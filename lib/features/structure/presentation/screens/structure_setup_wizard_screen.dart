import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
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
  State<StructureSetupWizardScreen> createState() => _StructureSetupWizardScreenState();
}

class _StructureSetupWizardScreenState extends State<StructureSetupWizardScreen> {
  int _currentStep = 0;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    final schoolId = (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
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
    final schoolId = (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final issues = _validationIssues(state);
        return Scaffold(
          backgroundColor: const Color(0xFF020716),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Structure Setup Wizard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
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
                    _buildReviewStep(state),
                    _buildValidationStep(issues),
                    _buildActivationStep(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(schoolId, issues),
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.l, horizontal: AppSpacing.xl),
      decoration: const BoxDecoration(
        color: Color(0xFF071229),
        border: Border(bottom: BorderSide(color: Color(0xFF1A315B))),
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

  Widget _buildReviewStep(StructureState state) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const Text(
          'Review Your Structure',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ensure all core components are correctly configured before activating the module.',
          style: TextStyle(color: Color(0xFF8190AA), fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildReviewCard(
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
          title: 'People & Org',
          icon: Icons.groups_outlined,
          color: Colors.orange,
          items: [
            '${state.departments.length} Department(s)',
            '${state.staffRoles.length} Staff Role(s)',
          ],
          isComplete: state.departments.isNotEmpty,
        ),
        _buildReviewCard(
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
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    required bool isComplete,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      color: const Color(0xFF071229),
      borderColor: const Color(0xFF1A315B),
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: items.map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1B3B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item, style: const TextStyle(fontSize: 11, color: Color(0xFFB9C6DC))),
                  )).toList(),
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

  Widget _buildValidationStep(List<String> issues) {
    if (issues.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, size: 80, color: Colors.blue),
            SizedBox(height: AppSpacing.xl),
            Text('Validation Successful', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
            SizedBox(height: 8),
            Text(
              'No conflicts or missing requirements found.',
              style: TextStyle(color: Color(0xFF8190AA)),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const Icon(Icons.warning_amber_outlined, size: 60, color: Colors.orange),
        const SizedBox(height: AppSpacing.l),
        const Text(
          'Structure Isn\'t Ready Yet',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.l),
        ...issues.map((issue) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 6, color: Color(0xFF8190AA)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(issue, style: const TextStyle(color: Color(0xFFB9C6DC)))),
                ],
              ),
            )),
      ],
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
          const Text('Ready to Activate!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white)),
          const SizedBox(height: 12),
          const Text(
            'Activating will make this structure live for all modules. Future changes will be tracked.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8190AA), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(String schoolId, List<String> issues) {
    final canAdvancePastValidation = issues.isEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.m, AppSpacing.xl, AppSpacing.m + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF071229),
        border: Border(top: BorderSide(color: Color(0xFF1A315B))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF1A315B)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      if (_currentStep == 1 && !canAdvancePastValidation) return;
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _activate(schoolId);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isActivating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_currentStep == 2 ? 'Activate Module' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            color: isActive ? AppColors.electricBlue : const Color(0xFF020716),
            border: Border.all(color: isActive ? AppColors.electricBlue : const Color(0xFF1A315B)),
          ),
          child: Center(
            child: Text(
              index.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF8190AA),
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
            color: isActive ? Colors.white : const Color(0xFF8190AA),
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
        color: isActive ? AppColors.electricBlue : const Color(0xFF1A315B),
      ),
    );
  }
}
