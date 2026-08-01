import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  bool _enterIsSend = false;
  bool _mediaVisibility = true;
  String _fontSize = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'Chat Settings',
          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSectionHeader('Display'),
          _buildSettingItem(
            title: 'Theme',
            subtitle: 'System default',
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () {},
          ),
          _buildSettingItem(
            title: 'Wallpaper',
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () {},
          ),
          _buildSettingItem(
            title: 'Font size',
            subtitle: _fontSize,
            onTap: () => _showFontSizeDialog(),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Chat Settings'),
          _buildSwitchItem(
            title: 'Enter is send',
            subtitle: 'Enter key will send your message',
            value: _enterIsSend,
            onChanged: (val) => setState(() => _enterIsSend = val),
          ),
          _buildSwitchItem(
            title: 'Media visibility',
            subtitle: 'Show newly downloaded media in your phone\'s gallery',
            value: _mediaVisibility,
            onChanged: (val) => setState(() => _mediaVisibility = val),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Archived Chats'),
          _buildSwitchItem(
            title: 'Keep chats archived',
            subtitle: 'Archived chats will remain archived when you receive a new message',
            value: true,
            onChanged: (v) {},
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('History'),
          _buildSettingItem(
            leading: const Icon(Icons.archive_outlined, color: Colors.white70),
            title: 'Archive all chats',
            onTap: () {},
          ),
          _buildSettingItem(
            leading: const Icon(Icons.clear_all_rounded, color: Colors.white70),
            title: 'Clear all chats',
            onTap: () {},
          ),
          _buildSettingItem(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            title: 'Delete all chats',
            titleColor: Colors.redAccent,
            onTap: () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, AppSpacing.l, 8, AppSpacing.s),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.electricBlue,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            color: titleColor ?? Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(color: Colors.white60),
              )
            : null,
        trailing: trailing,
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(color: Colors.white60),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.electricBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Font size', style: AppTypography.titleLarge.copyWith(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Small', 'Medium', 'Large'].map((size) {
            return RadioListTile<String>(
              title: Text(size, style: const TextStyle(color: Colors.white)),
              value: size,
              groupValue: _fontSize,
              activeColor: AppColors.electricBlue,
              onChanged: (val) {
                setState(() => _fontSize = val!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
