import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/assessment_grading_entities.dart';
import '../../domain/entities/structure_entities.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// Assessment & Grading step: define the grading system(s) used to convert
/// marks into grades. Replaces the earlier Fee Categories tab, which
/// duplicated Finance's own configuration and did not belong in Structure
/// setup.
class AssessmentGradingScreen extends StatelessWidget {
  const AssessmentGradingScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: const Text('Assessment & grading'))
          : null,
      backgroundColor: showAppBar ? null : Colors.transparent,
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => _GradingSystemsBody(state: state),
      ),
    );
  }
}

class _GradingSystemsBody extends StatelessWidget {
  const _GradingSystemsBody({required this.state});

  final StructureState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final systems = state.gradingSystems;

    void onAdd() => _showGradingSystemFormSheet(
      context,
      schoolId: schoolId,
      levels: state.levels,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Create the grading system used to calculate results.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add grading system'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (systems.isEmpty)
              _GradingEmptyState(onAdd: onAdd)
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: systems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final system = systems[index];
                    final bands =
                        state.gradeBands
                            .where((b) => b.gradingSystemId == system.id)
                            .toList()
                          ..sort((a, b) => a.order.compareTo(b.order));
                    final levelName = system.levelIds.isEmpty
                        ? 'Whole school'
                        : state.levels
                              .where((l) => system.levelIds.contains(l.id))
                              .map((l) => l.name)
                              .join(', ');
                    final passMark = system.passingScore != null
                        ? '${system.passingScore!.toStringAsFixed(0)}%'
                        : (system.passingGradeCode ?? '—');
                    final shown = bands.take(3).toList();
                    final more = bands.length - shown.length;

                    return AppCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              system.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (system.isDefault) ...[
                                            const SizedBox(width: 8),
                                            Chip(
                                              label: const Text('Default'),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              backgroundColor: scheme.primary,
                                              labelStyle: TextStyle(
                                                color: scheme.onPrimary,
                                              ),
                                              side: BorderSide.none,
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        '$levelName  •  Pass mark $passMark',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${bands.length} grade band${bands.length == 1 ? '' : 's'}'
                                        '${bands.isEmpty ? '' : '  •  ${bands.first.grade} to ${bands.last.grade}'}',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (_) =>
                                      _showGradingSystemFormSheet(
                                        context,
                                        schoolId: schoolId,
                                        levels: state.levels,
                                        existing: system,
                                        existingBands: bands,
                                      ),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (shown.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final band in shown)
                                    _bandChip(context, band),
                                  if (more > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: scheme.outlineVariant,
                                        ),
                                      ),
                                      child: Text(
                                        '+$more more',
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bandChip(BuildContext context, GradeBand band) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            band.grade,
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            band.hasNumericBoundary
                ? '${band.minScore.toStringAsFixed(0)}–${band.maxScore.toStringAsFixed(0)}'
                : band.label,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _GradingEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _GradingEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.insert_chart_outlined, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'No grading system added',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Add grade bands and pass marks for your school.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeBandDraft {
  _GradeBandDraft({String? grade, String? range})
    : gradeController = TextEditingController(text: grade),
      rangeController = TextEditingController(text: range);

  final TextEditingController gradeController;
  final TextEditingController rangeController;

  void dispose() {
    gradeController.dispose();
    rangeController.dispose();
  }
}

/// Parses "80-100" / "80–100" into (min, max); returns null if malformed.
(double, double)? _parseRange(String raw) {
  final parts = raw.trim().split(RegExp(r'[-–]'));
  if (parts.length != 2) return null;
  final min = double.tryParse(parts[0].trim());
  final max = double.tryParse(parts[1].trim());
  if (min == null || max == null) return null;
  return (min, max);
}

Future<void> _showGradingSystemFormSheet(
  BuildContext context, {
  required String schoolId,
  required List<EducationalLevel> levels,
  GradingSystemDef? existing,
  List<GradeBand>? existingBands,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final passMarkController = TextEditingController(
    text: existing?.passingScore?.toStringAsFixed(0) ?? '50',
  );
  String? selectedLevelId = existing != null && existing.levelIds.isNotEmpty
      ? existing.levelIds.first
      : (levels.isNotEmpty ? levels.first.id : null);
  bool isDefault = existing?.isDefault ?? false;
  final drafts = existingBands != null && existingBands.isNotEmpty
      ? existingBands
            .map(
              (b) => _GradeBandDraft(
                grade: b.grade,
                range: b.hasNumericBoundary
                    ? '${b.minScore.toStringAsFixed(0)}-${b.maxScore.toStringAsFixed(0)}'
                    : b.label,
              ),
            )
            .toList()
      : [_GradeBandDraft()];

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          existing == null
                              ? 'Add grading system'
                              : 'Edit grading system',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          shape: const CircleBorder(),
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Define how marks are converted into grades.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'System name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLevelId,
                    decoration: const InputDecoration(
                      labelText: 'Education level',
                    ),
                    items: levels
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedLevelId = v),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: passMarkController,
                    decoration: const InputDecoration(
                      labelText: 'Pass mark',
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final value = double.tryParse(v ?? '');
                      if (value == null || value < 0 || value > 100) {
                        return 'Enter a value between 0 and 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Grade bands',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < drafts.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: drafts[i].gradeController,
                              decoration: const InputDecoration(
                                hintText: 'D1',
                                isDense: true,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: drafts[i].rangeController,
                              decoration: const InputDecoration(
                                hintText: '80-100',
                                isDense: true,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required';
                                }
                                return _parseRange(v) == null
                                    ? 'Use e.g. 80-100'
                                    : null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: drafts.length == 1
                                ? null
                                : () => setState(() {
                                    drafts[i].dispose();
                                    drafts.removeAt(i);
                                  }),
                          ),
                        ],
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => drafts.add(_GradeBandDraft())),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add grade band'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(
                        color: scheme.primary,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set as default',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Switch(
                        value: isDefault,
                        onChanged: (v) => setState(() => isDefault = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        final parsed = <(String grade, double min, double max)>[
                          for (final draft in drafts)
                            (
                              draft.gradeController.text.trim(),
                              _parseRange(draft.rangeController.text)!.$1,
                              _parseRange(draft.rangeController.text)!.$2,
                            ),
                        ]..sort((a, b) => b.$2.compareTo(a.$2));

                        final gradeCodes = parsed.map(
                          (e) => e.$1.toLowerCase(),
                        );
                        if (gradeCodes.toSet().length != parsed.length) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Grade codes must be unique.'),
                            ),
                          );
                          return;
                        }
                        for (final band in parsed) {
                          if (band.$3 < band.$2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${band.$1}: max must be greater than or equal to min.',
                                ),
                              ),
                            );
                            return;
                          }
                        }
                        for (var i = 0; i < parsed.length - 1; i++) {
                          final higher = parsed[i];
                          final lower = parsed[i + 1];
                          if (higher.$2 <= lower.$3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${higher.$1} and ${lower.$1} overlap.',
                                ),
                              ),
                            );
                            return;
                          }
                          if (higher.$2 > lower.$3 + 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'There is a gap between ${lower.$1} and ${higher.$1}.',
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        final systemId = existing?.id ?? const Uuid().v4();
                        final system = GradingSystemDef(
                          id: systemId,
                          schoolId: schoolId,
                          name: nameController.text.trim(),
                          isDefault: isDefault,
                          appliesTo: selectedLevelId == null
                              ? 'school'
                              : 'levels',
                          levelIds: selectedLevelId == null
                              ? const []
                              : [selectedLevelId!],
                          passingScore: double.tryParse(
                            passMarkController.text,
                          ),
                        );

                        final bloc = context.read<StructureBloc>();

                        // Pop the sheet before dispatching any bloc events.
                        // Each SaveGradingSystemRequested/SaveGradeBandRequested
                        // handler awaits a Firestore write and the bloc's own
                        // watchGradingSystems/watchGradeBands stream subscriptions
                        // then feed the write straight back as a *Loaded event,
                        // which re-emits state asynchronously (a real async gap,
                        // not same-frame reentrancy). If that re-emit lands while
                        // this sheet is still mid-teardown, the ancestor
                        // BlocBuilder rebuilds against a subtree whose
                        // TextEditingControllers are disposing, producing "used
                        // after disposed" -> "build dirty widget in wrong build
                        // scope". Popping first lets the sheet fully unmount and
                        // dispose its controllers before any such re-emit can
                        // reach it.
                        Navigator.pop(context);

                        bloc.add(SaveGradingSystemRequested(system));

                        final keptIds = <String>{};
                        for (var i = 0; i < parsed.length; i++) {
                          final existingBand =
                              existingBands != null && i < existingBands.length
                              ? existingBands[i]
                              : null;
                          final id = existingBand?.id ?? const Uuid().v4();
                          keptIds.add(id);
                          bloc.add(
                            SaveGradeBandRequested(
                              GradeBand(
                                id: id,
                                schoolId: schoolId,
                                gradingSystemId: systemId,
                                grade: parsed[i].$1,
                                minScore: parsed[i].$2,
                                maxScore: parsed[i].$3,
                                order: i,
                                hasNumericBoundary: true,
                              ),
                            ),
                          );
                        }
                        if (existingBands != null) {
                          for (final old in existingBands) {
                            if (!keptIds.contains(old.id)) {
                              bloc.add(DeleteGradeBandRequested(old.id));
                            }
                          }
                        }
                      },
                      child: Text(
                        existing == null
                            ? 'Save grading system'
                            : 'Save changes',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  for (final draft in drafts) {
    draft.dispose();
  }
  nameController.dispose();
  passMarkController.dispose();
}
