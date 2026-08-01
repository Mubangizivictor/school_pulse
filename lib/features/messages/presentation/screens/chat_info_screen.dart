import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class ChatInfoScreen extends StatelessWidget {
  final String chatId;
  const ChatInfoScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.electricBlue,
                  child: Text('P7', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: AppSpacing.m),
                Text('P7 - Parents Group', style: AppTypography.headlineSmall),
                Text('32 members', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted(context))),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(icon: Icons.phone_outlined, label: 'Audio', onTap: () {}),
              _ActionButton(icon: Icons.videocam_outlined, label: 'Video', onTap: () {}),
              _ActionButton(icon: Icons.person_add_outlined, label: 'Add', onTap: () {}),
              _ActionButton(icon: Icons.search, label: 'Search', onTap: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          _buildSectionHeader(context, 'Description'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(
              'Official communication group for all P7 parents and class teacher.',
              style: AppTypography.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          const Divider(),
          _buildInfoTile(context, Icons.perm_media_outlined, 'Media, Links & Docs', '242', onTap: () => context.push('/messages/chat/\$chatId/media')),
          _buildInfoTile(context, Icons.star_border, 'Starred Messages', '12', onTap: () => context.push('/messages/starred')),
          _buildInfoTile(context, Icons.push_pin_outlined, 'Pinned Messages', '3', onTap: () => context.push('/messages/pinned')),
          const Divider(),
          _buildInfoTile(context, Icons.group_outlined, 'Members', '32', onTap: () {}),
          _buildInfoTile(context, Icons.notifications_none, 'Notifications', 'On', onTap: () {}),
          _buildInfoTile(context, Icons.visibility_outlined, 'Media Visibility', 'All', onTap: () {}),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Exit Group', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.x3l),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Text(title, style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted(context))),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted(context)),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context))),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}
