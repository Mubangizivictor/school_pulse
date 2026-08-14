import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'How can we help you?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Common Topics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'In-app help articles aren\'t available yet - mention a topic '
            'below when you contact support and we\'ll help directly.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                _SupportTopic(
                  icon: Icons.lightbulb_outline,
                  title: 'Getting Started',
                ),
                _SupportTopic(
                  icon: Icons.speed_rounded,
                  title: 'Using Class Performance',
                ),
                _SupportTopic(
                  icon: Icons.checklist_rtl_rounded,
                  title: 'Taking Attendance',
                ),
                _SupportTopic(
                  icon: Icons.edit_note_rounded,
                  title: 'Entering Marks',
                ),
                _SupportTopic(
                  icon: Icons.assignment_outlined,
                  title: 'Creating Homework',
                ),
                _SupportTopic(
                  icon: Icons.bar_chart_rounded,
                  title: 'Generating Reports',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Contact Support',
            icon: Icons.headset_mic_outlined,
            onPressed: () => launchUrl(
              Uri.parse(
                'mailto:support@schoolpulse.app?subject=School%20Pulse%20Support',
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SupportTopic extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLast;

  const _SupportTopic({
    required this.icon,
    required this.title,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary(context), size: 22),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          dense: true,
        ),
        if (!isLast)
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
