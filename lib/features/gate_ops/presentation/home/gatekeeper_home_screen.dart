import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/movement_event.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/visitor.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/check_in_visitor.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/check_out_visitor.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/watch_gates.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/watch_visitors.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// A focused, at-a-glance visitor desk for the gatekeeper role.
///
/// This deliberately keeps the most frequent job (checking a person in or
/// out) in the first viewport instead of burying it behind a dense dashboard
/// and bottom navigation.
class GatekeeperHomeScreen extends StatefulWidget {
  const GatekeeperHomeScreen({super.key});

  @override
  State<GatekeeperHomeScreen> createState() => _GatekeeperHomeScreenState();
}

class _GatekeeperHomeScreenState extends State<GatekeeperHomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _VisitorFilter _filter = _VisitorFilter.inside;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }

    final schoolId = auth.user.schoolId;
    return StreamBuilder<List<Gate>>(
      stream: di.sl<WatchGates>()(schoolId),
      builder: (context, gatesSnapshot) {
        final gates = gatesSnapshot.data ?? const <Gate>[];
        return StreamBuilder<List<Visitor>>(
          stream: di.sl<WatchVisitors>()(schoolId),
          builder: (context, visitorsSnapshot) {
            final visitors = visitorsSnapshot.data ?? const <Visitor>[];
            return Scaffold(
              backgroundColor: const Color(0xFFF5F7FB),
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {},
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _DeskHeader(
                          officerName: auth.user.name,
                          gateName: gates.isEmpty
                              ? 'Your assigned gate'
                              : gates.first.name,
                          onAddVisitor: () =>
                              _showCheckInSheet(auth.user, gates),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _SummaryStrip(visitors: visitors),
                            const SizedBox(height: 24),
                            _buildDirectory(visitors, gates, auth.user),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDirectory(
    List<Visitor> visitors,
    List<Gate> gates,
    UserEntity user,
  ) {
    final filtered = visitors.where((visitor) {
      final matchesFilter = switch (_filter) {
        _VisitorFilter.inside => visitor.status == VisitorStatus.checkedIn,
        _VisitorFilter.today => _isToday(visitor.arrivalTime),
        _VisitorFilter.all => true,
      };
      final needle = _query.toLowerCase();
      return matchesFilter &&
          (needle.isEmpty ||
              visitor.fullName.toLowerCase().contains(needle) ||
              visitor.hostName?.toLowerCase().contains(needle) == true);
    }).toList()..sort((a, b) => b.arrivalTime.compareTo(a.arrivalTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visitor desk',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        const Text(
          'Find someone quickly, then check them out in one tap.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: InputDecoration(
            hintText: 'Search name or host',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _VisitorFilter.values
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter.label),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          _EmptyVisitors(onAddVisitor: () => _showCheckInSheet(user, gates))
        else
          ...filtered.map(
            (visitor) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _VisitorTile(
                visitor: visitor,
                onCheckOut: visitor.status == VisitorStatus.checkedIn
                    ? () => _checkOut(visitor)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _checkOut(Visitor visitor) async {
    final result = await di.sl<CheckOutVisitor>()(visitor.id);
    if (!mounted) return;
    result.fold(
      (failure) => _showMessage(failure.message, isError: true),
      (_) => _showMessage('${visitor.fullName} checked out'),
    );
  }

  Future<void> _showCheckInSheet(UserEntity user, List<Gate> gates) async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final host = TextEditingController();
    String purpose = 'Meeting';
    String? gateId = gates.isNotEmpty ? gates.first.id : null;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Check in a visitor',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Capture only what the gate needs right now.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter the visitor’s name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number (optional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: host,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Who are they here to see?',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: purpose,
                        decoration: const InputDecoration(labelText: 'Purpose'),
                        items:
                            const [
                                  'Meeting',
                                  'Pickup',
                                  'Delivery',
                                  'Maintenance',
                                  'Other',
                                ]
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setSheetState(() => purpose = value!),
                      ),
                      if (gates.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: gateId,
                          decoration: const InputDecoration(
                            labelText: 'Entry gate',
                          ),
                          items: gates
                              .map(
                                (gate) => DropdownMenuItem(
                                  value: gate.id,
                                  child: Text(gate.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setSheetState(() => gateId = value),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: gateId == null
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final visitor = Visitor(
                                  id: 'visitor_${DateTime.now().microsecondsSinceEpoch}',
                                  schoolId: user.schoolId,
                                  fullName: name.text.trim(),
                                  phone: phone.text.trim().isEmpty
                                      ? null
                                      : phone.text.trim(),
                                  purpose: purpose,
                                  hostName: host.text.trim().isEmpty
                                      ? null
                                      : host.text.trim(),
                                  gateId: gateId!,
                                  arrivalTime: DateTime.now(),
                                  status: VisitorStatus.checkedIn,
                                  isQuickEntry: false,
                                  syncStatus: SyncStatus.pending,
                                );
                                final result = await di.sl<CheckInVisitor>()(
                                  visitor,
                                );
                                if (!sheetContext.mounted) return;
                                result.fold(
                                  (failure) =>
                                      ScaffoldMessenger.of(
                                        sheetContext,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(failure.message),
                                        ),
                                      ),
                                  (_) {
                                    Navigator.pop(sheetContext);
                                    _showMessage(
                                      '${visitor.fullName} is checked in',
                                    );
                                  },
                                );
                              },
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Check in visitor'),
                      ),
                      if (gateId == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Set up a gate before checking in visitors.',
                            style: TextStyle(color: Color(0xFFB45309)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    name.dispose();
    phone.dispose();
    host.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB42318)
            : const Color(0xFF166534),
      ),
    );
  }

  bool _isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }
}

enum _VisitorFilter {
  inside('Inside now'),
  today('Today'),
  all('All visits');

  const _VisitorFilter(this.label);
  final String label;
}

class _DeskHeader extends StatelessWidget {
  const _DeskHeader({
    required this.officerName,
    required this.gateName,
    required this.onAddVisitor,
  });
  final String officerName;
  final String gateName;
  final VoidCallback onAddVisitor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF071A42), Color(0xFF173D7A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GATE DESK',
                    style: TextStyle(
                      color: Color(0xFFB8D4FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    gateName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              tooltip: 'More options',
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Good day, ${officerName.split(' ').first}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Everything you need for a smooth entry point.',
          style: TextStyle(color: Color(0xFFD9E7FF), fontSize: 14),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onAddVisitor,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Check in a visitor'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFA51F),
              foregroundColor: const Color(0xFF17233E),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.visitors});
  final List<Visitor> visitors;

  @override
  Widget build(BuildContext context) {
    final inside = visitors
        .where((visitor) => visitor.status == VisitorStatus.checkedIn)
        .length;
    final today = visitors.where((visitor) {
      final now = DateTime.now();
      return visitor.arrivalTime.year == now.year &&
          visitor.arrivalTime.month == now.month &&
          visitor.arrivalTime.day == now.day;
    }).length;
    final overdue = visitors
        .where(
          (visitor) =>
              visitor.status == VisitorStatus.checkedIn &&
              DateTime.now().difference(visitor.arrivalTime).inHours >= 4,
        )
        .length;
    return Row(
      children: [
        _Metric(
          value: '$inside',
          label: 'Inside',
          icon: Icons.login_rounded,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 10),
        _Metric(
          value: '$today',
          label: 'Today',
          icon: Icons.groups_2_outlined,
          color: const Color(0xFF0F9F6E),
        ),
        const SizedBox(width: 10),
        _Metric(
          value: '$overdue',
          label: 'Needs review',
          icon: Icons.schedule_outlined,
          color: const Color(0xFFB45309),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _VisitorTile extends StatelessWidget {
  const _VisitorTile({required this.visitor, this.onCheckOut});
  final Visitor visitor;
  final VoidCallback? onCheckOut;
  @override
  Widget build(BuildContext context) {
    final inside = visitor.status == VisitorStatus.checkedIn;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: inside
                ? const Color(0xFFE7F0FF)
                : const Color(0xFFF1F5F9),
            foregroundColor: inside
                ? const Color(0xFF2563EB)
                : const Color(0xFF64748B),
            child: Text(
              visitor.fullName.isEmpty
                  ? '?'
                  : visitor.fullName[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${visitor.purpose}${visitor.hostName == null ? '' : ' · ${visitor.hostName}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: inside
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    inside ? 'IN · ${_time(visitor.arrivalTime)}' : 'OUT',
                    style: TextStyle(
                      color: inside
                          ? const Color(0xFF166534)
                          : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onCheckOut != null)
            IconButton(
              onPressed: onCheckOut,
              tooltip: 'Check out',
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFB45309)),
            ),
        ],
      ),
    );
  }

  static String _time(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }
}

class _EmptyVisitors extends StatelessWidget {
  const _EmptyVisitors({required this.onAddVisitor});
  final VoidCallback onAddVisitor;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE8EDF5)),
    ),
    child: Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF1FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_search_outlined,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'No visitors here yet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Use the check-in action when someone arrives.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onAddVisitor,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Check in visitor'),
        ),
      ],
    ),
  );
}
