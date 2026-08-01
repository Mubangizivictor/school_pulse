import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class ContactProfileScreen extends StatelessWidget {
  final String contactId;
  const ContactProfileScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            const Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  SizedBox(height: AppSpacing.m),
                  Text('Mr. Kofi Mensah', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Science Teacher', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(icon: Icons.message_outlined, label: 'Message'),
                _ActionButton(icon: Icons.phone_outlined, label: 'Audio'),
                _ActionButton(icon: Icons.videocam_outlined, label: 'Video'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            _buildInfoItem('Phone', '+233 24 123 4567'),
            _buildInfoItem('Email', 'kofi.mensah@school.edu.gh'),
            _buildInfoItem('Department', 'Science Department'),
            _buildInfoItem('Role', 'Teacher'),
            const Divider(),
            ListTile(
              title: const Text('View Groups in Common'),
              subtitle: const Text('P7 - Parents Group, Science Dept.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text('Block Contact', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Report Contact', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.electricBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.electricBlue),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.electricBlue)),
      ],
    );
  }
}
