import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/domain/entities/assessment_moderation.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Read-only DOS oversight of canonical subject-assessment and class-homework
/// documents. Teachers remain the only creators of their academic activity.
class AssessmentsOverviewScreen extends StatefulWidget {
  const AssessmentsOverviewScreen({super.key});

  @override
  State<AssessmentsOverviewScreen> createState() =>
      _AssessmentsOverviewScreenState();
}

class _AssessmentsOverviewScreenState extends State<AssessmentsOverviewScreen> {
  String _type = 'All';
  String _query = '';
  String? _classId;
  bool _attentionOnly = false;
  bool _searchOpen = false;

  String get _schoolId {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated ? auth.user.schoolId : '';
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        sl<DeanBloc>()..add(AssessmentsOverviewRequested(schoolId: _schoolId)),
    child: Builder(
      builder: (context) => Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: BlocBuilder<DeanBloc, DeanState>(
            builder: (context, state) {
              void reload() => context.read<DeanBloc>().add(
                AssessmentsOverviewRequested(schoolId: _schoolId),
              );
              if (state is DeanLoading || state is DeanInitial) {
                return const _Skeleton();
              }
              if (state is DeanError) {
                return _Failure(message: state.message, onRetry: reload);
              }
              if (state is! AssessmentsOverviewLoaded) return const _Skeleton();
              return _Overview(
                items: state.assessments,
                type: _type,
                query: _query,
                classId: _classId,
                attentionOnly: _attentionOnly,
                searchOpen: _searchOpen,
                onRefresh: reload,
                onType: (v) => setState(() => _type = v),
                onQuery: (v) => setState(() => _query = v),
                onSearch: () => setState(() => _searchOpen = !_searchOpen),
                onFilters: (classId, attention) => setState(() {
                  _classId = classId;
                  _attentionOnly = attention;
                }),
                onClear: () => setState(() {
                  _type = 'All';
                  _query = '';
                  _classId = null;
                  _attentionOnly = false;
                }),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.items,
    required this.type,
    required this.query,
    required this.classId,
    required this.attentionOnly,
    required this.searchOpen,
    required this.onRefresh,
    required this.onType,
    required this.onQuery,
    required this.onSearch,
    required this.onFilters,
    required this.onClear,
  });
  final List<AssessmentModeration> items;
  final String type, query;
  final String? classId;
  final bool attentionOnly, searchOpen;
  final VoidCallback onRefresh, onSearch, onClear;
  final ValueChanged<String> onType, onQuery;
  final void Function(String?, bool) onFilters;

  bool _needsAttention(AssessmentModeration item) =>
      item.rawStatus == 'returned' ||
      ((item.dueDate?.isBefore(DateTime.now()) ?? false) &&
          item.missingMarksCount > 0);
  List<AssessmentModeration> get _shown {
    final needle = query.toLowerCase().trim();
    final result = items
        .where(
          (item) =>
              (type == 'All' ||
                  item.type.toLowerCase() == type.toLowerCase()) &&
              (classId == null || item.classId == classId) &&
              (!attentionOnly || _needsAttention(item)) &&
              (needle.isEmpty ||
                  '${item.title} ${item.teacherName} ${item.subjectName} ${item.className}'
                      .toLowerCase()
                      .contains(needle)),
        )
        .toList();
    result.sort((a, b) => _sortRank(a).compareTo(_sortRank(b)));
    return result;
  }

  int _sortRank(AssessmentModeration item) => _needsAttention(item)
      ? 0
      : (item.dueDate != null &&
                DateUtils.isSameDay(item.dueDate, DateTime.now())
            ? 1
            : 2);

  @override
  Widget build(BuildContext context) {
    final needsReview = items.where(_needsAttention).length;
    final classes = {
      for (final item in items)
        if (item.classId.isNotEmpty) item.classId: item.className,
    };
    final filters =
        (type == 'All' ? 0 : 1) +
        (query.isEmpty ? 0 : 1) +
        (classId == null ? 0 : 1) +
        (attentionOnly ? 1 : 0);
    final supportedTypes = <String>{
      'All',
      'Homework',
      'Quiz',
      'Test',
      'Project',
      'Practical',
      ...items.map((e) => e.type),
    }.where((v) => v.isNotEmpty && !v.toLowerCase().contains('exam')).toList();
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _Header(
                searchOpen: searchOpen,
                query: query,
                filters: filters,
                onSearch: onSearch,
                onQuery: onQuery,
                onFilter: () => _filterSheet(context, classes),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: _Metrics(items: items)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final value in supportedTypes) ...[
                      ChoiceChip(
                        label: Text(value),
                        selected: type.toLowerCase() == value.toLowerCase(),
                        onSelected: (_) => onType(value),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (needsReview > 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              sliver: SliverToBoxAdapter(
                child: OutlinedButton.icon(
                  onPressed: () => onFilters(classId, true),
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning(context),
                  ),
                  label: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$needsReview assessment${needsReview == 1 ? '' : 's'} need attention',
                        ),
                      ),
                      const Text('Review'),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'Recent activity',
                    style: AppTypography.titleMedium.copyWith(fontSize: 17),
                  ),
                  const Spacer(),
                  if (filters > 0)
                    TextButton(
                      onPressed: onClear,
                      child: const Text('Clear all'),
                    ),
                ],
              ),
            ),
          ),
          if (_shown.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No assessments found',
                message: filters > 0
                    ? 'No assessments match the selected filters.'
                    : 'No continuous assessments have been created for this term.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: _shown.length,
                separatorBuilder: (_, _) =>
                    Divider(color: AppColors.border(context), height: 1),
                itemBuilder: (_, index) => _Row(item: _shown[index]),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _filterSheet(
    BuildContext context,
    Map<String, String> classes,
  ) async {
    var chosenClass = classId;
    var chosenAttention = attentionOnly;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (_, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter assessments', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: chosenClass,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All classes'),
                    ),
                    for (final entry in classes.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value.isEmpty ? entry.key : entry.value,
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setSheetState(() => chosenClass = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Needs attention'),
                  value: chosenAttention,
                  onChanged: (value) =>
                      setSheetState(() => chosenAttention = value),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      onFilters(chosenClass, chosenAttention);
                      Navigator.pop(sheet);
                    },
                    child: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchOpen,
    required this.query,
    required this.filters,
    required this.onSearch,
    required this.onQuery,
    required this.onFilter,
  });
  final bool searchOpen;
  final String query;
  final int filters;
  final VoidCallback onSearch, onFilter;
  final ValueChanged<String> onQuery;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessments & Marks',
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track coursework, deadlines and marking',
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search assessments',
            onPressed: onSearch,
            icon: Icon(searchOpen ? Icons.close : Icons.search),
          ),
          Badge(
            isLabelVisible: filters > 0,
            label: Text('$filters'),
            child: IconButton(
              tooltip: 'Filter assessments',
              onPressed: onFilter,
              icon: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      if (searchOpen) ...[
        const SizedBox(height: 10),
        TextField(
          autofocus: true,
          onChanged: onQuery,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search title, teacher, subject or class',
          ),
        ),
      ],
    ],
  );
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.items});
  final List<AssessmentModeration> items;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekEnd = now.add(Duration(days: 7 - now.weekday));
    final metrics = [
      (
        items
            .where(
              (v) => ![
                'draft',
                'completed',
                'archived',
                'cancelled',
              ].contains(v.rawStatus),
            )
            .length,
        'Active',
        AppColors.information(context),
        Icons.assignment_outlined,
      ),
      (
        items
            .where(
              (v) =>
                  v.dueDate != null &&
                  !v.dueDate!.isBefore(DateUtils.dateOnly(now)) &&
                  !v.dueDate!.isAfter(weekEnd),
            )
            .length,
        'Due this week',
        AppColors.warning(context),
        Icons.calendar_month_outlined,
      ),
      (
        items
            .where(
              (v) =>
                  v.rawStatus == 'returned' ||
                  ((v.dueDate?.isBefore(now) ?? false) &&
                      v.missingMarksCount > 0),
            )
            .length,
        'Need review',
        AppColors.danger(context),
        Icons.warning_amber_rounded,
      ),
      (
        items.fold(0, (total, v) => total + v.missingMarksCount),
        'Marks pending',
        AppColors.success(context),
        Icons.check_circle_outline,
      ),
    ];
    return LayoutBuilder(
      builder: (_, box) => GridView.count(
        crossAxisCount: box.maxWidth >= 700 ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: box.maxWidth >= 700 ? 2.3 : 1.65,
        children: [
          for (final metric in metrics)
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: metric.$3.withValues(alpha: .12),
                    child: Icon(metric.$4, color: metric.$3, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${metric.$1}',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 26,
                            height: 1,
                            color: metric.$3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          metric.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item});
  final AssessmentModeration item;
  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final due = item.dueDate;
    final overdue = due?.isBefore(DateTime.now()) ?? false;
    final badge = item.missingMarksCount > 0
        ? 'Marking ${item.markedCount}/${item.totalStudents}'
        : _status;
    return InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => _Details(item: item),
      ),
      borderRadius: AppRadius.medium,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(_icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type.toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      item.teacherName,
                      item.subjectName,
                      item.className,
                    ].where((v) => v.isNotEmpty).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    due == null
                        ? _status
                        : '${overdue
                              ? 'Overdue'
                              : DateUtils.isSameDay(due, DateTime.now())
                              ? 'Due today'
                              : 'Due ${DateFormat('d MMM').format(due)}'} • ${item.totalStudents} learners',
                    style: AppTypography.bodySmall.copyWith(
                      color: overdue
                          ? AppColors.danger(context)
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: color),
                    borderRadius: AppRadius.small,
                  ),
                  child: Text(
                    badge,
                    style: AppTypography.labelSmall.copyWith(color: color),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _status => switch (item.rawStatus) {
    'returned' => 'Returned',
    'completed' => 'Marks complete',
    'published' || 'active' => 'Published',
    _ => item.rawStatus.replaceAll('_', ' '),
  };
  IconData get _icon => switch (item.type.toLowerCase()) {
    'homework' => Icons.menu_book_outlined,
    'quiz' => Icons.quiz_outlined,
    'project' => Icons.folder_outlined,
    'practical' => Icons.science_outlined,
    _ => Icons.assignment_outlined,
  };
  Color _color(BuildContext context) => switch (item.type.toLowerCase()) {
    'homework' => AppColors.information(context),
    'quiz' => AppColors.success(context),
    'project' => Colors.deepPurple,
    'practical' => AppColors.warning(context),
    _ => AppColors.danger(context),
  };
}

class _Details extends StatelessWidget {
  const _Details({required this.item});
  final AssessmentModeration item;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.type,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.information(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(item.title, style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          if ((item.description ?? '').isNotEmpty) Text(item.description!),
          const SizedBox(height: 10),
          Text(
            [
              item.teacherName,
              item.subjectName,
              item.className,
            ].where((v) => v.isNotEmpty).join(' • '),
          ),
          const SizedBox(height: 8),
          Text('Eligible learners: ${item.totalStudents}'),
          Text('Marks entered: ${item.markedCount}'),
          Text('Missing marks: ${item.missingMarksCount}'),
          if (item.dueDate != null)
            Text('Due: ${DateFormat.yMMMd().format(item.dueDate!)}'),
          if (item.attachments.isNotEmpty)
            Text('Attachments: ${item.attachments.length}'),
        ],
      ),
    ),
  );
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: EmptyState(
      icon: Icons.error_outline,
      title: 'Could not load assessments',
      message: message,
      ctaLabel: 'Retry',
      onCtaPressed: onRetry,
    ),
  );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const SizedBox(height: 28),
      Container(height: 30, color: Colors.grey.withValues(alpha: .15)),
      const SizedBox(height: 10),
      Container(height: 18, color: Colors.grey.withValues(alpha: .1)),
      const SizedBox(height: 28),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.65,
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: .12),
              borderRadius: AppRadius.medium,
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      ...List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: .1),
              borderRadius: AppRadius.medium,
            ),
          ),
        ),
      ),
    ],
  );
}
