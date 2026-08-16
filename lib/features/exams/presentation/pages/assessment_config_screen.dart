import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';
import '../../domain/entities/assessment_type.dart';
import '../../../../design_system/app_components.dart';
import '../../data/models/assessment_type_model.dart';

// Grading-system configuration is owned exclusively by Structure's
// GradingSystemsScreen (lib/features/structure/.../grading_systems_screen.dart)
// against GradingSystemDef/GradeBand - this screen used to duplicate that
// with its own thinner GradingSystem model, which has been removed to keep
// a single source of truth for grading configuration.
class AssessmentConfigScreen extends StatefulWidget {
  final String schoolId;
  const AssessmentConfigScreen({super.key, required this.schoolId});

  @override
  State<AssessmentConfigScreen> createState() => _AssessmentConfigScreenState();
}

class _AssessmentConfigScreenState extends State<AssessmentConfigScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AssessmentBloc>().add(LoadAssessmentConfig(widget.schoolId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment Types')),
      body: BlocBuilder<AssessmentBloc, AssessmentState>(
        builder: (context, state) {
          if (state.status == AssessmentStatus.loading) {
            return const Center(child: SchoolPulseLoader());
          }
          return _AssessmentTypesTab(
            types: state.assessmentTypes,
            schoolId: widget.schoolId,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAssessmentTypeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAssessmentTypeDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final weightController = TextEditingController();
    final maxMarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Assessment Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. Midterm)',
                ),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code (e.g. MT)'),
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (%)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxMarkController,
                decoration: const InputDecoration(labelText: 'Max Mark'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  weightController.text.isEmpty) {
                return;
              }
              final type = AssessmentTypeModel(
                id: const Uuid().v4(),
                name: nameController.text,
                code: codeController.text,
                weight: double.tryParse(weightController.text) ?? 0,
                maxMark: double.tryParse(maxMarkController.text) ?? 100,
                passingMark: 0,
                academicTerm: 'Term 1',
                academicYear: '2024',
              );
              context.read<AssessmentBloc>().add(
                AddAssessmentType(widget.schoolId, type),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AssessmentTypesTab extends StatelessWidget {
  final List<AssessmentType> types;
  final String schoolId;
  const _AssessmentTypesTab({required this.types, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment,
        title: 'No Assessment Types',
        message: 'Add assessment types like CAT, Midterm, etc.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              type.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Weight: ${type.weight}% | Max: ${type.maxMark}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}
