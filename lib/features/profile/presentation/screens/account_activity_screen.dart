import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/injection_container.dart';

class AccountActivityScreen extends StatelessWidget {
  const AccountActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    final lastSignIn = user?.metadata.lastSignInTime;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Account Activity'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.login, color: AppColors.primary(context)),
              title: Text(
                'Last Sign-In',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              subtitle: Text(
                lastSignIn != null ? '${lastSignIn.toLocal()}' : 'Unknown',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const EmptyState(
            icon: Icons.query_stats_outlined,
            title: 'No aggregated activity yet',
            message:
                'A full activity timeline will appear here once server-side '
                'audit logging is available.',
          ),
        ],
      ),
    );
  }
}
