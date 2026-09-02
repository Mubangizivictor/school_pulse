import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_push_token_service.dart';

Future<void> handleSuperAdminLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    // A visible scrim keeps the confirmation focused and separates it from
    // the settings page behind it, especially in the dark theme.
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (dialogContext) => const _LogoutConfirmationDialog(),
  );
  if (confirmed == true && context.mounted) {
    // Wipe the owner-only notification cache + offline queue before the auth
    // state tears down, so nothing owner-scoped is left on the device for
    // the next account (account switch / role loss / session revocation all
    // funnel through here).
    await OwnerNotificationService().clearOfflineState();
    // Also drop this device's owner FCM token so a former-owner device
    // stops receiving owner push.
    await OwnerPushTokenService().unregisterCurrentDevice();
    if (!context.mounted) return;
    context.read<AuthBloc>().add(LogoutPressed());
    context.go('/welcome');
  }
}

class _LogoutConfirmationDialog extends StatelessWidget {
  const _LogoutConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    final danger = AppColors.danger(context);
    final primary = AppColors.primary(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.dangerSurface(context),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, color: danger, size: 29),
            ),
            const SizedBox(height: 18),
            Text(
              'Log out?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'You will need to sign in again to access your School Pulse owner account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: AppColors.border(context)),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Stay signed in',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: danger,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SuperAdminLogoutButton extends StatelessWidget {
  const SuperAdminLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: 'Logout',
      onPressed: () => handleSuperAdminLogout(context),
    );
  }
}
