import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/matron_bloc.dart';
import '../bloc/matron_event.dart';
import '../bloc/matron_state.dart';
import '../../domain/entities/boarding_entities.dart';

class HygieneManagementScreen extends StatefulWidget {
  const HygieneManagementScreen({super.key});

  @override
  State<HygieneManagementScreen> createState() => _HygieneManagementScreenState();
}

class _HygieneManagementScreenState extends State<HygieneManagementScreen> {
  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(HygieneChecksRequested(gender: _genderScope(context)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hygiene & Sanitation'),
      ),
      body: BlocBuilder<MatronBloc, MatronState>(
        buildWhen: (previous, current) => current is HygieneChecksLoaded || current is MatronLoading || current is MatronError,
        builder: (context, state) {
          if (state is MatronLoading) return const Center(child: CircularProgressIndicator());
          if (state is MatronError) return Center(child: Text(state.message));
          if (state is HygieneChecksLoaded) {
            if (state.checks.isEmpty) {
              return const Center(child: Text('No hygiene inspections recorded.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.checks.length,
              itemBuilder: (context, index) {
                final check = state.checks[index];
                return _HygieneCheckCard(check: check);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHygieneSheet(context),
        label: const Text('New Inspection'),
        icon: const Icon(Icons.clean_hands_outlined),
      ),
    );
  }

  void _showAddHygieneSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddHygieneSheet(),
    );
  }
}

class _HygieneCheckCard extends StatelessWidget {
  final HygieneCheck check;
  const _HygieneCheckCard({required this.check});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(check.dormitoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _ScoreIndicator(score: check.score),
            ],
          ),
          const SizedBox(height: 8),
          Text(check.notes, style: Theme.of(context).textTheme.bodyMedium),
          if (check.maintenanceRequired.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Maintenance Needed:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Wrap(
              spacing: 8,
              children: check.maintenanceRequired
                  .map((item) => Chip(
                        label: Text(item, style: const TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By: ${check.recordedBy}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(check.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreIndicator extends StatelessWidget {
  final double score;
  const _ScoreIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    if (score < 7) color = Colors.orange;
    if (score < 4) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Score: ${score.toStringAsFixed(1)}/10',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _AddHygieneSheet extends StatefulWidget {
  const _AddHygieneSheet();

  @override
  State<_AddHygieneSheet> createState() => _AddHygieneSheetState();
}

class _AddHygieneSheetState extends State<_AddHygieneSheet> {
  String? _selectedDormId;
  String? _selectedDormName;
  double _score = 8.0;
  final _notesController = TextEditingController();
  final List<String> _maintenanceItems = [];
  final _maintenanceItemController = TextEditingController();

  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(DormitoriesRequested(gender: _genderScope(context)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state as AuthAuthenticated;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            context.read<MatronBloc>().add(HygieneChecksRequested(gender: _genderScope(context)));
          }
        },
        builder: (context, state) {
          List<Dormitory> dorms = [];
          if (state is DormitoriesLoaded) dorms = state.dormitories;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sanitation Inspection', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Dormitory', border: OutlineInputBorder()),
                items: dorms.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                onChanged: (val) {
                  _selectedDormId = val;
                  _selectedDormName = dorms.firstWhere((d) => d.id == val).name;
                },
              ),
              const SizedBox(height: 24),
              Text('Cleanliness Score: ${_score.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _score,
                min: 0,
                max: 10,
                divisions: 20,
                label: _score.toStringAsFixed(1),
                onChanged: (val) => setState(() => _score = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'General Notes', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _maintenanceItemController,
                      decoration: const InputDecoration(labelText: 'Add Maintenance Request', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      if (_maintenanceItemController.text.isNotEmpty) {
                        setState(() {
                          _maintenanceItems.add(_maintenanceItemController.text);
                          _maintenanceItemController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (_maintenanceItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _maintenanceItems
                      .map((item) => InputChip(
                            label: Text(item),
                            onDeleted: () => setState(() => _maintenanceItems.remove(item)),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_selectedDormId != null && _notesController.text.isNotEmpty)
                      ? () {
                          context.read<MatronBloc>().add(AddHygieneCheckRequested(
                                HygieneCheck(
                                  id: '',
                                  dormitoryId: _selectedDormId!,
                                  dormitoryName: _selectedDormName!,
                                  date: DateTime.now(),
                                  score: _score,
                                  notes: _notesController.text,
                                  maintenanceRequired: _maintenanceItems,
                                  recordedBy: authState.user.name,
                                ),
                              ));
                        }
                      : null,
                  child: const Text('Submit Inspection'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
