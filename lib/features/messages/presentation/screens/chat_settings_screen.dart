import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/chat_preferences.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  bool _enterIsSend = false;
  bool _mediaVisibility = true;
  bool _keepArchived = true;
  String _fontSize = 'Medium';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enterIsSend = prefs.getBool(ChatPreferences.enterIsSendKey) ?? false;
      _mediaVisibility =
          prefs.getBool(ChatPreferences.mediaVisibilityKey) ?? true;
      _keepArchived = prefs.getBool(ChatPreferences.keepArchivedKey) ?? true;
      _fontSize = prefs.getString(ChatPreferences.fontSizeKey) ?? 'Medium';
      _loaded = true;
    });
  }

  Future<void> _setBool(
    String key,
    bool value,
    void Function(bool) apply,
  ) async {
    setState(() => apply(value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Chat Settings',
          style: AppTypography.titleLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: !_loaded
          ? const Center(child: SchoolPulseLoader())
          : MessagingUserBuilder(
              builder: (context, user) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionHeader(context, 'Display'),
                  _buildSettingItem(
                    context,
                    title: 'Theme',
                    subtitle: 'System default',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colors.onSurfaceVariant,
                    ),
                    onTap: () => context.showMessagingSnack(
                      'Change the app theme from Settings › Appearance',
                    ),
                  ),
                  _buildSettingItem(
                    context,
                    title: 'Wallpaper',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colors.onSurfaceVariant,
                    ),
                    onTap: () => context.showMessagingSnack(
                      'Chat wallpapers are not available yet',
                    ),
                  ),
                  _buildSettingItem(
                    context,
                    title: 'Font size',
                    subtitle: _fontSize,
                    onTap: _showFontSizeDialog,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'Chat Settings'),
                  _buildSwitchItem(
                    context,
                    title: 'Enter is send',
                    subtitle: 'Enter key will send your message',
                    value: _enterIsSend,
                    onChanged: (val) => _setBool(
                      ChatPreferences.enterIsSendKey,
                      val,
                      (v) => _enterIsSend = v,
                    ),
                  ),
                  _buildSwitchItem(
                    context,
                    title: 'Media visibility',
                    subtitle:
                        'Show newly downloaded media in your phone\'s gallery',
                    value: _mediaVisibility,
                    onChanged: (val) => _setBool(
                      ChatPreferences.mediaVisibilityKey,
                      val,
                      (v) => _mediaVisibility = v,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'Archived Chats'),
                  _buildSwitchItem(
                    context,
                    title: 'Keep chats archived',
                    subtitle:
                        'Archived chats will remain archived when you receive a new message',
                    value: _keepArchived,
                    onChanged: (val) => _setBool(
                      ChatPreferences.keepArchivedKey,
                      val,
                      (v) => _keepArchived = v,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'History'),
                  _buildSettingItem(
                    context,
                    leading: Icon(
                      Icons.archive_outlined,
                      color: colors.onSurfaceVariant,
                    ),
                    title: 'Archive all chats',
                    onTap: () => _confirmBulkAction(
                      user,
                      title: 'Archive all chats?',
                      body:
                          'Every conversation moves to the Archived list. Nothing is deleted.',
                      confirmLabel: 'Archive all',
                      action: () => context.messages.archiveAllChats(user.id),
                      done: 'All chats archived',
                    ),
                  ),
                  _buildSettingItem(
                    context,
                    leading: Icon(
                      Icons.clear_all_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                    title: 'Clear all chats',
                    onTap: () => _confirmBulkAction(
                      user,
                      title: 'Clear all chats?',
                      body:
                          'Every conversation is removed from your inbox. Other participants keep their copy.',
                      confirmLabel: 'Clear all',
                      action: () => context.messages.deleteAllChats(user.id),
                      done: 'All chats cleared',
                    ),
                  ),
                  _buildSettingItem(
                    context,
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.black,
                    ),
                    title: 'Delete all chats',
                    titleColor: Colors.black,
                    onTap: () => _confirmBulkAction(
                      user,
                      title: 'Delete all chats?',
                      body:
                          'Every conversation is removed from your inbox and cannot be restored from this device.',
                      confirmLabel: 'Delete all',
                      destructive: true,
                      action: () => context.messages.deleteAllChats(user.id),
                      done: 'All chats deleted',
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Future<void> _confirmBulkAction(
    UserEntity user, {
    required String title,
    required String body,
    required String confirmLabel,
    required Future<void> Function() action,
    required String done,
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmLabel,
              style: TextStyle(color: destructive ? Colors.black : null),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await action();
      if (!mounted) return;
      context.showMessagingSnack(done);
    } catch (e) {
      if (!mounted) return;
      context.showMessagingSnack('Failed: $e');
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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

  Widget _buildSettingItem(
    BuildContext context, {
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
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            color: titleColor ?? Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.electricBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(
          dialogContext,
        ).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Font size',
          style: AppTypography.titleLarge.copyWith(
            color: Theme.of(dialogContext).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ChatPreferences.fontSizes.map((size) {
            return ListTile(
              title: Text(
                size,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.onSurface,
                ),
              ),
              trailing: _fontSize == size
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.electricBlue,
                    )
                  : null,
              onTap: () async {
                Navigator.pop(dialogContext);
                setState(() => _fontSize = size);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(ChatPreferences.fontSizeKey, size);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
