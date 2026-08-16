import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

class StorageUsageScreen extends StatefulWidget {
  const StorageUsageScreen({super.key});

  @override
  State<StorageUsageScreen> createState() => _StorageUsageScreenState();
}

class _StorageUsageScreenState extends State<StorageUsageScreen> {
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
      appBar: AppBar(title: const Text('Storage Usage')),
      body: BlocBuilder<ClassResourceBloc, ClassResourceState>(
        builder: (context, state) {
          final usage = state.storageUsage;
          final fraction = usage.fraction;
          final byKind = <ClassResourceKind, int>{};
          for (final r in state.files) {
            byKind[r.kind] = (byKind[r.kind] ?? 0) + (r.sizeBytes ?? 0);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                AppCard(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: fraction,
                          strokeWidth: 12,
                          backgroundColor: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.1),
                          color: Theme.of(context).colorScheme.primary,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Storage Used',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          Text(
                            _formatBytes(usage.usedBytes),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            fraction == null
                                ? '${usage.fileCount} files'
                                : 'of ${_formatBytes(usage.quotaBytes)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x3l),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _StorageItem(
                        label: 'Documents',
                        bytes: byKind[ClassResourceKind.document] ?? 0,
                        color: Colors.blue,
                      ),
                      _StorageItem(
                        label: 'Videos',
                        bytes: byKind[ClassResourceKind.video] ?? 0,
                        color: Colors.purple,
                      ),
                      _StorageItem(
                        label: 'Images',
                        bytes: byKind[ClassResourceKind.image] ?? 0,
                        color: Colors.green,
                      ),
                      _StorageItem(
                        label: 'Others',
                        bytes: byKind[ClassResourceKind.other] ?? 0,
                        color: Colors.orange,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Manage Storage',
                  onPressed: () =>
                      context.push('/staff/resources/my-resources'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

class _StorageItem extends StatelessWidget {
  final String label;
  final int bytes;
  final Color color;
  final bool isLast;

  const _StorageItem({
    required this.label,
    required this.bytes,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                _formatBytes(bytes),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 44,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
