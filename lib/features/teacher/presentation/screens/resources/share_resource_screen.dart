import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';

class ShareResourceScreen extends StatefulWidget {
  final ClassResource? resource;
  const ShareResourceScreen({super.key, this.resource});

  @override
  State<ShareResourceScreen> createState() => _ShareResourceScreenState();
}

class _ShareResourceScreenState extends State<ShareResourceScreen> {
  late ClassResourceAudience _audience;

  @override
  void initState() {
    super.initState();
    _audience = widget.resource?.audience ?? ClassResourceAudience.teacherOnly;
  }

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    if (resource == null) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Share Resource')),
        body: const Center(
          child: Text('This resource is no longer available.'),
        ),
      );
    }

    return BlocListener<ClassResourceBloc, ClassResourceState>(
      listenWhen: (previous, current) =>
          previous.successMessage != current.successMessage &&
          current.successMessage != null,
      listener: (context, state) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Share Resource')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        resource.isLink ? Icons.link : Icons.insert_drive_file,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            resource.isLink ? 'Link' : resource.sizeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),

              const Text(
                'Share With',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.l),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ShareOption(
                      icon: Icons.lock_outline,
                      label: 'Only me',
                      subtitle: 'Not visible to the class',
                      selected: _audience == ClassResourceAudience.teacherOnly,
                      onTap: () => setState(
                        () => _audience = ClassResourceAudience.teacherOnly,
                      ),
                    ),
                    _ShareOption(
                      icon: Icons.people_outline,
                      label: 'My class',
                      subtitle: 'Visible to students',
                      selected: _audience == ClassResourceAudience.students,
                      onTap: () => setState(
                        () => _audience = ClassResourceAudience.students,
                      ),
                    ),
                    _ShareOption(
                      icon: Icons.family_restroom_outlined,
                      label: 'Class and guardians',
                      subtitle: 'Visible to students and parents',
                      selected:
                          _audience ==
                          ClassResourceAudience.studentsAndGuardians,
                      isLast: true,
                      onTap: () => setState(
                        () => _audience =
                            ClassResourceAudience.studentsAndGuardians,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              BlocBuilder<ClassResourceBloc, ClassResourceState>(
                builder: (context, state) => PrimaryButton(
                  label: 'Share Resource',
                  onPressed: state.isSaving
                      ? null
                      : () => context.read<ClassResourceBloc>().add(
                          ClassResourceShared(resource, _audience),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
          ),
          trailing: selected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : const Icon(Icons.radio_button_unchecked),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
