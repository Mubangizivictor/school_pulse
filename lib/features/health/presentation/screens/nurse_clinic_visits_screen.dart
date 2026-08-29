import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/medical_inventory.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/nurse/presentation/clinic_ui.dart';

class NurseClinicVisitsScreen extends StatefulWidget {
  const NurseClinicVisitsScreen({super.key});
  @override
  State<NurseClinicVisitsScreen> createState() =>
      _NurseClinicVisitsScreenState();
}

class _NurseClinicVisitsScreenState extends State<NurseClinicVisitsScreen> {
  String _query = '';
  bool _followUpOnly = false;
  String get _schoolId {
    final a = context.read<AuthBloc>().state;
    return a is AuthAuthenticated ? a.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    if (_schoolId.isNotEmpty) {
      context.read<HealthBloc>().add(FetchClinicVisits(schoolId: _schoolId));
    }
  }

  @override
  Widget build(BuildContext context) => ClinicPage(
    floatingActionButton: FloatingActionButton(
      backgroundColor: ClinicUi.black,
      foregroundColor: Colors.white,
      onPressed: () => context.push('/staff/nurse/lookup'),
      child: const Icon(Icons.add),
    ),
    child: BlocBuilder<HealthBloc, HealthState>(
      builder: (_, state) {
        final all = state is ClinicVisitsLoaded
            ? state.visits
            : const <ClinicVisit>[];
        final visits = all
            .where(
              (v) =>
                  (!_followUpOnly || v.followUpRequired) &&
                  (_query.isEmpty ||
                      v.studentId.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      v.reason.toLowerCase().contains(_query.toLowerCase())),
            )
            .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Clinic visits',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: ClinicUi.foreground(context),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _followUpOnly = !_followUpOnly),
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      color: _followUpOnly
                          ? ClinicUi.red
                          : ClinicUi.foreground(context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search visits',
                        filled: true,
                        fillColor: ClinicUi.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _followUpOnly = !_followUpOnly),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(64, 48),
                      side: const BorderSide(color: ClinicUi.line),
                    ),
                    child: const Text('Filter'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 7),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Today',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Expanded(
              child: state is HealthLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: ClinicUi.black),
                    )
                  : visits.isEmpty
                  ? const ClinicEmptyState(
                      title: 'No matching visits',
                      message:
                          'Try another search or record a new clinic visit.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                      itemCount: visits.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _VisitCard(visit: visits[i]),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});
  final ClinicVisit visit;

  void _openDispense(BuildContext context) {
    final schoolId = () {
      final a = context.read<AuthBloc>().state;
      return a is AuthAuthenticated ? a.user.schoolId : '';
    }();
    if (schoolId.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ClinicUi.background(context),
      builder: (_) => BlocProvider.value(
        value: context.read<HealthBloc>(),
        child: DispenseMedicineSheet(visit: visit, schoolId: schoolId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final needsReview = visit.followUpRequired;
    return InkWell(
      onTap: () => context.push('/staff/nurse/profile/${visit.studentId}'),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ClinicUi.outlinedCard(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              child: Text(
                DateFormat('h:mm a').format(visit.dateTime),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              needsReview ? Icons.radio_button_checked : Icons.check_circle,
              size: 17,
              color: needsReview ? ClinicUi.red : ClinicUi.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          visit.studentId,
                          style: TextStyle(
                            color: ClinicUi.foreground(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ClinicUi.pill(
                        needsReview ? 'Follow-up' : 'Completed',
                        color: needsReview ? ClinicUi.red : ClinicUi.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Reason for visit',
                    style: const TextStyle(fontSize: 10, color: ClinicUi.muted),
                  ),
                  Text(
                    visit.reason,
                    style: TextStyle(
                      color: ClinicUi.foreground(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    visit.followUpRequired
                        ? 'Follow-up required'
                        : 'Routine clinical note',
                    style: TextStyle(
                      fontSize: 11,
                      color: needsReview ? ClinicUi.red : ClinicUi.muted,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: ClinicUi.muted),
              onSelected: (v) {
                if (v == 'profile') {
                  context.push('/staff/nurse/profile/${visit.studentId}');
                } else if (v == 'dispense') {
                  _openDispense(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'profile', child: Text('Open profile')),
                PopupMenuItem(
                  value: 'dispense',
                  child: Text('Dispense medicine'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dispenses a medicine or supply against [visit] through the
/// `dispenseMedicalItem` callable (server-authoritative: atomic decrement,
/// no-negative guard, learner check, movement + audit rows). The visit's own
/// studentId is sent, so the server rejects a mismatch.
class DispenseMedicineSheet extends StatefulWidget {
  const DispenseMedicineSheet({
    required this.visit,
    required this.schoolId,
    super.key,
  });
  final ClinicVisit visit;
  final String schoolId;

  @override
  State<DispenseMedicineSheet> createState() => _DispenseMedicineSheetState();
}

class _DispenseMedicineSheetState extends State<DispenseMedicineSheet> {
  MedicalInventoryItem? _item;
  final _qty = TextEditingController(text: '1');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    context.read<HealthBloc>().add(FetchInventory(widget.schoolId));
  }

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  void _submit() {
    final item = _item;
    final qty = int.tryParse(_qty.text.trim()) ?? 0;
    if (item == null || qty <= 0) return;
    setState(() => _submitting = true);
    context.read<HealthBloc>().add(
      DispenseMedicalItemEvent(
        itemId: item.id,
        visitId: widget.visit.id,
        studentId: widget.visit.studentId,
        quantity: qty,
        schoolId: widget.schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return BlocListener<HealthBloc, HealthState>(
      listenWhen: (_, s) =>
          s is HealthActionSuccess || s is HealthError || s is InventoryLoaded,
      listener: (context, state) {
        if (state is HealthActionSuccess && _submitting) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Item dispensed')));
        } else if (state is HealthError && _submitting) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dispense for ${widget.visit.studentId}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ClinicUi.foreground(context),
              ),
            ),
            const SizedBox(height: 14),
            BlocBuilder<HealthBloc, HealthState>(
              buildWhen: (_, s) => s is InventoryLoaded || s is HealthLoading,
              builder: (_, state) {
                if (state is! InventoryLoaded) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(color: ClinicUi.black),
                    ),
                  );
                }
                final items = state.items;
                if (items.isEmpty) {
                  return const ClinicEmptyState(
                    title: 'No stock',
                    message: 'There are no inventory items to dispense.',
                  );
                }
                _item ??= items.first;
                return DropdownButtonFormField<MedicalInventoryItem>(
                  initialValue: _item,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Item'),
                  items: [
                    for (final it in items)
                      DropdownMenuItem(
                        value: it,
                        child: Text(
                          '${it.name} · ${it.quantity} ${it.unit} in stock',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _item = v),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: ClinicUi.black,
                minimumSize: const Size(0, 48),
              ),
              child: Text(_submitting ? 'Dispensing…' : 'Dispense'),
            ),
          ],
        ),
      ),
    );
  }
}
