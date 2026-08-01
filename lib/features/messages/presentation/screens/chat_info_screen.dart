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
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricBlue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'P7',
                          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppColors.bgDark : Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                Text('P7 - Parents Group', style: AppTypography.headlineSmall),
                const SizedBox(height: 4),
                Text('Group • 32 members', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted(context))),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(icon: Icons.add_moderator_outlined, label: 'Manage', onTap: () {}),
                _ActionButton(icon: Icons.person_add_outlined, label: 'Add', onTap: () {}),
                _ActionButton(icon: Icons.search, label: 'Search', onTap: () {}),
                _ActionButton(icon: Icons.notifications_off_outlined, label: 'Mute', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildInfoSection(context, [
            _buildInfoTile(context, Icons.info_outline, 'Description', 'Official communication group for P7 parents'),
            _buildInfoTile(context, Icons.perm_media_outlined, 'Media, Links & Docs', '242 items', 
              onTap: () => context.push('/messages/chat/$chatId/media')),
            _buildInfoTile(context, Icons.star_border, 'Starred Messages', '12', 
              onTap: () => context.push('/messages/starred')),
          ]),
          _buildInfoSection(context, [
            _buildInfoTile(context, Icons.notifications_none, 'Notifications', 'Custom', showChevron: true),
            _buildInfoTile(context, Icons.lock_outline, 'Encryption', 'Messages are end-to-end encrypted'),
          ]),
          _buildSectionHeader(context, '32 MEMBERS'),
          _buildMemberTile(context, 'Mrs. Amina', 'Admin', isMe: true),
          _buildMemberTile(context, 'Mr. Kofi Mensah', 'Teacher'),
          _buildMemberTile(context, 'Sarah Johnson', 'Parent'),
          const SizedBox(height: AppSpacing.xl),
          _buildDangerTile(Icons.exit_to_app, 'Exit Group'),
          _buildDangerTile(Icons.report_gmailerrorred, 'Report Group'),
          const SizedBox(height: AppSpacing.x3l),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, List<Widget> children) {
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xl, top: AppSpacing.l, bottom: AppSpacing.s),
      child: Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context), letterSpacing: 1)),
    );
  }

  Widget _buildMemberTile(BuildContext context, String name, String role, {bool isMe = false}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
        child: Text(name[0], style: const TextStyle(color: AppColors.electricBlue)),
      ),
      title: Text(isMe ? '$name (You)' : name, style: AppTypography.titleSmall),
      subtitle: Text(role, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context))),
      trailing: role == 'Admin' 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.emeraldGreen),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Admin', style: TextStyle(color: AppColors.emeraldGreen, fontSize: 10)),
          )
        : null,
    );
  }

  Widget _buildDangerTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(label, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
      onTap: () {},
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value, {VoidCallback? onTap, bool showChevron = true}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.electricBlue, size: 22),
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(value, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context))),
      trailing: showChevron ? const Icon(Icons.chevron_right, size: 20) : null,
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
