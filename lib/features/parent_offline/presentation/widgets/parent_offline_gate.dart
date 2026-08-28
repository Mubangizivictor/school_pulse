import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/utils/biometric_auth_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/parent_offline/domain/parent_offline_cache_service.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Mobile-only local re-entry gate for the Parent Portal: on resume from
/// background, if the parent has previously set an offline PIN
/// (`ParentOfflineCacheService.hasOfflineGate`), require it (or biometrics)
/// before showing cached content again. This is what makes "reopen the
/// mobile Parent Portal offline using the existing local PIN/biometric
/// gate" true - a parent who has completed online setup and set this PIN
/// can pass this gate with zero network calls.
///
/// Requires a previously authenticated session: if no offline PIN has ever
/// been set for this parentId (e.g. first run, or setup never completed
/// online), this gate does not lock - the app's normal online auth guard
/// already covers that case, and no offline content exists to protect yet.
class ParentOfflineGate extends StatefulWidget {
  const ParentOfflineGate({required this.child, super.key});

  final Widget child;

  @override
  State<ParentOfflineGate> createState() => _ParentOfflineGateState();
}

class _ParentOfflineGateState extends State<ParentOfflineGate>
    with WidgetsBindingObserver {
  static const _idleThreshold = Duration(minutes: 1);

  DateTime? _backgroundedAt;
  bool _locked = false;
  bool _checkedOnLaunch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLock());
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
      _maybeLock();
    }
  }

  Future<void> _maybeLock() async {
    if (!_checkedOnLaunch) _checkedOnLaunch = true;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final parentId = authState.user.id;
    final hasGate = await di.sl<ParentOfflineCacheService>().hasOfflineGate(
      parentId,
    );
    if (!mounted || !hasGate) return;
    setState(() => _locked = true);
  }

  void _onUnlocked() {
    if (mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked) _ParentUnlockOverlay(onUnlocked: _onUnlocked),
      ],
    );
  }
}

class _ParentUnlockOverlay extends StatefulWidget {
  const _ParentUnlockOverlay({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<_ParentUnlockOverlay> createState() => _ParentUnlockOverlayState();
}

class _ParentUnlockOverlayState extends State<_ParentUnlockOverlay> {
  final _pinController = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final capable = await di.sl<BiometricAuthService>().isDeviceCapable();
    if (!capable || !mounted) return;
    final success = await di.sl<BiometricAuthService>().authenticate(
      'Unlock School Pulse',
    );
    if (success && mounted) widget.onUnlocked();
  }

  Future<void> _verifyPin() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final ok = await di.sl<ParentOfflineCacheService>().verifyOfflineGatePin(
      parentId: authState.user.id,
      pin: _pinController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      widget.onUnlocked();
      return;
    }
    setState(() {
      _checking = false;
      _error = 'Incorrect PIN';
      _pinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: AppColors.background(context),
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
                    'Enter your PIN',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'to access School Pulse',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      textAlign: TextAlign.center,
                      style: AppTypography.titleLarge,
                      decoration: InputDecoration(
                        counterText: '',
                        errorText: _error,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _verifyPin(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Unlock',
                    icon: Icons.lock_open_rounded,
                    onPressed: _checking ? null : _verifyPin,
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
