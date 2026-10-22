import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/dean_notification_preferences_screen.dart';

class DeanSettingsScreen extends StatelessWidget {
  const DeanSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.border(context)),
            ),
            child: const ThemeSwitchTile(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.border(context)),
            ),
            child: ListTile(
              leading: Icon(
                Icons.notifications_outlined,
                color: AppColors.primary(context),
              ),
              title: const Text('Notification Preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DeanNotificationPreferencesScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.danger(context)),
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: AppColors.danger(context),
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: AppColors.danger(context)),
              ),
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              Navigator.pop(dialogContext);
              context.go('/welcome');
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ),
        ],
      ),
    );
  }
}
