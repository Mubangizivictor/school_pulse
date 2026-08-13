import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/services/structure_dependency_service.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        final levels = state.levels
            .where(
              (l) => l.name.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        return AcademicsListScaffold(
          title: 'Levels',
          subtitle:
              'Educational levels define the overall structure of your school.',
          searchHint: 'Search levels...',
          onSearchChanged: (v) => setState(() => _query = v),
          fabLabel: 'Add Level',
          onFabPressed: () => _openForm(context, schoolId: schoolId, bloc: bloc),
          body: levels.isEmpty
              ? StructureEmptyHint(
                  _query.isEmpty
                      ? 'No educational levels yet.\nAdd Kindergarten, Primary, Secondary - or whatever tiers this school offers.'
                      : 'No levels match "$_query".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final classCount = state.classes
                        .where((c) => c.levelId == level.id)
                        .length;
                    return AcademicsListCard(
                      icon: Icons.layers_outlined,
                      color: Colors.teal,
                      title: level.name,
                      subtitle: level.code.isNotEmpty
                          ? level.code
                          : level.description,
                      trailingLabel: classCount > 0
                          ? '$classCount Class${classCount == 1 ? '' : 'es'}'
                          : null,
                      isActive: level.isActive,
                      onTap: () => _openForm(
                        context,
                        schoolId: schoolId,
                        bloc: bloc,
                        existing: level,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _openForm(
    BuildContext context, {
    required String schoolId,
    required StructureBloc bloc,
    EducationalLevel? existing,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LevelFormScreen(
          schoolId: schoolId,
          existing: existing,
          onSave: (level) => bloc.add(SaveLevelRequested(level)),
          onDelete: existing == null
              ? null
              : () async {
                  final dependentCount = await di
                      .sl<StructureDependencyService>()
                      .countClassesInLevel(schoolId, existing.id);
                  return dependentCount;
                },
          onDeleteConfirmed: existing == null
              ? null
              : (action) {
                  if (action == 'delete') {
                    bloc.add(DeleteLevelRequested(existing.id));
                  } else if (action == 'archive') {
                    bloc.add(ArchiveLevelRequested(existing.id));
                  }
                },
        ),
      ),
    );
  }
}

class _LevelFormScreen extends StatefulWidget {
  final String schoolId;
  final EducationalLevel? existing;
  final void Function(EducationalLevel) onSave;
  final Future<int> Function()? onDelete;
  final void Function(String action)? onDeleteConfirmed;

  const _LevelFormScreen({
    required this.schoolId,
    this.existing,
    required this.onSave,
    this.onDelete,
    this.onDeleteConfirmed,
  });

  @override
  State<_LevelFormScreen> createState() => _LevelFormScreenState();
}

class _LevelFormScreenState extends State<_LevelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _codeController = TextEditingController(
    text: widget.existing?.code,
  );
  late final _descController = TextEditingController(
    text: widget.existing?.description,
  );
  late final _orderController = TextEditingController(
    text: widget.existing?.order.toString() ?? '',
  );
  late bool _isActive = widget.existing?.isActive ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Educational Level' : 'Add Educational Level',
      subtitle: isEdit
          ? 'Update this educational level.'
          : 'Create a new educational level for your academic structure.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Level',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Level Name *',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Primary'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Level name is required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Level Code *',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'e.g. PRI'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Level code is required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'Brief description of this level',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Display Order',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Lower numbers appear first',
                style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(hintText: 'e.g. 2'),
                keyboardType: TextInputType.number,
              ),
              if (isEdit) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Level',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      EducationalLevel(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        order: int.tryParse(_orderController.text) ?? 0,
        description: _descController.text.trim(),
        isActive: _isActive,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final dependentCount = await widget.onDelete!();
    if (!mounted) return;
    final itemName = widget.existing!.name;
    String? action;
    if (dependentCount == 0) {
      final confirmed = await showDeleteConfirmDialog(
        context,
        title: 'Delete Level',
        message: 'Delete "$itemName"?',
      );
      action = confirmed == true ? 'delete' : null;
    } else {
      action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Level'),
          content: Text(
            '"$itemName" is still referenced by $dependentCount class(es). '
            'Archive it instead of deleting it to keep that data intact.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'archive'),
              child: const Text('Archive'),
            ),
          ],
        ),
      );
    }
    if (action == null || !mounted) return;
    widget.onDeleteConfirmed!(action);
    Navigator.of(context).pop();
  }
}
