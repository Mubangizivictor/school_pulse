import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_service.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:uuid/uuid.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_wizard_banner.dart';

/// Manages a school's broad academic tiers. It uses the existing Structure
/// repository and `educational_levels` collection; classes remain linked by
/// their existing `levelId` field.
class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key, this.wizardStep, this.wizardTotal});
  final int? wizardStep;
  final int? wizardTotal;
  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  String _query = '';
  _Filter _filter = _Filter.all;
  _Order _order = _Order.display;

  /// One-shot, school-wide aggregate fetched once per screen visit - not
  /// stored in StructureBloc/State since it belongs to Students, not
  /// Structure. Mirrors the pattern used by the Classes & Streams overview
  /// tile (a single `.count()` query, never a per-level fan-out).
  late Future<int> _totalStudentsFuture;
  String? _studentsSchoolId;

  /// Per-level student counts, fetched at most once per level id - `build()`
  /// runs on every keystroke/filter/sort change, so this cache is what keeps
  /// that from turning into a fresh Firestore fan-out on every rebuild.
  final Map<String, Future<int>> _levelStudentsFutures = {};

  Future<int> _studentsFor(
    String schoolId,
    EducationalLevel level,
    int classCount,
  ) {
    if (classCount == 0) return Future.value(0);
    return _levelStudentsFutures[level.id] ??= di
        .sl<StructureDependencyService>()
        .countStudentsInLevel(schoolId, level.id);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    if (_studentsSchoolId != auth.user.schoolId) {
      _studentsSchoolId = auth.user.schoolId;
      _totalStudentsFuture = di
          .sl<StructureDependencyService>()
          .countAllStudents(auth.user.schoolId);
      _levelStudentsFutures.clear();
    }
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final all = [...state.levels]
          ..sort((a, b) => a.order.compareTo(b.order));
        final levels = all.where((level) {
          final query = _query.trim().toLowerCase();
          final matchesQuery =
              query.isEmpty ||
              level.name.toLowerCase().contains(query) ||
              level.code.toLowerCase().contains(query);
          return matchesQuery &&
              switch (_filter) {
                _Filter.all => true,
                _Filter.active => level.isActive,
                _Filter.inactive => !level.isActive,
              };
        }).toList();
        _sort(levels);
        final classCounts = <String, int>{};
        for (final item in state.classes) {
          classCounts.update(item.levelId, (n) => n + 1, ifAbsent: () => 1);
        }
        final canManage = auth.user.roles.any(
          (r) => r != UserRole.parent && r != UserRole.student,
        );
        return Scaffold(
          appBar: AdminAppBar(
            title: 'Levels',
            actions: [
              IconButton(
                tooltip: 'About educational levels',
                icon: const Icon(Icons.info_outline),
                onPressed: () => _info(context),
              ),
            ],
            bottom: widget.wizardStep == null || widget.wizardTotal == null
                ? null
                : StructureWizardBanner(
                    stepId: 'levels',
                    stepNumber: widget.wizardStep!,
                    totalSteps: widget.wizardTotal!,
                  ),
          ),
          body: ListView(
            // The previous Levels layout had a different scroll extent. A
            // distinct storage key prevents an old saved offset from opening
            // this redesigned screen below all of its content.
            key: const PageStorageKey('levels-overview-v2'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.x10l,
            ),
            children: [
              Text(
                'Educational levels define the overall structure of your school.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              _SearchBar(
                onChanged: (v) => setState(() => _query = v),
                onFilter: _pickFilter,
                isFiltering: _filter != _Filter.all,
              ),
              const SizedBox(height: AppSpacing.x2l),
              _Summary(
                total: all.length,
                active: all.where((l) => l.isActive).length,
                classes: state.classes
                    .where((c) => all.any((l) => l.id == c.levelId))
                    .length,
                studentsFuture: _totalStudentsFuture,
              ),
              const SizedBox(height: AppSpacing.x3l),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'LEVELS (${levels.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: .2,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickOrder,
                    icon: const Icon(Icons.unfold_more, size: 18),
                    label: const Text('Order'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              if (levels.isEmpty)
                _Empty(query: _query, filtered: _filter != _Filter.all)
              else
                ...levels.map(
                  (level) => _LevelCard(
                    level: level,
                    classCount: classCounts[level.id] ?? 0,
                    studentsFuture: _studentsFor(
                      auth.user.schoolId,
                      level,
                      classCounts[level.id] ?? 0,
                    ),
                    onTap: () =>
                        _openForm(context, auth.user.schoolId, all, level),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add-level',
            onPressed: canManage
                ? () => _openForm(context, auth.user.schoolId, all, null)
                : () => _denied(context),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
            icon: const Icon(Icons.add),
            label: const Text('Add Level'),
          ),
        );
      },
    );
  }

  void _sort(List<EducationalLevel> levels) {
    int byText(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());
    switch (_order) {
      case _Order.display:
        levels.sort(
          (a, b) => a.order != b.order
              ? a.order.compareTo(b.order)
              : byText(a.name, b.name),
        );
      case _Order.name:
        levels.sort((a, b) => byText(a.name, b.name));
      case _Order.code:
        levels.sort((a, b) => byText(a.code, b.code));
    }
  }

  Future<void> _pickFilter() async {
    final value =
        await _options<_Filter>(context, 'Filter levels', _filter, const {
          _Filter.all: 'All levels',
          _Filter.active: 'Active only',
          _Filter.inactive: 'Inactive only',
        });
    if (value != null && mounted) {
      setState(() => _filter = value);
    }
  }

  Future<void> _pickOrder() async {
    final value =
        await _options<_Order>(context, 'Order levels by', _order, const {
          _Order.display: 'Display order',
          _Order.name: 'Level name',
          _Order.code: 'Level code',
        });
    if (value != null && mounted) setState(() => _order = value);
  }

  void _openForm(
    BuildContext context,
    String schoolId,
    List<EducationalLevel> levels,
    EducationalLevel? existing,
  ) {
    final bloc = context.read<StructureBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LevelForm(
          schoolId: schoolId,
          levels: levels,
          existing: existing,
          save: (level) async => bloc.add(SaveLevelRequested(level)),
          dependencies: existing == null
              ? null
              : () => di.sl<StructureDependencyService>().countClassesInLevel(
                  schoolId,
                  existing.id,
                ),
          delete: existing == null
              ? null
              : (action) => bloc.add(
                  action == 'delete'
                      ? DeleteLevelRequested(existing.id)
                      : ArchiveLevelRequested(existing.id),
                ),
        ),
      ),
    );
  }
}

enum _Filter { all, active, inactive }

enum _Order { display, name, code }

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.onChanged,
    required this.onFilter,
    required this.isFiltering,
  });
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  final bool isFiltering;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.l),
          Icon(Icons.search, size: 28, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search levels...',
                border: InputBorder.none,
              ),
            ),
          ),
          VerticalDivider(
            indent: AppSpacing.l,
            endIndent: AppSpacing.l,
            color: scheme.outlineVariant,
          ),
          IconButton(
            onPressed: onFilter,
            tooltip: 'Filter levels',
            icon: Badge(
              isLabelVisible: isFiltering,
              smallSize: 7,
              child: const Icon(Icons.filter_alt_outlined),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.total,
    required this.active,
    required this.classes,
    required this.studentsFuture,
  });
  final int total, active, classes;
  final Future<int> studentsFuture;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.m,
      vertical: AppSpacing.x2l,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: AppRadius.large,
    ),
    child: Row(
      children: [
        Expanded(
          child: _Stat(
            Icons.account_balance_outlined,
            '$total',
            'Total Levels',
            Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: _Stat(
            Icons.check_circle_outline,
            '$active',
            'Active',
            AppColors.success(context),
          ),
        ),
        Expanded(
          child: _Stat(
            Icons.layers_outlined,
            '$classes',
            'Classes',
            Theme.of(context).colorScheme.secondary,
          ),
        ),
        Expanded(
          child: FutureBuilder<int>(
            future: studentsFuture,
            builder: (context, snapshot) => _Stat(
              Icons.people_outline,
              snapshot.hasData ? '${snapshot.data}' : '—',
              'Students',
              Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label, this.color);
  final IconData icon;
  final String value, label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.classCount,
    required this.studentsFuture,
    required this.onTap,
  });
  final EducationalLevel level;
  final int classCount;
  final Future<int> studentsFuture;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _color(context, level.code);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Material(
        color: scheme.surface,
        borderRadius: AppRadius.large,
        child: InkWell(
          borderRadius: AppRadius.large,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 98),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: AppRadius.large,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.l),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withValues(alpha: 0.14),
                  foregroundColor: color,
                  child: Text(
                    _initials(level),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.l + AppSpacing.s),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: level.isActive
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 7),
                      FutureBuilder<int>(
                        future: studentsFuture,
                        builder: (context, snapshot) => Text(
                          'Code: ${level.code}  •  Classes: $classCount'
                          '${snapshot.hasData ? '  •  Students: ${snapshot.data}' : ''}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _Badge(level.isActive),
                const SizedBox(width: AppSpacing.m),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.m),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.active);
  final bool active;
  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.success(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.query, required this.filtered});
  final String query;
  final bool filtered;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: AppSpacing.x9l,
      horizontal: AppSpacing.x3l,
    ),
    child: Column(
      children: [
        Icon(
          Icons.layers_outlined,
          size: 46,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          query.isNotEmpty || filtered
              ? 'No levels match your search.'
              : 'No educational levels yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Add Kindergarten, Primary, Secondary — or whatever tiers this school offers.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _LevelForm extends StatefulWidget {
  const _LevelForm({
    required this.schoolId,
    required this.levels,
    required this.save,
    this.existing,
    this.dependencies,
    this.delete,
  });
  final String schoolId;
  final List<EducationalLevel> levels;
  final EducationalLevel? existing;
  final Future<void> Function(EducationalLevel) save;
  final Future<int> Function()? dependencies;
  final void Function(String)? delete;
  @override
  State<_LevelForm> createState() => _LevelFormState();
}

class _LevelFormState extends State<_LevelForm> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _code = TextEditingController(text: widget.existing?.code);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  late final _order = TextEditingController(
    // New levels should be immediately saveable; append them after the
    // existing structure while still allowing an administrator to reorder.
    text: (widget.existing?.order ?? widget.levels.length + 1).toString(),
  );
  late bool _active = widget.existing?.isActive ?? true;
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _order.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.existing != null;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AdminAppBar(
        title: edit ? 'Edit Educational Level' : 'Add Educational Level',
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _formInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _key,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.l,
                  AppSpacing.xl,
                  AppSpacing.x2l,
                ),
                children: [
                  Text(
                    edit
                        ? 'Update this educational level.'
                        : 'Create a new educational level for your academic structure.',
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4l - AppSpacing.s),
                  _Label('Level Name *'),
                  _Field(
                    _name,
                    'e.g. Primary',
                    Icons.account_balance_outlined,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a level name.'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.x3l + AppSpacing.s),
                  _Label('Level Code *'),
                  _Field(
                    _code,
                    'e.g. PRI',
                    Icons.sell_outlined,
                    validator: _validateCode,
                  ),
                  const SizedBox(height: AppSpacing.x3l + AppSpacing.s),
                  _Label('Description'),
                  _Field(
                    _description,
                    'Brief description of this level',
                    Icons.description_outlined,
                    lines: 3,
                  ),
                  const SizedBox(height: AppSpacing.x3l + AppSpacing.s),
                  _Label('Display Order *'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.l),
                    child: Text(
                      'Lower numbers appear first',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  _Field(
                    _order,
                    'e.g. 1, 2, 3',
                    Icons.format_list_numbered,
                    type: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      return n == null || n < 1
                          ? 'Enter a valid display order.'
                          : null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.x3l + AppSpacing.m),
                  _Label('Status'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.l),
                    child: Text(
                      'Inactive levels won’t be available for selection',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _Status(
                          true,
                          _active,
                          () => setState(() => _active = true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.l),
                      Expanded(
                        child: _Status(
                          false,
                          !_active,
                          () => setState(() => _active = false),
                        ),
                      ),
                    ],
                  ),
                  if (edit && widget.dependencies != null) ...[
                    const SizedBox(height: AppSpacing.x3l - AppSpacing.s),
                    TextButton.icon(
                      onPressed: _saving ? null : _delete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Level'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xs,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(
                  _saving
                      ? 'Saving…'
                      : edit
                      ? 'Save Changes'
                      : 'Save Level',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateCode(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) return 'Enter a level code.';
    return widget.levels.any(
          (level) =>
              level.id != widget.existing?.id &&
              level.code.trim().toLowerCase() == code.toLowerCase(),
        )
        ? 'This level code is already in use.'
        : null;
  }

  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final level = EducationalLevel(
      id: widget.existing?.id ?? const Uuid().v4(),
      schoolId: widget.existing?.schoolId ?? widget.schoolId,
      name: _name.text.trim(),
      code: _code.text.trim(),
      description: _description.text.trim(),
      order: int.parse(_order.text.trim()),
      isActive: _active,
    );
    try {
      await widget.save(level);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('${level.name} saved successfully.')),
      );
    } catch (error, trace) {
      debugPrint('Failed to save educational level: $error\n$trace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save the level. Check your connection and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final n = await widget.dependencies!();
    if (!mounted) return;
    final action = n == 0
        ? ((await showDeleteConfirmDialog(
                    context,
                    title: 'Delete Level',
                    message: 'Delete "${widget.existing!.name}"?',
                  )) ==
                  true
              ? 'delete'
              : null)
        : await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Level is in use'),
              content: Text(
                'This level is used by $n class(es). Archive it instead to preserve those records.',
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
    if (action != null && mounted) {
      widget.delete!(action);
      Navigator.pop(context);
    }
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.l),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field(
    this.controller,
    this.hint,
    this.icon, {
    this.validator,
    this.lines = 1,
    this.type,
    this.formatters,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final int lines;
  final TextInputType? type;
  final List<TextInputFormatter>? formatters;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    maxLines: lines,
    keyboardType: type,
    inputFormatters: formatters,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      alignLabelWithHint: lines > 1,
      contentPadding: EdgeInsets.symmetric(vertical: lines > 1 ? 18 : 0),
      border: OutlineInputBorder(borderRadius: AppRadius.medium),
    ),
  );
}

class _Status extends StatelessWidget {
  const _Status(this.active, this.selected, this.onTap);
  final bool active, selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: AppRadius.medium,
      onTap: onTap,
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          borderRadius: AppRadius.medium,
          border: Border.all(color: selected ? s.primary : s.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? s.primary : s.outline,
            ),
            const SizedBox(width: AppSpacing.m + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    active ? 'Active' : 'Inactive',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    active ? 'Available for use' : 'Hidden from selection',
                    style: TextStyle(fontSize: 11.5, color: s.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> _options<T>(
  BuildContext context,
  String title,
  T selected,
  Map<T, String> options,
) => showModalBottomSheet<T>(
  context: context,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2l,
        0,
        AppSpacing.x2l,
        AppSpacing.x2l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.l - 2),
          RadioGroup<T>(
            groupValue: selected,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.entries
                  .map(
                    (entry) => RadioListTile<T>(
                      contentPadding: EdgeInsets.zero,
                      value: entry.key,
                      title: Text(entry.value),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  ),
);
void _info(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Educational levels'),
    content: const Text(
      'Levels are the major educational stages offered by the school. Classes such as P1 or S1 are created under a Level.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Got it'),
      ),
    ],
  ),
);
void _formInfo(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('About levels'),
    content: const Text(
      'Use levels for broad tiers. Lower display orders appear first throughout the school.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Got it'),
      ),
    ],
  ),
);
void _denied(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You don\'t have permission to manage school structure.'),
      ),
    );
Color _color(BuildContext context, String code) {
  final scheme = Theme.of(context).colorScheme;
  final colors = [
    scheme.primary,
    scheme.secondary,
    scheme.tertiary,
    scheme.error,
  ];
  return colors[code.toLowerCase().hashCode.abs() % colors.length];
}

String _initials(EducationalLevel level) {
  final words = level.name
      .trim()
      .split(RegExp(r'\s+'))
      .where((x) => x.isNotEmpty)
      .toList();
  return words.isEmpty
      ? 'LV'
      : words.take(2).map((x) => x[0]).join().toUpperCase();
}
