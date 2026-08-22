import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

class ResourceCategoriesScreen extends StatefulWidget {
  const ResourceCategoriesScreen({super.key});

  @override
  State<ResourceCategoriesScreen> createState() =>
      _ResourceCategoriesScreenState();
}

class _ResourceCategoriesScreenState extends State<ResourceCategoriesScreen> {
  String _query = '';

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
      appBar: AppBar(title: const Text('Resource Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppSearchField(
              hintText: 'Search categories...',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: BlocBuilder<ClassResourceBloc, ClassResourceState>(
              builder: (context, state) {
                final counts = <ClassResourceKind, int>{};
                for (final r in state.files) {
                  counts[r.kind] = (counts[r.kind] ?? 0) + 1;
                }

                final categories =
                    [
                      (
                        icon: Icons.grid_view_outlined,
                        label: 'All Resources',
                        count: state.files.length,
                        color: Colors.blue,
                        kind: null,
                      ),
                      (
                        icon: Icons.description_outlined,
                        label: 'Documents',
                        count: counts[ClassResourceKind.document] ?? 0,
                        color: Colors.red,
                        kind: ClassResourceKind.document,
                      ),
                      (
                        icon: Icons.play_circle_outline,
                        label: 'Videos',
                        count: counts[ClassResourceKind.video] ?? 0,
                        color: Colors.purple,
                        kind: ClassResourceKind.video,
                      ),
                      (
                        icon: Icons.image_outlined,
                        label: 'Images',
                        count: counts[ClassResourceKind.image] ?? 0,
                        color: Colors.green,
                        kind: ClassResourceKind.image,
                      ),
                      (
                        icon: Icons.link_outlined,
                        label: 'Links',
                        count: counts[ClassResourceKind.link] ?? 0,
                        color: Colors.orange,
                        kind: ClassResourceKind.link,
                      ),
                      (
                        icon: Icons.audiotrack_outlined,
                        label: 'Audio',
                        count: counts[ClassResourceKind.audio] ?? 0,
                        color: Colors.teal,
                        kind: ClassResourceKind.audio,
                      ),
                      (
                        icon: Icons.more_horiz_outlined,
                        label: 'Others',
                        count: counts[ClassResourceKind.other] ?? 0,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        kind: ClassResourceKind.other,
                      ),
                    ].where(
                      (c) =>
                          _query.isEmpty ||
                          c.label.toLowerCase().contains(_query.toLowerCase()),
                    );

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  children: [
                    for (final category in categories)
                      _CategoryItem(
                        icon: category.icon,
                        label: category.label,
                        count: category.count,
                        color: category.color,
                        onTap: () =>
                            context.push('/staff/resources/my-resources'),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor),
        ],
      ),
    );
  }
}
