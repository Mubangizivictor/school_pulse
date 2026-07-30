import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/utils/gatekeeper_gate_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/gatekeeper_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_event.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_state.dart';
import 'package:school_pulse/features/security/presentation/widgets/emergency_protocol_dialog.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_bloc.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_event.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'gatekeeper_incident_screen.dart';
import 'gatekeeper_pickup_screen.dart';
import 'gatekeeper_scan_screen.dart';
import 'gatekeeper_staff_screen.dart';
import 'gatekeeper_student_screen.dart';
import 'gatekeeper_visitor_checkin_screen.dart';
import 'gatekeeper_visitor_checkout_screen.dart';

/// Home screen for Gatekeeper Simple Mode - large-button, minimal-typing UI
/// for the `gatekeeper` role. Reuses SecurityBloc/VisitorsBloc exactly as
/// the advanced SecurityDashboardScreen (Reception/Supervisor mode) does; no
/// new domain or data layer. Role-based routing to this screen lives in
/// router.dart.
class GatekeeperHomeScreen extends StatefulWidget {
  const GatekeeperHomeScreen({super.key});

  @override
  State<GatekeeperHomeScreen> createState() => _GatekeeperHomeScreenState();
}

class _GatekeeperHomeScreenState extends State<GatekeeperHomeScreen> {
  final _gateService = GatekeeperGateService();
  String? _selectedGateId;
  bool _gateLoaded = false;
  bool _isOnline = true;
  bool _isGateSheetOpen = false;
  late final Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadGate();
    _refreshConnectivity();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SecurityBloc>().add(LoadSecurityDashboard(authState.user.schoolId));
      context.read<VisitorsBloc>().add(LoadVisitors(authState.user.schoolId));
      context.read<VisitorsBloc>().add(WatchVisitorsList(authState.user.schoolId));
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _loadGate() async {
    final id = await _gateService.getSelectedGateId();
    if (!mounted) return;
    setState(() {
      _selectedGateId = id;
      _gateLoaded = true;
    });
  }

  Future<void> _refreshConnectivity() async {
    final online = await di.sl<NetworkInfo>().isConnected;
    if (mounted) setState(() => _isOnline = online);
  }

  Future<void> _pickGate(List<Gate> gates) async {
    // Guards against showModalBottomSheet being triggered again (e.g. by the
    // per-second clock rebuild, or a live Firestore gates update) while a
    // sheet from a previous call is still open - without this, sheets stack
    // and a tap on the visible one leaves an older, invisible one still
    // awaiting underneath.
    if (_isGateSheetOpen) return;
    _isGateSheetOpen = true;
    try {
      final gate = await showModalBottomSheet<Gate>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => _GatePickerSheet(gates: gates),
      );
      if (gate != null) {
        await _gateService.setSelectedGateId(gate.id);
        if (mounted) setState(() => _selectedGateId = gate.id);
      }
    } finally {
      _isGateSheetOpen = false;
    }
  }

  void _openEmergency() {
    showDialog(context: context, builder: (_) => const EmergencyProtocolDialog());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Gate',
            onPressed: () => _pickGate(context.read<SecurityBloc>().state.gates),
          ),
          const NotificationBellButton(),
        ],
      ),
      body: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, securityState) {
          if (!_gateLoaded || securityState.status == SecurityStatus.loading || securityState.status == SecurityStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (securityState.gates.isEmpty) {
            return const EmptyState(
              icon: Icons.door_front_door_outlined,
              title: 'No gate configured',
              message: 'Ask an admin to set up a gate before you can start.',
            );
          }

          if (_selectedGateId == null || !securityState.gates.any((g) => g.id == _selectedGateId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && (_selectedGateId == null || !securityState.gates.any((g) => g.id == _selectedGateId))) {
                _pickGate(securityState.gates);
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          final gate = securityState.gates.firstWhere((g) => g.id == _selectedGateId);
          final visitorsState = context.watch<VisitorsBloc>().state;
          final peopleInside = (securityState.stats['peopleCurrentlyInside'] ?? 0).toString();
          final pendingSync = visitorsState is VisitorsLoaded ? visitorsState.visitors.where((v) => !v.isSynced).length : 0;
          final hasActiveEmergency = securityState.activeEmergencies.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SecurityBloc>().add(LoadSecurityDashboard(user.schoolId));
              await _refreshConnectivity();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HomeHeader(
                  schoolName: user.schoolName ?? 'School Pulse',
                  gateName: gate.name,
                  officerName: user.name,
                  now: _now,
                  isOnline: _isOnline,
                  pendingSync: pendingSync,
                  peopleInside: peopleInside,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = gatekeeperGridColumns(constraints.maxWidth);
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.05,
                      children: _buildTiles(context, gate, hasActiveEmergency),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTiles(BuildContext context, Gate gate, bool hasActiveEmergency) {
    final colors = Theme.of(context).extension<SemanticColors>()!;
    return [
      GatekeeperActionTile(
        label: 'Scan',
        icon: Icons.qr_code_scanner,
        color: colors.info,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GatekeeperScanScreen(gate: gate))),
      ),
      GatekeeperActionTile(
        label: 'Student',
        icon: Icons.school_outlined,
        color: colors.primaryBlue,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GatekeeperStudentScreen(gate: gate))),
      ),
      GatekeeperActionTile(
        label: 'Visitor In',
        icon: Icons.person_add_alt_1_outlined,
        color: colors.success,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GatekeeperVisitorCheckInScreen(gate: gate))),
      ),
      GatekeeperActionTile(
        label: 'Visitor Out',
        icon: Icons.logout,
        color: colors.info,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GatekeeperVisitorCheckOutScreen())),
      ),
      GatekeeperActionTile(
        label: 'Staff',
        icon: Icons.badge_outlined,
        color: colors.primaryBlue,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GatekeeperStaffScreen(gate: gate))),
      ),
      GatekeeperActionTile(
        label: 'Pickup',
        icon: Icons.family_restroom,
        color: colors.warning,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GatekeeperPickupScreen(gate: gate))),
      ),
      GatekeeperActionTile(
        label: 'Incident',
        icon: Icons.report_gmailerrorred_outlined,
        color: colors.warning,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GatekeeperIncidentScreen())),
      ),
      GatekeeperActionTile(
        label: hasActiveEmergency ? 'EMERGENCY!' : 'Emergency',
        icon: Icons.emergency_outlined,
        color: colors.error,
        onTap: _openEmergency,
        badgeCount: hasActiveEmergency ? 1 : null,
      ),
    ];
  }
}

class _HomeHeader extends StatelessWidget {
  final String schoolName;
  final String gateName;
  final String officerName;
  final DateTime now;
  final bool isOnline;
  final int pendingSync;
  final String peopleInside;

  const _HomeHeader({
    required this.schoolName,
    required this.gateName,
    required this.officerName,
    required this.now,
    required this.isOnline,
    required this.pendingSync,
    required this.peopleInside,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarInitials(name: officerName, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(officerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '$schoolName • $gateName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              GatekeeperStatusChip(
                state: isOnline ? GatekeeperConnectionState.online : GatekeeperConnectionState.offline,
                pendingSyncCount: pendingSync,
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEE, d MMM • h:mm:ss a').format(now),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(Icons.groups_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('$peopleInside inside', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GatePickerSheet extends StatelessWidget {
  final List<Gate> gates;
  const _GatePickerSheet({required this.gates});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Which gate are you at?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'You won\'t be asked again on this device.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...gates.map(
              (gate) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => Navigator.of(context).pop(gate),
                  child: Row(
                    children: [
                      const Icon(Icons.door_front_door_outlined, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gate.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(gate.location, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
