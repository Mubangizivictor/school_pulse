import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../domain/entities/owner_session.dart';
import '../bloc/owner_session_cubit.dart';

/// SaaS Owner Settings > Security > Trusted Devices.
///
/// Reads the real Firestore-backed device/session registry
/// (`super_admin_settings/{ownerId}/sessions`) via [OwnerSessionCubit] -
/// no fabricated device list. The current device is flagged and cannot be
/// removed from here (that's what "Sign Out This Device" in Security
/// Settings is for); other devices can be trusted/untrusted or removed
/// (revoking their trust and dropping them from the registry) with a
/// confirmation dialog before the destructive removal.
class TrustedDevicesScreen extends StatelessWidget {
  const TrustedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Devices'),
        leading: const BackButton(),
      ),
      body: BlocBuilder<OwnerSessionCubit, OwnerSessionState>(
        builder: (context, state) {
          if (state.status == OwnerSessionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x2l),
                child: Text(
                  'No devices registered yet.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: state.sessions.length,
            itemBuilder: (context, index) {
              final session = state.sessions[index];
              final isCurrent = session.deviceId == state.currentDeviceId;
              return _DeviceCard(session: session, isCurrent: isCurrent);
            },
          );
        },
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.session, required this.isCurrent});

  final OwnerSession session;
  final bool isCurrent;

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Remove this device?',
      message:
          '"${session.deviceName}" will be removed from your trusted '
          'device list. If it is still signed in, its session is not '
          'force-revoked (this app has no server-side session kill '
          'switch), but it will no longer appear here as trusted.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      await context.read<OwnerSessionCubit>().removeSession(session.deviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                session.platform.toLowerCase().contains('ios')
                    ? Icons.phone_iphone_rounded
                    : session.platform.toLowerCase().contains('android')
                    ? Icons.phone_android_rounded
                    : Icons.devices_other_outlined,
                color: AppColors.success(context),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.deviceName,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      session.platform,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                StatusBadge(
                  label: 'This device',
                  color: AppColors.primary(context),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (session.lastActiveAt != null)
            Text(
              'Last active ${dateFormat.format(session.lastActiveAt!)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      session.trusted
                          ? Icons.verified_user_rounded
                          : Icons.gpp_maybe_outlined,
                      size: 18,
                      color: session.trusted
                          ? AppColors.success(context)
                          : AppColors.textMuted(context),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      session.trusted ? 'Trusted' : 'Not trusted',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: session.trusted,
                onChanged: (value) => context
                    .read<OwnerSessionCubit>()
                    .setTrusted(session.deviceId, value),
              ),
              if (!isCurrent)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger(context),
                  ),
                  onPressed: () => _confirmRemove(context),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
