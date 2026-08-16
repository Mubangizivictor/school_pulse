import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

/// Resources marked for offline use. The repository already carries
/// [ClassResource.availableOffline], but on-device caching (actually storing
/// the bytes locally, the way attendance and the dashboard use Isar) is not
/// built yet - so this screen shows the marked list honestly rather than
/// pretending files are downloaded.
class OfflineResourcesScreen extends StatefulWidget {
  const OfflineResourcesScreen({super.key});

  @override
  State<OfflineResourcesScreen> createState() =>
      _OfflineResourcesScreenState();
}

class _OfflineResourcesScreenState extends State<OfflineResourcesScreen> {
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
      appBar: AppBar(title: const Text('Offline Resources')),
      body: BlocBuilder<ClassResourceBloc, ClassResourceState>(
        builder: (context, state) {
          final marked = state.files.where((r) => r.availableOffline).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppCard(
                  color: Theme.of(context).colorScheme.primary.withValues(
                    alpha: 0.08,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'On-device offline downloads are coming soon. '
                          'Resources marked below will sync automatically '
                          'once that ships.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: marked.isEmpty
                    ? Center(
                        child: Text(
                          'No resources marked for offline yet.',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        children: [
                          for (final resource in marked)
                            AppCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.insert_drive_file,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resource.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          resource.sizeLabel,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.bookmark,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
