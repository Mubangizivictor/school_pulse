import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class SelectContactsScreen extends StatefulWidget {
  final bool isGroupSelection;
  const SelectContactsScreen({super.key, this.isGroupSelection = false});

  @override
  State<SelectContactsScreen> createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends State<SelectContactsScreen> {
  final List<String> _selectedIds = [];
  final List<Map<String, String>> _contacts = [
    {'id': '1', 'name': 'Mr. Kofi Mensah', 'role': 'Science Teacher', 'avatar': 'KM'},
    {'id': '2', 'name': 'Mrs. Amina', 'role': 'Class Teacher - P7', 'avatar': 'AM'},
    {'id': '3', 'name': 'Finance Office', 'role': 'School Department', 'avatar': 'FO'},
    {'id': '4', 'name': 'Nurse Office', 'role': 'School Health', 'avatar': 'NO'},
    {'id': '5', 'name': 'School Admin', 'role': 'Administrator', 'avatar': 'SA'},
    {'id': '6', 'name': 'Mr. Boateng', 'role': 'Parent', 'avatar': 'MB'},
    {'id': '7', 'name': 'Abena Owusu', 'role': 'Parent', 'avatar': 'AO'},
    {'id': '8', 'name': 'David Evans', 'role': 'Teacher', 'avatar': 'DE'},
  ];

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isGroupSelection ? 'Add Members' : 'New Chat', style: AppTypography.titleLarge),
            Text('${_selectedIds.length} of ${_contacts.length} selected', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.search, color: AppColors.textPrimary(context)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          if (widget.isGroupSelection && _selectedIds.isNotEmpty) ...[
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                itemCount: _selectedIds.length,
                itemBuilder: (context, index) {
                  final contact = _contacts.firstWhere((c) => c['id'] == _selectedIds[index]);
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: AppSpacing.s),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.electricBlue, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
                                child: Text(contact['avatar']!, style: const TextStyle(color: AppColors.electricBlue, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedIds.remove(contact['id'])),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(contact['name']!.split(' ').first, 
                          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),
          ],
          Expanded(
            child: ListView(
              children: [
                _buildSectionHeader('FREQUENTLY CONTACTED'),
                ..._contacts.take(3).map((c) => _buildContactTile(c)),
                _buildSectionHeader('ALL CONTACTS'),
                ..._contacts.skip(3).map((c) => _buildContactTile(c)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty ? null : () {
                  if (widget.isGroupSelection) {
                    context.push('/messages/new/group/details');
                  } else {
                    context.push('/messages/chat/${_selectedIds.first}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.disabled(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  widget.isGroupSelection ? 'Continue' : 'Start Chat', 
                  style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.s),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildContactTile(Map<String, String> contact) {
    final isSelected = _selectedIds.contains(contact['id']);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.electricBlue, width: 1) : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
          child: Text(
            contact['avatar']!,
            style: const TextStyle(
              color: AppColors.electricBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact['name']!,
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          contact['role']!,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.electricBlue : Colors.grey.withValues(alpha: 0.3),
              width: 2,
            ),
            color: isSelected ? AppColors.electricBlue : Colors.transparent,
          ),
          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(contact['id']);
            } else {
              if (!widget.isGroupSelection) {
                _selectedIds.clear();
              }
              _selectedIds.add(contact['id']!);
            }
          });
        },
      ),
    );
  }
}
