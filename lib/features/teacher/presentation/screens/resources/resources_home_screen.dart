import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

class ResourcesHomeScreen extends StatefulWidget {
  const ResourcesHomeScreen({super.key});

  @override
  State<ResourcesHomeScreen> createState() => _ResourcesHomeScreenState();
}

class _ResourcesHomeScreenState extends State<ResourcesHomeScreen> {
  ClassResourceKind? _filter;

  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassResourceBloc>().add(ClassResourcesRequested(active));
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = context.watch<ClassTeacherContextBloc>().state.active;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.folder_copy_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Resources',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (active?.className != null)
                    Text(
                      active!.className!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (active?.academicYearName.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      active!.academicYearName,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: BlocBuilder<ClassResourceBloc, ClassResourceState>(
        builder: (context, state) {
          final counts = <ClassResourceKind, int>{};
          for (final r in state.files) {
            counts[r.kind] = (counts[r.kind] ?? 0) + 1;
          }

          final filtered = state.recentFirst.where((r) {
            if (r.isFolder) return false;
            if (_filter != null && r.kind != _filter) return false;
            return true;
          }).toList();
          final recent = filtered.take(5);

          return RefreshIndicator(
            onRefresh: () async {
              final ctx = state.context;
              if (ctx != null) {
                context.read<ClassResourceBloc>().add(
                  ClassResourcesRequested(ctx, folderId: state.folderId),
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.l,
                AppSpacing.xl,
                AppSpacing.x3l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TotalResourcesCard(
                    total: state.files.length,
                    counts: counts,
                  ),
                  const SizedBox(height: AppSpacing.x2l),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.info_outline_rounded,
                        size: 17,
                        color: Theme.of(context).hintColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.m,
                    crossAxisSpacing: AppSpacing.m,
                    childAspectRatio: 0.92,
                    children: [
                      _QuickActionTile(
                        icon: Icons.cloud_upload_rounded,
                        label: 'Upload\nResource',
                        color: Colors.blue,
                        onTap: () => context.push('/staff/resources/upload'),
                      ),
                      _QuickActionTile(
                        icon: Icons.create_new_folder_rounded,
                        label: 'Create\nFolder',
                        color: Colors.green,
                        onTap: () =>
                            context.push('/staff/resources/create-folder'),
                      ),
                      _QuickActionTile(
                        icon: Icons.link_rounded,
                        label: 'Add Link',
                        color: Colors.deepPurple,
                        onTap: () => context.push('/staff/resources/add-link'),
                      ),
                      _QuickActionTile(
                        icon: Icons.folder_rounded,
                        label: 'View\nFolders',
                        color: Colors.amber,
                        onTap: () => context.push('/staff/resources/folders'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x2l),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _filter == null,
                          onTap: () => setState(() => _filter = null),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        _FilterChip(
                          label: 'Documents',
                          icon: Icons.description_outlined,
                          isSelected: _filter == ClassResourceKind.document,
                          onTap: () => setState(
                            () => _filter = ClassResourceKind.document,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        _FilterChip(
                          label: 'Videos',
                          icon: Icons.play_circle_outline_rounded,
                          isSelected: _filter == ClassResourceKind.video,
                          onTap: () => setState(
                            () => _filter = ClassResourceKind.video,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        _FilterChip(
                          label: 'Images',
                          icon: Icons.image_outlined,
                          isSelected: _filter == ClassResourceKind.image,
                          onTap: () => setState(
                            () => _filter = ClassResourceKind.image,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        _FilterChip(
                          label: 'Links',
                          icon: Icons.link_rounded,
                          isSelected: _filter == ClassResourceKind.link,
                          onTap: () => setState(
                            () => _filter = ClassResourceKind.link,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2l),

                  SectionHeader(
                    title: 'Recent Resources',
                    actionLabel: 'View All',
                    onActionPressed: () =>
                        context.push('/staff/resources/my-resources'),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.x4l),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filtered.isEmpty)
                    _NoResourcesEmptyState(
                      onUpload: () => context.push('/staff/resources/upload'),
                    )
                  else
                    for (final r in recent)
                      _RecentResourceCard(
                        resource: r,
                        onTap: () => context.push(
                          '/staff/resources/details',
                          extra: r,
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TotalResourcesCard extends StatelessWidget {
  final int total;
  final Map<ClassResourceKind, int> counts;

  const _TotalResourcesCard({required this.total, required this.counts});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Resources',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'This Term',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: _ResourceStat(
                  icon: Icons.description_outlined,
                  label: 'Documents',
                  count: counts[ClassResourceKind.document] ?? 0,
                  color: Colors.blue[200]!,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: _ResourceStat(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Videos',
                  count: counts[ClassResourceKind.video] ?? 0,
                  color: Colors.purple[200]!,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: _ResourceStat(
                  icon: Icons.link_rounded,
                  label: 'Links',
                  count: counts[ClassResourceKind.link] ?? 0,
                  color: Colors.orange[200]!,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: _ResourceStat(
                  icon: Icons.image_outlined,
                  label: 'Images',
                  count: counts[ClassResourceKind.image] ?? 0,
                  color: Colors.green[200]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResourceStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _ResourceStat({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.m,
      ),
      showShadow: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.onTap,
    this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentResourceCard extends StatelessWidget {
  final ClassResource resource;
  final VoidCallback onTap;

  const _RecentResourceCard({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = _iconFor(resource.kind);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconData.$2.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData.$1, color: iconData.$2),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  resource.isLink ? 'Link' : resource.sizeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }

  static (IconData, Color) _iconFor(ClassResourceKind kind) => switch (kind) {
    ClassResourceKind.document => (Icons.picture_as_pdf, Colors.red),
    ClassResourceKind.spreadsheet => (Icons.grid_on, Colors.green),
    ClassResourceKind.presentation => (Icons.slideshow, Colors.orange),
    ClassResourceKind.image => (Icons.image, Colors.green),
    ClassResourceKind.audio => (Icons.audiotrack, Colors.teal),
    ClassResourceKind.video => (Icons.videocam, Colors.purple),
    ClassResourceKind.link => (Icons.link, Colors.blue),
    ClassResourceKind.folder => (Icons.folder, Colors.amber),
    ClassResourceKind.other => (Icons.insert_drive_file, Colors.grey),
  };
}

class _NoResourcesEmptyState extends StatelessWidget {
  final VoidCallback onUpload;

  const _NoResourcesEmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.x3l,
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 44,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.l),
          const Text(
            'No resources yet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Upload documents, videos, images or links\nto share with your class.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Upload Your First Resource',
              icon: Icons.add,
              onPressed: onUpload,
            ),
          ),
        ],
      ),
    );
  }
}
