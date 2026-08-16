import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/assessment_grading_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

/// Fee Categories and Assessment Types - defined here as Structure's own
/// configuration copies (Finance/Exams maintain their own already-wired
/// versions; this module does not replace them). Grading Systems used to
/// have a third tab here, duplicating GradingSystemsScreen's
/// GradingSystemDef/GradeBand configuration against the same Firestore
/// collections; that tab has been removed so grading configuration has a
/// single home (Structure > Academics > Grading Systems).
class AssessmentGradingScreen extends StatefulWidget {
  const AssessmentGradingScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<AssessmentGradingScreen> createState() =>
      _AssessmentGradingScreenState();
}

class _AssessmentGradingScreenState extends State<AssessmentGradingScreen> {
  static const _sections = ['Fee categories', 'Assessment types'];
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
  }

  @override
  void didUpdateWidget(covariant AssessmentGradingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Assessment & Grading'),
      body: Column(
        children: [
          StructureSectionPicker(
            sections: _sections,
            selectedIndex: _selectedIndex,
            onSelected: (index) =>
                context.go('/staff/admin/structure/assessment?tab=$index'),
          ),
          Expanded(
            child: BlocBuilder<StructureBloc, StructureState>(
              builder: (context, state) => IndexedStack(
                index: _selectedIndex,
                children: [
                  _FeeCategoriesTab(state: state),
                  _AssessmentTypesTab(state: state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeCategoriesTab extends StatelessWidget {
  final StructureState state;
  const _FeeCategoriesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      body: state.feeCategories.isEmpty
          ? const StructureEmptyHint('No fee categories defined yet.')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.feeCategories.length,
              itemBuilder: (context, index) {
                final category = state.feeCategories[index];
                return StructureListRow(
                  icon: Icons.payments_outlined,
                  color: Colors.deepOrange,
                  title: category.name,
                  subtitle: category.isMandatory ? 'Mandatory' : 'Optional',
                  isActive: category.isActive,
                  onEdit: () => showFeeCategoryFormDialog(
                    context,
                    existing: category,
                    schoolId: schoolId,
                    onSave: (u) => bloc.add(SaveFeeCategoryRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Category',
                      message: 'Delete "${category.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteFeeCategoryRequested(category.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFeeCategoryFormDialog(
          context,
          schoolId: schoolId,
          onSave: (c) => bloc.add(SaveFeeCategoryRequested(c)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}

class _AssessmentTypesTab extends StatelessWidget {
  final StructureState state;
  const _AssessmentTypesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      body: state.assessmentTypes.isEmpty
          ? const StructureEmptyHint(
              'No assessment types defined yet.\ne.g. CAT, Assignment, Midterm, Final Examination.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.assessmentTypes.length,
              itemBuilder: (context, index) {
                final type = state.assessmentTypes[index];
                return StructureListRow(
                  icon: Icons.assignment_outlined,
                  color: Colors.deepOrange,
                  title: type.name,
                  subtitle: 'Weight: ${type.weightPercentage}%',
                  isActive: type.isActive,
                  onEdit: () => showAssessmentTypeFormDialog(
                    context,
                    existing: type,
                    schoolId: schoolId,
                    onSave: (u) => bloc.add(SaveAssessmentTypeRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Type',
                      message: 'Delete "${type.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteAssessmentTypeRequested(type.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAssessmentTypeFormDialog(
          context,
          schoolId: schoolId,
          onSave: (t) => bloc.add(SaveAssessmentTypeRequested(t)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Type'),
      ),
    );
  }
}
