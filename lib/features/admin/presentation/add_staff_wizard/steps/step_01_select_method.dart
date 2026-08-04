import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';

class Step01SelectMethod extends StatelessWidget {
  const Step01SelectMethod({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AddStaffWizardController>();
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Add Staff Member'),
        elevation: 0,
        backgroundColor: AppColors.background(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2 of 10',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How would you like to add staff?',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Choose the method of adding staff',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            _MethodCard(
              icon: Icons.person_add_alt_1,
              title: 'Add New Staff',
              subtitle: 'Create a new staff member',
              selected: true,
              onTap: () => controller.next(),
            ),
            const SizedBox(height: 12),
            _MethodCard(
              icon: Icons.file_upload_outlined,
              title: 'Import Staff',
              subtitle: 'Import from Excel or CSV file',
              enabled: false,
            ),
            const SizedBox(height: 12),
            _MethodCard(
              icon: Icons.restore,
              title: 'Rehire Former Staff',
              subtitle: 'Rehire a previously employed staff',
              enabled: false,
            ),
            const SizedBox(height: 16),
            AlertBanner(
              title: 'Only School Admin can add staff members',
              message: 'Import and Rehire are coming soon.',
              color: AppColors.warning(context),
              icon: Icons.info_outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: AppCard(
        onTap: enabled ? onTap : null,
        borderColor: selected ? AppColors.electricBlue : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.electricBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.electricBlue)
            else if (!enabled)
              StatusBadge(label: 'Soon', color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }
}
