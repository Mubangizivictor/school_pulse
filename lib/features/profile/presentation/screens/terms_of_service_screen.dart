import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Pulse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 2.1.0',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'School Pulse is a comprehensive school management system '
              'designed to make teaching and learning more effective. By '
              'using this app, staff, parents, and students agree to use '
              'the platform responsibly, keep their account credentials '
              'confidential, and respect the privacy of student and staff '
              'data accessed through it.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary(context),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data submitted through the app - including attendance, '
              'academic records, and communications - is used solely for '
              'the operation of the school and is not shared with third '
              'parties beyond what is necessary to deliver these services.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary(context),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Continued use of School Pulse constitutes acceptance of '
              'these terms and any future updates to them.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary(context),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
