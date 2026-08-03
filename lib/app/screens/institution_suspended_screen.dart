import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';

/// Shown when the active institution's status is suspended or archived.
/// Read-only: does not sign the user out or delete any locally cached data,
/// it simply blocks further institution-scoped access until the SaaS Owner
/// reactivates the tenant.
class InstitutionSuspendedScreen extends StatelessWidget {
  const InstitutionSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.lock_outline,
          title: 'Institution access suspended',
          message:
              'Your institution\'s access has been paused by School Pulse. '
              'Any previously loaded data remains available for viewing. '
              'Please contact your platform administrator to restore access.',
          ctaLabel: 'Sign In Again',
          onCtaPressed: () => context.read<AuthBloc>().add(LogoutPressed()),
        ),
      ),
    );
  }
}
