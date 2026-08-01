import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherAboutScreen extends StatelessWidget {
  const TeacherAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('About School Pulse'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'School Pulse',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Class Teacher App',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary(context),
              ),
            ),
            Text(
              'Version 2.1.0',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted(context),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'School Pulse is a comprehensive school management system designed to make teaching and learning more effective.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _AboutTile(icon: Icons.new_releases_outlined, title: "What's New", onTap: () {}),
                  _AboutTile(icon: Icons.gavel_outlined, title: 'Terms of Use', onTap: () {}),
                  _AboutTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () {}),
                  _AboutTile(icon: Icons.badge_outlined, title: 'Licenses', onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AboutTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.textPrimary(context), size: 22),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: onTap,
          dense: true,
        ),
        Divider(
          height: 1,
          indent: 56,
          endIndent: 16,
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
