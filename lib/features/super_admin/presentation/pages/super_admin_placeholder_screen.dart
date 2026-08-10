import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/app_components.dart';

/// Honest "coming in a later phase" placeholder for owner console sections
/// that genuinely don't have a backing screen yet (Notifications, Settings).
/// No fake data, no dead buttons — just a clear message.
class SuperAdminPlaceholderScreen extends StatelessWidget {
  const SuperAdminPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.message = 'Coming in a later phase.',
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(icon: icon, title: title, message: message),
    );
  }
}
