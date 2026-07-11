import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';

class PlatformBlockedScreen extends StatelessWidget {
  final UserRole role;

  const PlatformBlockedScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phonelink_erase, size: 80, color: Theme.of(context).extension<SemanticColors>()?.errorRed),
              const SizedBox(height: 24),
              Text(
                "Not available on this device",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                PlatformAccess.getBlockedMessage(role),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                label: 'Back to Login',
                onPressed: () => context.go('/welcome'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
