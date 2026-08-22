import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

/// Uploads to the class's resource area, newest first. This is the resource
/// area's own log, not the school-wide audit trail - it reads what
/// [ClassResourceRepository] already returns rather than a second feed.
class RecentActivityScreen extends StatefulWidget {
  const RecentActivityScreen({super.key});

  @override
  State<RecentActivityScreen> createState() => _RecentActivityScreenState();
}

class _RecentActivityScreenState extends State<RecentActivityScreen> {
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
      appBar: AppBar(title: const Text('Recent Activity')),
      body: BlocBuilder<ClassResourceBloc, ClassResourceState>(
        builder: (context, state) {
          final recent = state.recentFirst;
          if (recent.isEmpty) {
            return Center(
              child: Text(
                'Nothing uploaded yet.',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              for (final resource in recent)
                _ActivityItem(
                  resource: resource,
                  onTap: () =>
                      context.push('/staff/resources/details', extra: resource),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ClassResource resource;
  final VoidCallback onTap;

  const _ActivityItem({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = resource.isFolder
        ? (Icons.create_new_folder_outlined, Colors.orange)
        : resource.isLink
        ? (Icons.link_outlined, Colors.purple)
        : (Icons.upload_file_outlined, Colors.red);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconData.$2.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData.$1, color: iconData.$2, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.isFolder
                      ? 'Folder created'
                      : resource.isLink
                      ? 'Link added'
                      : 'File uploaded',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  resource.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _timeAgo(resource.uploadedAt),
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
