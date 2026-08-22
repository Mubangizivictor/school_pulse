import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';

class UploadResourceScreen extends StatefulWidget {
  const UploadResourceScreen({super.key});

  @override
  State<UploadResourceScreen> createState() => _UploadResourceScreenState();
}

class _UploadResourceScreenState extends State<UploadResourceScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  PlatformFile? _picked;
  ClassResourceAudience _audience = ClassResourceAudience.teacherOnly;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(withData: true);
    final file = result?.files.singleOrNull;
    if (file == null) return;
    setState(() {
      _picked = file;
      if (_titleController.text.isEmpty) {
        _titleController.text = file.name;
      }
    });
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
        appBar: AppBar(title: const Text('Upload Resource')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _pickFile,
                child: AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  borderColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _picked == null
                                ? Icons.cloud_upload_outlined
                                : Icons.insert_drive_file,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _picked == null
                              ? 'Tap to choose a file'
                              : '${_picked!.name}\n'
                                    '${(_picked!.size / 1024).toStringAsFixed(0)} KB',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),

              const Text(
                'Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.l),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter resource title',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add a short description',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              DropdownButtonFormField<ClassResourceAudience>(
                decoration: const InputDecoration(labelText: 'Share with'),
                initialValue: _audience,
                items: ClassResourceAudience.values
                    .map(
                      (a) => DropdownMenuItem(value: a, child: Text(a.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _audience = v ?? _audience),
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
                      label: 'Upload Resource',
                      onPressed: state.isSaving
                          ? null
                          : () {
                              final picked = _picked;
                              if (picked?.bytes == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Choose a file to upload.'),
                                  ),
                                );
                                return;
                              }
                              context.read<ClassResourceBloc>().add(
                                ClassResourceUploaded(
                                  fileName: picked!.name,
                                  bytes: picked.bytes!,
                                  description:
                                      _descriptionController.text.trim().isEmpty
                                      ? null
                                      : _descriptionController.text.trim(),
                                  audience: _audience,
                                ),
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
