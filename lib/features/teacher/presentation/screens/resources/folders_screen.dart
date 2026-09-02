import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
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
      appBar: AppBar(title: const Text('Folders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppSearchField(
              hintText: 'Search folders...',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: BlocBuilder<ClassResourceBloc, ClassResourceState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final folders = state.folders.where((f) {
                  if (_query.isEmpty) return true;
                  return f.name.toLowerCase().contains(_query.toLowerCase());
                }).toList();

                if (folders.isEmpty) {
                  return Center(
                    child: Text(
                      'No folders yet. Tap + to create one.',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  children: [
                    for (final folder in folders)
                      _FolderItem(
                        folder: folder,
                        resourceCount: state.resources
                            .where((r) => r.folderId == folder.id)
                            .length,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/staff/resources/create-folder'),
        tooltip: 'Create folder',
        child: const Icon(Icons.add, semanticLabel: 'Create folder'),
      ),
    );
  }
}

class _FolderItem extends StatelessWidget {
  final ClassResource folder;
  final int resourceCount;

  const _FolderItem({required this.folder, required this.resourceCount});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.black, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$resourceCount resources',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor),
        ],
      ),
    );
  }
}
