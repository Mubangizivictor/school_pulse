import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// Foundation setup wizard for Structure: review what's configured so far,
/// validate the minimum required for the institution to operate, then mark
/// setup complete. Deliberately shallow - Phase 2 scope, not a full
/// 13-step generic template/hierarchy wizard.
class StructureSetupWizardScreen extends StatefulWidget {
  const StructureSetupWizardScreen({super.key});

  @override
  State<StructureSetupWizardScreen> createState() =>
      _StructureSetupWizardScreenState();
}

class _StructureSetupWizardScreenState
    extends State<StructureSetupWizardScreen> {
  int _currentStep = 0;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<StructureBloc>().add(LoadStructureData(schoolId));
  }

  List<String> _validationIssues(StructureState state) {
    final issues = <String>[];
    if (state.levels.where((l) => l.isActive).isEmpty) {
      issues.add('At least one active Educational Level is required.');
    }
    if (state.academicYears.where((y) => !y.isArchived).isEmpty) {
      issues.add('At least one active Academic Year is required.');
    }
    return issues;
  }

  Future<void> _activate(String schoolId) async {
    setState(() => _isActivating = true);
    final firestore = di.sl<FirebaseFirestore>();
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('config')
        .doc('structure_setup')
        .set({
          'structureSetupComplete': true,
          'completedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    if (!mounted) return;
    setState(() => _isActivating = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final issues = _validationIssues(state);
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AdminAppBar(
            title: 'Structure Setup Wizard',
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              _buildStepIndicator(context),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildReviewStep(context, state),
                    _buildValidationStep(context, issues),
                    _buildActivationStep(context),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, schoolId, issues),
        );
      },
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.l,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
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

  Widget _buildReviewStep(BuildContext context, StructureState state) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(
          'Review Your Structure',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure all core components are correctly configured before activating the module.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildReviewCard(
          context: context,
          title: 'Academic Structure',
          icon: Icons.school_outlined,
          color: Colors.blue,
          items: [
            '${state.levels.length} Level(s)',
            '${state.classes.length} Class(es)',
            '${state.subjects.length} Subject(s)',
            '${state.academicYears.length} Academic Year(s)',
          ],
          isComplete: state.levels.isNotEmpty && state.academicYears.isNotEmpty,
        ),
        _buildReviewCard(
          context: context,
          title: 'People & Org',
          icon: Icons.groups_outlined,
          color: Colors.orange,
          items: [
            '${state.departments.length} Department(s)',
            '${state.designations.length} Staff Role(s)',
          ],
          isComplete: state.departments.isNotEmpty,
        ),
        _buildReviewCard(
          context: context,
          title: 'Campus & Facilities',
          icon: Icons.location_city_outlined,
          color: Colors.teal,
          items: [
            '${state.campuses.length} Campus(es)',
            '${state.houses.length} House(s)',
            '${state.hostels.length} Hostel(s)',
            '${state.transportRoutes.length} Transport Route(s)',
          ],
          isComplete: true, // fully optional - never blocks activation
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    required bool isComplete,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderColor: Theme.of(context).colorScheme.outline,
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
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: items
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Icon(
            isComplete ? Icons.check_circle : Icons.error_outline,
            color: isComplete ? Colors.green : Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStep(BuildContext context, List<String> issues) {
    if (issues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, size: 80, color: Colors.blue),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Validation Successful',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No conflicts or missing requirements found.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const Icon(
          Icons.warning_amber_outlined,
          size: 60,
          color: Colors.orange,
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Structure Isn\'t Ready Yet',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        ...issues.map(
          (issue) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 6,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    issue,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivationStep(BuildContext context) {
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
            child: const Icon(
              Icons.rocket_launch_outlined,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Ready to Activate!',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Activating will make this structure live for all modules. Future changes will be tracked.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    String schoolId,
    List<String> issues,
  ) {
    final canAdvancePastValidation = issues.isEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.m,
        AppSpacing.xl,
        AppSpacing.m + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.m),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isActivating
                  ? null
                  : () {
                      if (_currentStep == 1 && !canAdvancePastValidation) {
                        return;
                      }
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _activate(schoolId);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isActivating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      _currentStep == 2 ? 'Activate Module' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
  const _StepCircle({
    required this.index,
    required this.label,
    required this.isActive,
  });

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
            color: isActive
                ? AppColors.primary(context)
                : Theme.of(context).colorScheme.surfaceContainer,
            border: Border.all(
              color: isActive
                  ? AppColors.primary(context)
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Center(
            child: Text(
              index.toString(),
              style: TextStyle(
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
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
            color: isActive
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: isActive
            ? AppColors.primary(context)
            : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
