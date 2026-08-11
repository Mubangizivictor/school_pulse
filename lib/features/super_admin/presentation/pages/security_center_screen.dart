import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/utils/biometric_auth_service.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/core/utils/device_info_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';

import '../../data/datasources/security_settings_remote_data_source.dart';
import '../../data/datasources/owner_session_remote_data_source.dart';
import '../bloc/security_settings_cubit.dart';
import '../bloc/owner_session_cubit.dart';
import 'security_settings_deep_dive_screen.dart';
import 'trusted_devices_screen.dart';

/// SaaS Owner Settings > Security > Overview.
///
/// Real UI backed by real data: Firebase Auth's `currentUser` for identity
/// / recovery contact / last sign-in, the app-wide [AuthBloc] for the MFA
/// flag actually persisted on the owner's profile, and a small
/// [SecuritySettingsCubit] (own Firestore doc, namespaced under a
/// `security` sub-map) for owner-set preferences like Login Alerts.
///
/// "Account Secure" banner logic (documented here since it's a judgment
/// call, not a given number): secure when MFA is enabled AND the password
/// was verifiably changed at least once via Firebase Auth's tracked
/// `metadata.lastSignInTime`/creation heuristic is NOT reliable enough to
/// infer password-change recency (Firebase doesn't expose a
/// last-password-change timestamp on the client SDK), so the real signal
/// used is just: MFA enabled. That's the one honestly-available strong
/// signal the client can read. Everything else (Trusted Devices, Active
/// Sessions, Passkey/Biometrics) surfaces its real state or an honest
/// "not available" explanation rather than being folded into the score.
class SecurityCenterScreen extends StatelessWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ownerId = user?.uid ?? 'unknown';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SecuritySettingsCubit(
            dataSource: sl<SecuritySettingsRemoteDataSource>(),
            ownerId: ownerId,
          ),
        ),
        BlocProvider(
          create: (_) => OwnerSessionCubit(
            dataSource: sl<OwnerSessionRemoteDataSource>(),
            deviceIdService: sl<DeviceIdService>(),
            deviceInfoService: sl<DeviceInfoService>(),
            ownerId: ownerId,
          ),
        ),
      ],
      child: _SecurityOverviewBody(user: user),
    );
  }
}

class _SecurityOverviewBody extends StatefulWidget {
  const _SecurityOverviewBody({required this.user});
  final User? user;

  @override
  State<_SecurityOverviewBody> createState() => _SecurityOverviewBodyState();
}

class _SecurityOverviewBodyState extends State<_SecurityOverviewBody> {
  bool? _deviceCapable;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    sl<BiometricAuthService>().isDeviceCapable().then((capable) {
      if (mounted) setState(() => _deviceCapable = capable);
    });
  }

  Future<void> _toggleBiometric(bool enable) async {
    final cubit = context.read<SecuritySettingsCubit>();
    if (!enable) {
      await cubit.setBiometricEnabled(false);
      return;
    }
    if (_deviceCapable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This device has no biometrics enrolled or does not support '
            'biometric authentication.',
          ),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    final success = await sl<BiometricAuthService>().authenticate(
      'Confirm it\'s you to enable biometric unlock',
    );
    if (mounted) setState(() => _busy = false);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric confirmation failed.')),
        );
      }
      return;
    }
    await cubit.setBiometricEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final authState = context.watch<AuthBloc>().state;
    final mfaEnabled =
        authState is AuthAuthenticated && authState.user.mfaEnabled;
    final lastSignIn = user?.metadata.lastSignInTime;
    final recoveryEmail = user?.email?.trim();
    final recoveryPhone = user?.phoneNumber?.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _SecureStatusBanner(secure: mfaEnabled),
          const SizedBox(height: AppSpacing.x2l),
          Text(
            'RECOVERY CONTACT',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: recoveryEmail?.isNotEmpty == true
                      ? recoveryEmail!
                      : 'Not set',
                ),
                const Divider(height: AppSpacing.x2l),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: recoveryPhone?.isNotEmpty == true
                      ? recoveryPhone!
                      : 'Not set',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          Text(
            'SECURITY OVERVIEW',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _SecurityRow(
            icon: Icons.verified_user_outlined,
            title: 'Two-Step Verification',
            subtitle: mfaEnabled
                ? 'Authenticator app required at sign-in'
                : 'Not enabled — add an authenticator app',
            statusLabel: mfaEnabled ? 'Enabled' : 'Disabled',
            statusColor: mfaEnabled
                ? AppColors.success(context)
                : AppColors.danger(context),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SecuritySettingsDeepDiveScreen(),
              ),
            ),
          ),
          BlocBuilder<SecuritySettingsCubit, SecuritySettingsState>(
            builder: (context, state) {
              final enabled = state.settings.loginAlertsEnabled;
              return _SecurityRow(
                icon: Icons.notifications_active_outlined,
                title: 'Login Alerts',
                subtitle: enabled
                    ? 'Sign-ins are recorded to your audit log'
                    : 'Turn on to record sign-in events',
                trailing: Switch.adaptive(
                  value: enabled,
                  onChanged: (value) => context
                      .read<SecuritySettingsCubit>()
                      .setLoginAlertsEnabled(value),
                ),
              );
            },
          ),
          BlocBuilder<OwnerSessionCubit, OwnerSessionState>(
            builder: (context, sessionState) {
              final trustedCount = sessionState.sessions
                  .where((s) => s.trusted)
                  .length;
              return _SecurityRow(
                icon: Icons.devices_other_outlined,
                title: 'Trusted Devices',
                subtitle: trustedCount > 0
                    ? '$trustedCount device${trustedCount == 1 ? '' : 's'} marked as trusted'
                    : 'No devices marked as trusted yet',
                statusLabel:
                    '${sessionState.sessions.length} device'
                    '${sessionState.sessions.length == 1 ? '' : 's'}',
                statusColor: AppColors.primary(context),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<OwnerSessionCubit>(),
                      child: const TrustedDevicesScreen(),
                    ),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<OwnerSessionCubit, OwnerSessionState>(
            builder: (context, sessionState) {
              final count = sessionState.sessions.length;
              return _SecurityRow(
                icon: Icons.laptop_mac_outlined,
                title: 'Active Sessions',
                subtitle: lastSignIn != null
                    ? 'This device — signed in ${_formatWhen(lastSignIn)}'
                    : 'Current session',
                statusLabel: count > 0
                    ? '$count device${count == 1 ? '' : 's'}'
                    : '1 device',
                statusColor: AppColors.primary(context),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<OwnerSessionCubit>(),
                      child: const SecuritySettingsDeepDiveScreen(),
                    ),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<SecuritySettingsCubit, SecuritySettingsState>(
            builder: (context, state) {
              final enabled = state.settings.biometricEnabled;
              final capable = _deviceCapable;
              final subtitle = capable == null
                  ? 'Checking device capability…'
                  : capable
                  ? (enabled
                        ? 'Biometric unlock is enabled for this account'
                        : 'Turn on to require biometrics for App Lock')
                  : 'This device has no biometrics enrolled or does not '
                        'support biometric authentication';
              return _SecurityRow(
                icon: Icons.fingerprint_rounded,
                title: 'Passkey / Biometrics',
                subtitle: subtitle,
                trailing: _busy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch.adaptive(
                        value: enabled,
                        onChanged: capable == false
                            ? null
                            : (value) => _toggleBiometric(value),
                      ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.x2l),
          SecondaryButton(
            label: 'Security Settings',
            icon: Icons.settings_outlined,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SecuritySettingsDeepDiveScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatWhen(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _SecureStatusBanner extends StatelessWidget {
  const _SecureStatusBanner({required this.secure});
  final bool secure;

  @override
  Widget build(BuildContext context) {
    final color = secure
        ? AppColors.success(context)
        : AppColors.warning(context);
    return AppCard(
      color: color.withValues(alpha: 0.08),
      showBorder: true,
      borderColor: color.withValues(alpha: 0.25),
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              secure ? Icons.shield_rounded : Icons.gpp_maybe_rounded,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  secure ? 'Account Secure' : 'Action Recommended',
                  style: AppTypography.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  secure
                      ? 'Two-step verification is protecting your account.'
                      : 'Enable two-step verification to secure your account.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary(context)),
        const SizedBox(width: AppSpacing.l),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.statusLabel,
    this.statusColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? statusLabel;
  final Color? statusColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.success(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      onTap: onTap,
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          if (trailing != null)
            trailing!
          else if (statusLabel != null)
            StatusBadge(label: statusLabel!, color: statusColor!)
          else if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
        ],
      ),
    );
  }
}
