import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class ContactProfileScreen extends StatelessWidget {
  final String contactId;
  const ContactProfileScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(Icons.more_vert, color: AppColors.textPrimary(context)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 60, color: AppColors.electricBlue),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text('Mr. Kofi Mensah', style: AppTypography.headlineSmall),
                  Text('Science Teacher • Senior High', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted(context))),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(icon: Icons.message_outlined, label: 'Message'),
                  _ActionButton(icon: Icons.phone_outlined, label: 'Call'),
                  _ActionButton(icon: Icons.videocam_outlined, label: 'Video'),
                  _ActionButton(icon: Icons.share_outlined, label: 'Share'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildSection(context, [
              _buildDetailItem(context, 'Phone', '+233 24 123 4567', Icons.phone_android_outlined),
              _buildDetailItem(context, 'Email', 'kofi.mensah@school.edu.gh', Icons.email_outlined),
              _buildDetailItem(context, 'Department', 'Science & Mathematics', Icons.business_outlined),
            ]),
            _buildSection(context, [
              _buildDetailItem(context, 'Groups in Common', 'P7 - Parents Group, Science Dept.', Icons.group_outlined, showChevron: true),
              _buildDetailItem(context, 'Starred Messages', '15 messages', Icons.star_border_outlined, showChevron: true),
            ]),
            const SizedBox(height: AppSpacing.l),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Column(
                children: [
                  _buildActionRow(Icons.block, 'Block Mr. Kofi Mensah', Colors.red),
                  _buildActionRow(Icons.report_gmailerrorred, 'Report Contact', Colors.red),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon, {bool showChevron = false}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.electricBlue, size: 20),
      title: Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
      subtitle: Text(value, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
      trailing: showChevron ? const Icon(Icons.chevron_right, size: 20) : null,
      onTap: () {},
    );
  }

  Widget _buildActionRow(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: () {},
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
