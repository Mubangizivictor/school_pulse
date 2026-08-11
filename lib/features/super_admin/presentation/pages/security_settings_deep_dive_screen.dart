import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/utils/biometric_auth_service.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/core/utils/device_info_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/profile/presentation/screens/change_password_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/two_factor_auth_screen.dart';
import 'package:school_pulse/injection_container.dart';

import '../../data/datasources/security_settings_remote_data_source.dart';
import '../../data/datasources/owner_session_remote_data_source.dart';
import '../bloc/security_settings_cubit.dart';
import '../bloc/owner_session_cubit.dart';
import 'audit_logs_screen.dart';
import 'trusted_devices_screen.dart';

/// SaaS Owner Settings > Security > Settings (deep dive).
///
/// Change Password reuses the existing real Firebase Auth reauth +
/// updatePassword flow from `ChangePasswordScreen` rather than duplicating
/// it. Two-Step Verification reuses the existing real TOTP enrollment flow
/// from `TwoFactorAuthScreen`.
///
/// Session/device data is honestly limited to what Firebase Auth's client
/// SDK actually exposes for the current device (`currentUser.metadata`) -
/// there is no multi-device session registry backing this app, so only a
/// single real "this device" row is shown rather than a fabricated list.
///
/// "Revoke All Sessions" calls the real `revokeOwnerSessions` Cloud
/// Function (Admin SDK `revokeRefreshTokens`), which invalidates every
/// existing session/ID token for this owner across all devices, then also
/// signs out locally. Suspicious Activity reads real flagged sign-in
/// events from `super_admin_sign_in_events` (written by the
/// `logOwnerSignIn` callable invoked after login).
class SecuritySettingsDeepDiveScreen extends StatelessWidget {
  const SecuritySettingsDeepDiveScreen({super.key});

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
      child: _DeepDiveBody(user: user),
    );
  }
}

class _DeepDiveBody extends StatefulWidget {
  const _DeepDiveBody({required this.user});
  final User? user;

  @override
  State<_DeepDiveBody> createState() => _DeepDiveBodyState();
}

class _DeepDiveBodyState extends State<_DeepDiveBody> {
  bool _revoking = false;
  bool? _deviceCapable;
  bool _biometricBusy = false;

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
    setState(() => _biometricBusy = true);
    final success = await sl<BiometricAuthService>().authenticate(
      'Confirm it\'s you to enable biometric unlock',
    );
    if (mounted) setState(() => _biometricBusy = false);
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

  Future<void> _confirmRevoke() async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Sign out all devices?',
      message:
          'This immediately revokes every active School Pulse session for '
          'your owner account, on this device and any other device you\'re '
          'signed into. You will need to sign in again everywhere.',
      confirmLabel: 'Sign Out Everywhere',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _revoking = true);
    final ownerId = widget.user?.uid;
    try {
      if (ownerId != null) {
        // Real revocation: invalidates refresh tokens for this owner on
        // every device (see revokeOwnerSessions in
        // public_functions/owner_sign_in_events.js), not just this device.
        await FirebaseFunctions.instanceFor(
          region: 'europe-west1',
        ).httpsCallable('revokeOwnerSessions').call();
        await context.read<SecuritySettingsCubit>().logSecurityEvent(
          action: 'REVOKE_SESSION',
          reason: 'Owner-initiated sign-out from Security Settings',
        );
      }
      await FirebaseAuth.instance.signOut();
    } finally {
      if (mounted) setState(() => _revoking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final lastSignIn = user?.metadata.lastSignInTime;
    final createdAt = user?.metadata.creationTime;
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _SectionLabel('ACCOUNT'),
          const SizedBox(height: AppSpacing.m),
          _ActionTile(
            icon: Icons.password_rounded,
            title: 'Change Password',
            subtitle: 'Update your sign-in password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          _ActionTile(
            icon: Icons.verified_user_outlined,
            title: 'Two-Step Verification',
            subtitle: 'Authenticator app for sign-in',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TwoFactorAuthScreen()),
            ),
          ),
          BlocBuilder<SecuritySettingsCubit, SecuritySettingsState>(
            builder: (context, state) {
              final settings = state.settings;
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                showShadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: _deviceCapable == false
                              ? AppColors.textMuted(context)
                              : AppColors.success(context),
                        ),
                        const SizedBox(width: AppSpacing.l),
                        Expanded(
                          child: Text(
                            'Biometric Unlock',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        _biometricBusy
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Switch.adaptive(
                                value: settings.biometricEnabled,
                                onChanged: _deviceCapable == false
                                    ? null
                                    : (value) => _toggleBiometric(value),
                              ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _deviceCapable == null
                          ? 'Checking device capability…'
                          : _deviceCapable == false
                          ? 'This device has no biometrics enrolled or '
                                'does not support biometric authentication'
                          : 'Confirms it\'s you with a real device biometric '
                                'challenge; required before App Lock below '
                                'can be turned on',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const Divider(height: AppSpacing.x2l),
                    Row(
                      children: [
                        Icon(
                          Icons.phonelink_lock_outlined,
                          color: settings.biometricEnabled
                              ? AppColors.success(context)
                              : AppColors.textMuted(context),
                        ),
                        const SizedBox(width: AppSpacing.l),
                        Expanded(
                          child: Text(
                            'App Lock',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: settings.appLockEnabled,
                          onChanged: settings.biometricEnabled
                              ? (value) => context
                                    .read<SecuritySettingsCubit>()
                                    .setAppLockEnabled(value)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      settings.biometricEnabled
                          ? 'Requires biometric re-auth when the owner '
                                'console is resumed from the background '
                                'after a short idle period'
                          : 'Enable Biometric Unlock above first',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.x2l),
          _SectionLabel('DEVICES & SESSIONS'),
          const SizedBox(height: AppSpacing.m),
          BlocBuilder<OwnerSessionCubit, OwnerSessionState>(
            builder: (context, sessionState) {
              final devices = sessionState.sessions;
              return AppCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<OwnerSessionCubit>(),
                      child: const TrustedDevicesScreen(),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.laptop_mac_outlined,
                          color: AppColors.success(context),
                        ),
                        const SizedBox(width: AppSpacing.l),
                        Expanded(
                          child: Text(
                            'This device',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: 'Active',
                          color: AppColors.success(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _MetaRow(
                      label: 'Last sign-in',
                      value: lastSignIn != null
                          ? dateFormat.format(lastSignIn)
                          : 'Unknown',
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _MetaRow(
                      label: 'Account created',
                      value: createdAt != null
                          ? dateFormat.format(createdAt)
                          : 'Unknown',
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Icon(
                          Icons.devices_other_outlined,
                          size: 16,
                          color: AppColors.textMuted(context),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Text(
                            devices.isEmpty
                                ? 'Loading registered devices…'
                                : '${devices.length} device'
                                      '${devices.length == 1 ? '' : 's'} '
                                      'registered — tap to manage Trusted '
                                      'Devices',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted(context),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted(context),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.m),
          _ActionTile(
            icon: Icons.history_outlined,
            title: 'Sign-in History',
            subtitle: 'View recorded owner activity in Audit Logs',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          _SectionLabel('SUSPICIOUS ACTIVITY'),
          const SizedBox(height: AppSpacing.m),
          _SuspiciousActivityCard(ownerId: user?.uid),
          const SizedBox(height: AppSpacing.x3l),
          _SectionLabel('DANGER ZONE', color: AppColors.danger(context)),
          const SizedBox(height: AppSpacing.m),
          AppCard(
            borderColor: AppColors.danger(context).withValues(alpha: 0.3),
            showShadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revoke All Sessions',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Immediately revokes every active session for your owner '
                  'account on every device, then signs you out here too.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _revoking ? null : _confirmRevoke,
                    icon: _revoking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.logout_rounded,
                            color: AppColors.danger(context),
                          ),
                    label: Text(
                      'Revoke All Sessions',
                      style: TextStyle(color: AppColors.danger(context)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.danger(context)),
                    ),
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

/// Streams flagged owner sign-in events from `super_admin_sign_in_events`
/// (written by the `logOwnerSignIn` callable — see
/// public_functions/owner_sign_in_events.js for the simple IP/platform
/// heuristic used to set `suspicious`). Shows a real, honest list instead
/// of a fabricated "all clear" state; falls back to the same honest empty
/// state as before when there is nothing flagged yet.
class _SuspiciousActivityCard extends StatelessWidget {
  const _SuspiciousActivityCard({required this.ownerId});
  final String? ownerId;

  @override
  Widget build(BuildContext context) {
    final ownerId = this.ownerId;
    if (ownerId == null) return const SizedBox.shrink();

    final query = FirebaseFirestore.instance
        .collection('super_admin_sign_in_events')
        .where('ownerId', isEqualTo: ownerId)
        .where('suspicious', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(20);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppCard(
            showShadow: false,
            child: SizedBox(
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }
        if (docs.isEmpty) {
          return AppCard(
            showShadow: false,
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success(context),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Text(
                    'No suspicious activity flags recorded. Sign-ins whose '
                    'IP address or platform differ from the owner\'s '
                    'previous sign-in are flagged here automatically.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final dateFormat = DateFormat('MMM d, yyyy • HH:mm');
        return Column(
          children: [
            for (final doc in docs)
              AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                showShadow: false,
                borderColor: AppColors.warning(context).withValues(alpha: 0.3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning(context),
                    ),
                    const SizedBox(width: AppSpacing.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTimestamp(
                              doc.data()['timestamp'],
                              dateFormat,
                            ),
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Platform: ${doc.data()['platform'] ?? 'unknown'}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          if (doc.data()['reason'] != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              doc.data()['reason'] as String,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Object? value, DateFormat format) {
    if (value is Timestamp) return format.format(value.toDate());
    return 'Unknown time';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelSmall.copyWith(
        color: color ?? AppColors.textSecondary(context),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppColors.success(context)
        : AppColors.textMuted(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      onTap: enabled ? onTap : null,
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
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
                    color: enabled
                        ? AppColors.textPrimary(context)
                        : AppColors.textMuted(context),
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
          if (enabled)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
        ],
      ),
    );
  }
}
