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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Resources')),
      body: BlocBuilder<ClassResourceBloc, ClassResourceState>(
        builder: (context, state) {
          final counts = <ClassResourceKind, int>{};
          for (final r in state.files) {
            counts[r.kind] = (counts[r.kind] ?? 0) + 1;
          }
          final recent = state.recentFirst.where((r) => !r.isFolder).take(1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  color: Theme.of(context).colorScheme.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Resources',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.files.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'This Term',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ResourceStat(
                            label: 'Documents',
                            count: counts[ClassResourceKind.document] ?? 0,
                            color: Colors.blue[200]!,
                          ),
                          _ResourceStat(
                            label: 'Videos',
                            count: counts[ClassResourceKind.video] ?? 0,
                            color: Colors.purple[200]!,
                          ),
                          _ResourceStat(
                            label: 'Links',
                            count: counts[ClassResourceKind.link] ?? 0,
                            color: Colors.orange[200]!,
                          ),
                          _ResourceStat(
                            label: 'Images',
                            count: counts[ClassResourceKind.image] ?? 0,
                            color: Colors.green[200]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x3l),

                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: AppSpacing.l),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _QuickActionTile(
                        icon: Icons.upload_file_outlined,
                        label: 'Upload Resource',
                        onTap: () => context.push('/staff/resources/upload'),
                      ),
                      _QuickActionTile(
                        icon: Icons.create_new_folder_outlined,
                        label: 'Create Folder',
                        onTap: () =>
                            context.push('/staff/resources/create-folder'),
                      ),
                      _QuickActionTile(
                        icon: Icons.link_outlined,
                        label: 'Add Link',
                        onTap: () => context.push('/staff/resources/add-link'),
                      ),
                      _QuickActionTile(
                        icon: Icons.folder_outlined,
                        label: 'Folders',
                        onTap: () => context.push('/staff/resources/folders'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x3l),

                SectionHeader(
                  title: 'Recent Resources',
                  actionLabel: 'View All',
                  onActionPressed: () =>
                      context.push('/staff/resources/my-resources'),
                ),
                const SizedBox(height: AppSpacing.l),
                if (recent.isEmpty)
                  Text(
                    'Nothing uploaded yet.',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  )
                else
                  for (final r in recent)
                    AppCard(
                      onTap: () => context.push(
                        '/staff/resources/details',
                        extra: r,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  r.isLink ? 'Link' : r.sizeLabel,
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
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResourceStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ResourceStat({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: onTap,
        ),
        Divider(
          height: 1,
          indent: 56,
          endIndent: 16,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
