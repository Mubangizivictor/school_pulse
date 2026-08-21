import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_resource_repository.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Resources actually downloaded to this device. Reads
/// [ClassResourceRepository.isDownloaded] per resource rather than trusting
/// [ClassResource.availableOffline] alone - that flag is the server's record
/// of intent, but the bytes on this specific device are the only thing that
/// makes a resource usable with no signal.
class OfflineResourcesScreen extends StatefulWidget {
  const OfflineResourcesScreen({super.key});

  @override
  State<OfflineResourcesScreen> createState() =>
      _OfflineResourcesScreenState();
}

class _OfflineResourcesScreenState extends State<OfflineResourcesScreen> {
  Map<String, bool> _downloaded = {};

  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassResourceBloc>().add(ClassResourcesRequested(active));
    }
  }

  Future<void> _refreshDownloadState(List<ClassResource> resources) async {
    final repository = di.sl<ClassResourceRepository>();
    final entries = await Future.wait(
      resources.map(
        (r) async => MapEntry(r.id, await repository.isDownloaded(r.id)),
      ),
    );
    if (!mounted) return;
    setState(() => _downloaded = Map.fromEntries(entries));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Offline Resources')),
      body: BlocConsumer<ClassResourceBloc, ClassResourceState>(
        listener: (context, state) => _refreshDownloadState(state.files),
        builder: (context, state) {
          final marked = state.files
              .where((r) => _downloaded[r.id] == true)
              .toList();

          return marked.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'No resources downloaded yet. Open a file and choose '
                      '"Make available offline" to keep a copy on this '
                      'device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
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
                                color: Colors.green.withValues(alpha: 0.1),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Remove offline copy',
                              onPressed: () => context
                                  .read<ClassResourceBloc>()
                                  .add(ClassResourceDownloadRemoved(resource)),
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
