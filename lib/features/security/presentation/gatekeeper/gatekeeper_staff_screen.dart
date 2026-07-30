import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/gatekeeper_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/security/data/models/security_models.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_event.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'gatekeeper_shared.dart';

/// Gatekeeper Simple Mode staff entry/exit: search -> pick -> ENTER/LEAVE.
/// Mirrors GatekeeperStudentScreen's shape, reusing GetStaffMembers and
/// RecordStaffMovementRequested - no new domain logic.
class GatekeeperStaffScreen extends StatefulWidget {
  final Gate gate;
  const GatekeeperStaffScreen({super.key, required this.gate});

  @override
  State<GatekeeperStaffScreen> createState() => _GatekeeperStaffScreenState();
}

class _GatekeeperStaffScreenState extends State<GatekeeperStaffScreen> {
  bool _isSearching = false;
  bool _isSubmitting = false;
  List<UserEntity> _results = [];
  UserEntity? _selected;

  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    result.fold(
      (failure) => _showSnack('Search failed. Try again.', isError: true),
      (members) {
        final q = query.trim().toLowerCase();
        setState(() {
          _results = members.where((m) {
            if (m.schoolId != _schoolId) return false;
            if (q.isEmpty) return true;
            return m.name.toLowerCase().contains(q) || (m.staffCode ?? '').toLowerCase().contains(q);
          }).toList();
        });
      },
    );
    setState(() => _isSearching = false);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null),
    );
  }

  Future<void> _confirm(String direction) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _selected == null) return;
    setState(() => _isSubmitting = true);

    final movement = StaffMovementModel(
      id: const Uuid().v4(),
      staffId: _selected!.id,
      staffName: _selected!.name,
      timestamp: DateTime.now(),
      gateId: widget.gate.id,
      direction: direction,
      verificationMethod: 'Manual Search',
      officerId: authState.user.id,
      schoolId: authState.user.schoolId,
    );
    context.read<SecurityBloc>().add(RecordStaffMovementRequested(movement));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      body: BlocListener<SecurityBloc, SecurityState>(
        listenWhen: (p, c) => !identical(p.feedback, c.feedback) && c.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(feedback.message), backgroundColor: feedback.isError ? Colors.red : Colors.green),
          );
        },
        child: _selected == null ? _buildSearch(context) : _buildConfirm(context),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search by name or staff code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(hintText: 'e.g. Mr. Okello', prefixIcon: Icon(Icons.search)),
            onChanged: _search,
          ),
          const SizedBox(height: 16),
          if (_isSearching) const Center(child: CircularProgressIndicator()),
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final staff = _results[index];
                return AppCard(
                  onTap: () => setState(() => _selected = staff),
                  child: Row(
                    children: [
                      AvatarInitials(name: staff.name, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(staff.staffCode ?? staff.email, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirm(BuildContext context) {
    final staff = _selected!;
    final securityState = context.watch<SecurityBloc>().state;
    final suggestedDirection = suggestStaffDirection(securityState.staffMovements, staff.id);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarInitials(name: staff.name, size: 96),
          const SizedBox(height: 16),
          Text(staff.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(staff.staffCode ?? staff.email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          StatusBadge(
            label: suggestedDirection == 'In' ? 'Suggested: Enter' : 'Suggested: Leave',
            color: suggestedDirection == 'In' ? Colors.green : Colors.blueGrey,
            icon: suggestedDirection == 'In' ? Icons.login : Icons.logout,
          ),
          const SizedBox(height: 32),
          GatekeeperPrimaryButton(
            label: 'ENTER',
            icon: Icons.login,
            tone: GatekeeperButtonTone.success,
            isLoading: _isSubmitting,
            onPressed: () => _confirm('In'),
          ),
          const SizedBox(height: 12),
          GatekeeperPrimaryButton(
            label: 'LEAVE',
            icon: Icons.logout,
            tone: GatekeeperButtonTone.info,
            isLoading: _isSubmitting,
            onPressed: () => _confirm('Out'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSubmitting ? null : () => setState(() => _selected = null),
            child: const Text('Not this person — search again'),
          ),
        ],
      ),
    );
  }
}
