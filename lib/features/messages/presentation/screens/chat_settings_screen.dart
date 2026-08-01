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
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text('Chat Settings', style: AppTypography.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Display'),
          ListTile(
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Wallpaper'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Font size'),
            subtitle: Text(_fontSize),
            onTap: () => _showFontSizeDialog(),
          ),
          const Divider(),
          _buildSectionHeader('Chat Settings'),
          SwitchListTile(
            title: const Text('Enter is send'),
            subtitle: const Text('Enter key will send your message'),
            value: _enterIsSend,
            onChanged: (val) => setState(() => _enterIsSend = val),
            activeColor: AppColors.royalBlue,
          ),
          SwitchListTile(
            title: const Text('Media visibility'),
            subtitle: const Text('Show newly downloaded media in your phone\'s gallery'),
            value: _mediaVisibility,
            onChanged: (val) => setState(() => _mediaVisibility = val),
            activeColor: AppColors.royalBlue,
          ),
          const Divider(),
          _buildSectionHeader('Archived Chats'),
          ListTile(
            title: const Text('Keep chats archived'),
            subtitle: const Text('Archived chats will remain archived when you receive a new message'),
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeColor: AppColors.royalBlue,
            ),
          ),
          const Divider(),
          _buildSectionHeader('History'),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Archive all chats'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.clear_all_rounded),
            title: const Text('Clear all chats'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.deepOrange),
            title: const Text('Delete all chats', style: TextStyle(color: AppColors.deepOrange)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.s),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.royalBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Small', 'Medium', 'Large'].map((size) {
            return RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: _fontSize,
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
