import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';

class CreateFolderScreen extends StatefulWidget {
  const CreateFolderScreen({super.key});

  @override
  State<CreateFolderScreen> createState() => _CreateFolderScreenState();
}

class _CreateFolderScreenState extends State<CreateFolderScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClassResourceBloc, ClassResourceState>(
      listenWhen: (previous, current) =>
          previous.successMessage != current.successMessage &&
          current.successMessage != null,
      listener: (context, state) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Create Folder')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name *',
                  hintText: 'Enter folder name',
                ),
              ),
              const SizedBox(height: 40),
              BlocBuilder<ClassResourceBloc, ClassResourceState>(
                builder: (context, state) => Column(
                  children: [
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.l),
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(color: AppColors.danger(context)),
                        ),
                      ),
                    PrimaryButton(
                      label: 'Create Folder',
                      onPressed: state.isSaving
                          ? null
                          : () {
                              final name = _nameController.text.trim();
                              if (name.length < 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Give the folder a name.'),
                                  ),
                                );
                                return;
                              }
                              context.read<ClassResourceBloc>().add(
                                ClassResourceFolderCreated(name: name),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
