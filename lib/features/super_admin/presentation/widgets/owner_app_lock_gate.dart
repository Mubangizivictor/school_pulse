import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils/biometric_auth_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

import 'package:school_pulse/core/utils/device_id_service.dart';

import '../../data/datasources/security_settings_remote_data_source.dart';
import '../../data/datasources/owner_session_remote_data_source.dart';
import '../bloc/security_settings_cubit.dart';

/// Real app-lock-while-open mechanism for the SaaS Owner console.
///
/// SCOPE DECISION: gates only signed-in superAdmin sessions, not the whole
/// app. Wiring a global lifecycle gate into `main.dart`'s app root would
/// affect every role (parents, teachers, school admins) while most of this
/// app is mid-refactor on other branches right now (see repo status); a
/// wrong assumption there risks locking out unrelated flows this task
/// never touched. The owner console is a single, already-isolated role
/// (`UserRole.superAdmin`), so gating it here is materially lower-risk and
/// still satisfies the "real app-lock" requirement for the account this
/// spec is about. If a future spec wants this for every role, this widget
/// can be lifted verbatim into `main.dart`'s `builder:` without changing
/// its internals - it already reads `AuthBloc` itself rather than assuming
/// where it's mounted.
///
/// Mechanism: `WidgetsBindingObserver` on `AppLifecycleState` (the same
/// pattern already used for lifecycle-sensitive coordinators elsewhere in
/// this app) marks a timestamp on `paused`/`inactive`, and on `resumed`
/// checks whether the idle gap exceeded [_idleThreshold]. If the owner has
/// both `biometricEnabled` and `appLockEnabled` set, a full-screen lock
/// overlay blocks interaction until a real `local_auth.authenticate()`
/// challenge succeeds.
class OwnerAppLockGate extends StatefulWidget {
  const OwnerAppLockGate({required this.child, super.key});

  final Widget child;

  @override
  State<OwnerAppLockGate> createState() => _OwnerAppLockGateState();
}

class _OwnerAppLockGateState extends State<OwnerAppLockGate>
    with WidgetsBindingObserver {
  static const _idleThreshold = Duration(minutes: 2);

  DateTime? _backgroundedAt;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt ??= DateTime.now();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      final backgroundedAt = _backgroundedAt;
      _backgroundedAt = null;
      if (backgroundedAt == null) return;
      if (DateTime.now().difference(backgroundedAt) < _idleThreshold) return;

      _maybeLockOnResume();
    }
  }

  Future<void> _maybeLockOnResume() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated ||
        authState.user.role != UserRole.superAdmin) {
      return;
    }
    final ownerId = authState.user.id;

    // Cheap heartbeat: bumps lastActiveAt for this device's session doc on
    // every real resume, without a continuous write stream.
    final deviceId = await di.sl<DeviceIdService>().getDeviceId();
    unawaited(
      di.sl<OwnerSessionRemoteDataSource>().touchLastActive(
        ownerId: ownerId,
        deviceId: deviceId,
      ),
    );

    final map = await di
        .sl<SecuritySettingsRemoteDataSource>()
        .watchSecuritySettings(ownerId)
        .first;
    if (!mounted) return;
    final settings = SecuritySettings.fromMap(map);
    // `local_auth` has no web implementation, so `_unlock()`'s
    // `BiometricAuthService.authenticate()` call would fail every time on
    // web - showing the lock overlay there would strand the owner behind a
    // challenge they can never pass. Web relies on the authenticated
    // Firebase session (and re-auth on individual sensitive actions)
    // instead of an app-level biometric lock.
    if (!kIsWeb && settings.biometricEnabled && settings.appLockEnabled) {
      setState(() => _locked = true);
    }
  }

  Future<void> _unlock() async {
    final success = await di.sl<BiometricAuthService>().authenticate(
      'Unlock the School Pulse owner console',
    );
    if (success && mounted) {
      setState(() => _locked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked) _LockOverlay(onUnlock: _unlock),
      ],
    );
  }
}

class _LockOverlay extends StatelessWidget {
  const _LockOverlay({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x2l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 48,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Owner Console Locked',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Authenticate to continue.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  PrimaryButton(
                    label: 'Unlock',
                    icon: Icons.fingerprint_rounded,
                    onPressed: onUnlock,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
