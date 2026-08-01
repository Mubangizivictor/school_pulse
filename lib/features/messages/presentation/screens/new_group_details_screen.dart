import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class NewGroupDetailsScreen extends StatefulWidget {
  const NewGroupDetailsScreen({super.key});

  @override
  State<NewGroupDetailsScreen> createState() => _NewGroupDetailsScreenState();
}

class _NewGroupDetailsScreenState extends State<NewGroupDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceContainerHigh(context) : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.electricBlue),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.electricBlue,
                      child: Icon(Icons.add, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Add Group Photo', style: AppTypography.labelMedium.copyWith(color: AppColors.electricBlue)),
            const SizedBox(height: AppSpacing.x2l),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'P7 - Mathematics Parents',
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'This group is for all P7 parents to discuss Mathematics updates and homework.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            _buildSettingTile(Icons.person_add_outlined, 'Add Members', '15 selected', onTap: () => context.pop()),
            _buildSettingTile(Icons.public, 'Group Type', 'Private Group', onTap: () {}),
            _buildSettingTile(Icons.admin_panel_settings_outlined, 'Who can send messages?', 'All Members', onTap: () {}),
            const SizedBox(height: AppSpacing.x3l),
            ElevatedButton(
              onPressed: () => context.go('/messages'),
              child: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String value, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textMuted(context)),
      title: Text(title, style: AppTypography.titleSmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTypography.bodySmall.copyWith(color: AppColors.electricBlue)),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
