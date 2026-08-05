import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/gatekeeper_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/security/data/models/security_models.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/domain/entities/verification_method.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_event.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_state.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_bloc.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Gatekeeper Simple Mode parent/guardian pickup: enter the parent access
/// code -> pick the child -> RELEASE. Reuses ResolveParentAccessCode and
/// records the release as a student movement (direction Out, movementType
/// "Authorized Pickup") exactly like VerificationWorkflow's parent-code path
/// (Reception mode) - no new domain concept, just a large-button front end.
/// Blocks release and requires a supervisor if the parent/phone matches the
/// visitor blacklist (now schoolId-scoped).
class GatekeeperPickupScreen extends StatefulWidget {
  final Gate gate;
  const GatekeeperPickupScreen({super.key, required this.gate});

  @override
  State<GatekeeperPickupScreen> createState() => _GatekeeperPickupScreenState();
}

class _GatekeeperPickupScreenState extends State<GatekeeperPickupScreen> {
  final _codeController = TextEditingController();
  bool _isSearching = false;
  bool _isSubmitting = false;
  ParentAccessCode? _resolved;
  int? _selectedChildIndex;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _resolveCode(String code) async {
    if (code.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final result = await di.sl<ResolveParentAccessCode>()(code.trim());
    if (!mounted) return;
    result.fold(
      (failure) => _showSnack(
        'Code not recognized. Ask the parent to check it.',
        isError: true,
      ),
      (accessCode) => setState(() => _resolved = accessCode),
    );
    setState(() => _isSearching = false);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  bool get _isBlacklisted {
    final code = _resolved;
    if (code == null) return false;
    final visitorsState = context.read<VisitorsBloc>().state;
    if (visitorsState is! VisitorsLoaded) return false;
    final phone = code.phoneNumber ?? '';
    final name = code.parentName ?? '';
    return visitorsState.blacklist.any(
      (b) =>
          (phone.isNotEmpty && b.phone == phone) ||
          (name.isNotEmpty && b.fullName.toLowerCase() == name.toLowerCase()),
    );
  }

  Future<void> _confirmRelease() async {
    final authState = context.read<AuthBloc>().state;
    final code = _resolved;
    if (authState is! AuthAuthenticated ||
        code == null ||
        _selectedChildIndex == null)
      return;
    setState(() => _isSubmitting = true);
    final deviceId = await DeviceIdService().getDeviceId();
    if (!mounted) return;

    final studentId = code.studentIds[_selectedChildIndex!];
    final studentName = code.studentNames.length > _selectedChildIndex!
        ? code.studentNames[_selectedChildIndex!]
        : 'Student';

    final movement = StudentMovementModel(
      id: const Uuid().v4(),
      studentId: studentId,
      studentName: studentName,
      className: '',
      timestamp: DateTime.now(),
      gateId: widget.gate.id,
      direction: 'Out',
      movementType: 'Authorized Pickup',
      verificationMethod: VerificationMethod.parentCode.label,
      officerId: authState.user.id,
      deviceId: deviceId,
      schoolId: authState.user.schoolId,
      pickupDetails: {
        'parentCode': code.parentCode,
        'parentName': code.parentName,
        'phoneNumber': code.phoneNumber,
      },
    );
    context.read<SecurityBloc>().add(RecordStudentMovementRequested(movement));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pickup')),
      body: BlocListener<SecurityBloc, SecurityState>(
        listenWhen: (p, c) =>
            !identical(p.feedback, c.feedback) && c.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(feedback.message),
              backgroundColor: feedback.isError ? Colors.red : Colors.green,
            ),
          );
        },
        child: _resolved == null
            ? _buildCodeEntry(context)
            : _buildChildSelect(context),
      ),
    );
  }

  Widget _buildCodeEntry(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the parent\'s pickup code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            autofocus: true,
            style: const TextStyle(fontSize: 22, letterSpacing: 1.2),
            decoration: InputDecoration(
              hintText: 'e.g. PU-4821',
              prefixIcon: const Icon(Icons.family_restroom),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _resolveCode(_codeController.text),
              ),
            ),
            onSubmitted: _resolveCode,
          ),
          const SizedBox(height: 20),
          if (_isSearching) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildChildSelect(BuildContext context) {
    final code = _resolved!;
    final blacklisted = _isBlacklisted;

    if (blacklisted) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 72,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pickup not authorized',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This person is on the security blacklist. Do not release the child. Call a supervisor.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _resolved = null),
              child: const Text('Back'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            code.parentName ?? 'Parent',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            code.phoneNumber ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Which child is being picked up?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: code.studentIds.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final name = code.studentNames.length > index
                    ? code.studentNames[index]
                    : 'Student';
                final selected = _selectedChildIndex == index;
                return AppCard(
                  onTap: () => setState(() => _selectedChildIndex = index),
                  borderColor: selected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  child: Row(
                    children: [
                      AvatarInitials(name: name, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          GatekeeperPrimaryButton(
            label: 'RELEASE',
            icon: Icons.logout,
            tone: GatekeeperButtonTone.success,
            isLoading: _isSubmitting,
            onPressed: _selectedChildIndex == null ? null : _confirmRelease,
          ),
        ],
      ),
    );
  }
}
