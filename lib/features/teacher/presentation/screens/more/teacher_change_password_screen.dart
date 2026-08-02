import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';

class TeacherChangePasswordScreen extends StatelessWidget {
  const TeacherChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const PulseTextField(
              hint: 'Enter current password',
              isPassword: true,
              prefixIcon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: 20),
            const Text(
              'New Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const PulseTextField(
              hint: 'Enter new password',
              isPassword: true,
              prefixIcon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: 20),
            const Text(
              'Confirm New Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const PulseTextField(
              hint: 'Confirm new password',
              isPassword: true,
              prefixIcon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: 24),
            _buildComplexityHint('Minimum 8 characters'),
            _buildComplexityHint('Include numbers and letters'),
            _buildComplexityHint('Include special characters'),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Update Password',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexityHint(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            hint,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
