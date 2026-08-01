import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme.dart';

class ReportsGeneratedSuccessScreen extends StatelessWidget {
  const ReportsGeneratedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: SemanticColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: SemanticColors.success,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Reports Generated!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '32 report cards for Primary 2 Gold have been successfully generated and are ready for distribution.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              AppCard(
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.share_outlined,
                      title: 'Share with Parents',
                      subtitle: 'Send reports via email and app notifications',
                      onTap: () {},
                    ),
                    const Divider(),
                    _ActionTile(
                      icon: Icons.print_outlined,
                      title: 'Print All Reports',
                      subtitle: 'Generate a single PDF for printing',
                      onTap: () {},
                    ),
                    const Divider(),
                    _ActionTile(
                      icon: Icons.folder_open_outlined,
                      title: 'View in Archive',
                      subtitle: 'Access saved reports in the school portal',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Back to Dashboard',
                onPressed: () => context.go('/teacher/reports'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: SemanticColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
