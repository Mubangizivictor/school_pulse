import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/injection_container.dart';

class ActiveSessionsScreen extends StatelessWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    final lastSignIn = user?.metadata.lastSignInTime;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Active Sessions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                Icon(Icons.smartphone, color: AppColors.primary(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Device',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        lastSignIn != null
                            ? 'Signed in: ${lastSignIn.toLocal()}'
                            : 'Current session',
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: 'Active', color: AppColors.success(context)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: 0.5,
            child: IgnorePointer(
              child: SecondaryButton(
                label: 'Revoke Other Sessions (coming soon)',
                icon: Icons.block_outlined,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
