import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';

class AddLinkScreen extends StatefulWidget {
  const AddLinkScreen({super.key});

  @override
  State<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends State<AddLinkScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
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
        appBar: AppBar(title: const Text('Add Link')),
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
                    Icons.link,
                    color: Theme.of(context).colorScheme.primary,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Link Title *',
                  hintText: 'Enter link title',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Enter URL *',
                  hintText: 'https://',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add description',
                  alignLabelWithHint: true,
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
                      label: 'Add Link',
                      onPressed: state.isSaving
                          ? null
                          : () {
                              final name = _titleController.text.trim();
                              final url = _urlController.text.trim();
                              if (name.isEmpty || url.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Title and URL are required.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              context.read<ClassResourceBloc>().add(
                                ClassResourceLinkAdded(name: name, url: url),
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
