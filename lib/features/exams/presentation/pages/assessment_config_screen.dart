import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';
import '../../domain/entities/assessment_type.dart';
import '../../domain/entities/grading_system.dart';
import '../../../../design_system/app_components.dart';
import '../../data/models/assessment_type_model.dart';
import '../../data/models/grading_system_model.dart';

class AssessmentConfigScreen extends StatefulWidget {
  final String schoolId;
  const AssessmentConfigScreen({super.key, required this.schoolId});

  @override
  State<AssessmentConfigScreen> createState() => _AssessmentConfigScreenState();
}

class _AssessmentConfigScreenState extends State<AssessmentConfigScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AssessmentBloc>().add(LoadAssessmentConfig(widget.schoolId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Configuration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Assessment Types'),
            Tab(text: 'Grading Systems'),
          ],
        ),
      ),
      body: BlocBuilder<AssessmentBloc, AssessmentState>(
        builder: (context, state) {
          if (state.status == AssessmentStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _AssessmentTypesTab(
                types: state.assessmentTypes,
                schoolId: widget.schoolId,
              ),
              _GradingSystemsTab(
                systems: state.gradingSystems,
                schoolId: widget.schoolId,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    if (_tabController.index == 0) {
      _showAddAssessmentTypeDialog();
    } else {
      _showAddGradingSystemDialog();
    }
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
              if (nameController.text.isEmpty || weightController.text.isEmpty)
                return;
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

  void _showAddGradingSystemDialog() {
    final nameController = TextEditingController();
    GradingType selectedType = GradingType.percentage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Grading System'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'System Name'),
              ),
              const SizedBox(height: 16),
              DropdownButton<GradingType>(
                value: selectedType,
                isExpanded: true,
                items: GradingType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedType = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;
                final system = GradingSystemModel(
                  id: const Uuid().v4(),
                  schoolId: widget.schoolId,
                  name: nameController.text,
                  type: selectedType,
                  ranges: const [], // Ranges would be added in a detail view
                );
                context.read<AssessmentBloc>().add(
                  AddGradingSystem(widget.schoolId, system),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
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

class _GradingSystemsTab extends StatelessWidget {
  final List<GradingSystem> systems;
  final String schoolId;
  const _GradingSystemsTab({required this.systems, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    if (systems.isEmpty) {
      return const EmptyState(
        icon: Icons.grade,
        title: 'No Grading Systems',
        message: 'Configure grading scales for your school.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: systems.length,
      itemBuilder: (context, index) {
        final system = systems[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              system.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Type: ${system.type.name}'),
            children: system.ranges
                .map(
                  (range) => ListTile(
                    title: Text(
                      '${range.grade}: ${range.minScore} - ${range.maxScore}',
                    ),
                    subtitle: Text(range.remarks),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
