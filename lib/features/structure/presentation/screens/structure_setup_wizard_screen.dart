import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../widgets/structure_ui_kit.dart';

class StructureSetupWizardScreen extends StatefulWidget {
  const StructureSetupWizardScreen({super.key});

  @override
  State<StructureSetupWizardScreen> createState() => _StructureSetupWizardScreenState();
}

class _StructureSetupWizardScreenState extends State<StructureSetupWizardScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Structure Setup Wizard'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildReviewStep(),
                _buildValidationStep(),
                _buildActivationStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.l, horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context).withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          _StepCircle(index: 1, label: 'Review', isActive: _currentStep >= 0),
          _StepLine(isActive: _currentStep >= 1),
          _StepCircle(index: 2, label: 'Validate', isActive: _currentStep >= 1),
          _StepLine(isActive: _currentStep >= 2),
          _StepCircle(index: 3, label: 'Activate', isActive: _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        const Text(
          'Review Your Structure',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure all core components are correctly configured before activating the module.',
          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildReviewCard(
          title: 'Academic Structure',
          icon: Icons.school_outlined,
          color: Colors.blue,
          items: ['3 Educational Levels', '12 Classes', '42 Subjects'],
        ),
        _buildReviewCard(
          title: 'People & Org',
          icon: Icons.groups_outlined,
          color: Colors.orange,
          items: ['8 Departments', '15 Staff Roles'],
        ),
        _buildReviewCard(
          title: 'Campus & Facilities',
          icon: Icons.location_city_outlined,
          color: Colors.teal,
          items: ['4 Houses', '2 Hostels', '5 Transport Routes'],
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      color: AppColors.surfaceElevated(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: items.map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item, style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context))),
                  )).toList(),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildValidationStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user_outlined, size: 80, color: Colors.blue),
          const SizedBox(height: AppSpacing.xl),
          const Text('Validation Successful', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            'No conflicts or missing requirements found.',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivationStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rocket_launch_outlined, size: 60, color: Colors.green),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Ready to Activate!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
          const SizedBox(height: 12),
          Text(
            'Activating will make this structure live for all modules. Future changes will be tracked.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.m + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(top: BorderSide(color: AppColors.border(context).withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.m),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(_currentStep == 2 ? 'Activate Module' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  const _StepCircle({required this.index, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary(context) : AppColors.background(context),
            border: Border.all(color: isActive ? AppColors.primary(context) : AppColors.border(context)),
          ),
          child: Center(
            child: Text(
              index.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary(context),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.textPrimary(context) : AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;
  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isActive ? AppColors.primary(context) : AppColors.border(context).withValues(alpha: 0.5),
      ),
    );
  }
}
