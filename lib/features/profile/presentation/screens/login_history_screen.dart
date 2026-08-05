import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Login History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const EmptyState(
        icon: Icons.history,
        title: 'No login history yet',
        message:
            'Detailed login history will appear here once audit logging '
            'is available.',
      ),
    );
  }
}
