import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/teacher_workload.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

class TeacherWorkloadScreen extends StatelessWidget {
  const TeacherWorkloadScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<DeanBloc>()..add(TeacherWorkloadsRequested()),
    child: const _TeachingView(),
  );
}

class _TeachingView extends StatefulWidget {
  const _TeachingView();
  @override
  State<_TeachingView> createState() => _TeachingViewState();
}

class _TeachingViewState extends State<_TeachingView> {
  String _filter = 'Needs attention';
  void _reload() => context.read<DeanBloc>().add(TeacherWorkloadsRequested());
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    body: SafeArea(
      child: BlocBuilder<DeanBloc, DeanState>(
        builder: (c, s) {
          if (s is DeanLoading) return const _Skeleton();
          if (s is DeanError) {
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load teaching operations',
              message: s.message,
              ctaLabel: 'Retry',
              onCtaPressed: _reload,
            );
          }
          if (s is! TeacherWorkloadsLoaded) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'No teachers found',
              message: 'No teaching data is available for this school.',
              ctaLabel: 'Retry',
              onCtaPressed: _reload,
            );
          }
          final all = s.workloads;
          final visible = _apply(all);
          final attention = all.where(_needs).toList()..sort(_severity);
          final track = all.where((x) => !_needs(x)).toList();
          return LayoutBuilder(
            builder: (c, box) => RefreshIndicator(
              onRefresh: () async => _reload(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(box.maxWidth > 720 ? 24 : 16),
                    children: [
                      _Header(onRefresh: _reload),
                      const SizedBox(height: 16),
                      _Summary(all),
                      const SizedBox(height: 12),
                      _Selectors(),
                      const SizedBox(height: 12),
                      _Chips(
                        value: _filter,
                        onChanged: (v) => setState(() => _filter = v),
                      ),
                      const SizedBox(height: 20),
                      if (visible.isEmpty)
                        const EmptyState(
                          icon: Icons.search_off,
                          title: 'No teachers found',
                          message: 'No teachers match this filter.',
                        )
                      else ...[
                        if (_filter == 'Needs attention' ||
                            _filter == 'Missed lessons' ||
                            _filter == 'Pending marks')
                          _Section(
                            'Needs attention',
                            attention
                                .where((x) => visible.contains(x))
                                .toList(),
                            true,
                          ),
                        if ((_filter == 'All teachers' ||
                                _filter == 'No lesson today') &&
                            visible.isNotEmpty)
                          _Section('Teachers', visible, false),
                        if (_filter == 'Needs attention' && track.isNotEmpty)
                          _Section('On track', track.take(3).toList(), false),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  List<TeacherWorkload> _apply(List<TeacherWorkload> list) {
    return list.where((x) {
      return switch (_filter) {
        'All teachers' => true,
        'Missed lessons' => x.lessonsMissed > 0,
        'Pending marks' => x.marksPending > 0,
        'No lesson today' => x.weeklyLessonsCount == 0,
        _ => _needs(x),
      };
    }).toList();
  }

  bool _needs(TeacherWorkload x) => x.lessonsMissed > 0 || x.marksPending > 0;
  int _severity(TeacherWorkload a, TeacherWorkload b) =>
      (b.lessonsMissed * 100 + b.marksPending).compareTo(
        a.lessonsMissed * 100 + a.marksPending,
      );
}

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  const _Header({required this.onRefresh});
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teaching',
                  style: AppTypography.headlineLarge.copyWith(fontSize: 22),
                ),
                Text(
                  'Monitor lesson delivery and teacher follow-up',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary(c),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh teaching operations',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
          ),
        ],
      ),
    ],
  );
}

class _Summary extends StatelessWidget {
  final List<TeacherWorkload> x;
  const _Summary(this.x);
  @override
  Widget build(BuildContext c) {
    final scheduled = x.fold(0, (n, v) => n + v.weeklyLessonsCount);
    final delivered = x.fold(0, (n, v) => n + v.lessonsDelivered);
    final missed = x.fold(0, (n, v) => n + v.lessonsMissed);
    final pending = x.fold(0, (n, v) => n + v.marksPending);
    final percent = scheduled == 0
        ? 0
        : (delivered / scheduled * 100).round().clamp(0, 100);
    return LayoutBuilder(
      builder: (c, b) => GridView.count(
        crossAxisCount: b.maxWidth > 700 ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _Tile(
            'Teachers',
            x.length,
            Icons.groups_outlined,
            AppColors.information(c),
          ),
          _Tile(
            'Delivered',
            '$percent%',
            Icons.check_circle_outline,
            AppColors.success(c),
          ),
          _Tile(
            'Missed',
            missed,
            Icons.warning_amber_outlined,
            AppColors.danger(c),
          ),
          _Tile(
            'Pending marks',
            pending,
            Icons.note_alt_outlined,
            AppColors.warning(c),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String l;
  final Object v;
  final IconData i;
  final Color color;
  const _Tile(this.l, this.v, this.i, this.color);
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated(c),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(c)),
    ),
    child: Row(
      children: [
        Icon(i, color: color, size: 27),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$v',
              style: AppTypography.kpiStyle.copyWith(
                fontSize: 23,
                color: color,
              ),
            ),
            Text(l, style: AppTypography.bodyLarge.copyWith(fontSize: 13)),
          ],
        ),
      ],
    ),
  );
}

class _Selectors extends StatelessWidget {
  @override
  Widget build(BuildContext c) => Row(
    children: [
      Expanded(
        child: _Select(
          Icons.calendar_today,
          DateFormat('EEE, d MMM').format(DateTime.now()),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(child: _Select(Icons.account_tree_outlined, 'All departments')),
    ],
  );
}

class _Select extends StatelessWidget {
  final IconData i;
  final String l;
  const _Select(this.i, this.l);
  @override
  Widget build(BuildContext c) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border(c)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(i, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(l, overflow: TextOverflow.ellipsis)),
        const Icon(Icons.keyboard_arrow_down),
      ],
    ),
  );
}

class _Chips extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _Chips({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext c) {
    const a = [
      'Needs attention',
      'All teachers',
      'Missed lessons',
      'Pending marks',
      'No lesson today',
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: a.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ChoiceChip(
          label: Text(a[i], style: const TextStyle(fontSize: 12)),
          selected: value == a[i],
          onSelected: (_) => onChanged(a[i]),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<TeacherWorkload> rows;
  final bool attention;
  const _Section(this.title, this.rows, this.attention);
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(fontSize: 17),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: (attention ? AppColors.danger(c) : AppColors.success(c)),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${rows.length}',
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      ...rows.map((x) => _Row(x, attention)),
    ],
  );
}

class _Row extends StatelessWidget {
  final TeacherWorkload x;
  final bool attention;
  const _Row(this.x, this.attention);
  @override
  Widget build(BuildContext c) {
    final subject = x.assignedSubjects.isEmpty
        ? 'No subject assigned'
        : x.assignedSubjects.first.subjectName;
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: c,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '${x.teacherName}\n$subject\n${x.weeklyLessonsCount} lessons/week',
            ),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border(c))),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 64,
              decoration: BoxDecoration(
                color: attention ? AppColors.danger(c) : AppColors.success(c),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            AvatarInitials(name: x.teacherName, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    x.teacherName,
                    style: AppTypography.titleLarge.copyWith(fontSize: 15),
                  ),
                  Text(
                    '$subject  •  ${x.weeklyLessonsCount} lessons/week',
                    style: AppTypography.bodyLarge.copyWith(fontSize: 12),
                  ),
                  if (attention)
                    Wrap(
                      spacing: 6,
                      children: [
                        if (x.lessonsMissed > 0)
                          _Badge(
                            '${x.lessonsMissed} missed',
                            AppColors.danger(c),
                          ),
                        if (x.marksPending > 0)
                          _Badge(
                            '${x.marksPending} marks pending',
                            AppColors.warning(c),
                          ),
                      ],
                    )
                  else
                    Text(
                      'On track',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.success(c),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              attention ? 'Review' : '',
              style: TextStyle(color: AppColors.information(c)),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String l;
  final Color c;
  const _Badge(this.l, this.c);
  @override
  Widget build(BuildContext x) => Container(
    margin: const EdgeInsets.only(top: 5),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: c),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(l, style: TextStyle(fontSize: 11, color: c)),
  );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Skeleton(width: 140, height: 28),
      const SizedBox(height: 8),
      const Skeleton(width: 260, height: 14),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.7,
        children: const [Skeleton(), Skeleton(), Skeleton(), Skeleton()],
      ),
    ],
  );
}
