import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';

class ClassResourcesScreen extends StatefulWidget {
  final String classId;
  const ClassResourcesScreen({super.key, required this.classId});

  @override
  State<ClassResourcesScreen> createState() => _ClassResourcesScreenState();
}

class _ClassResourcesScreenState extends State<ClassResourcesScreen> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.textPrimary(context);

    return BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
      builder: (context, contextState) {
        final active = contextState.active;
        final placement = active == null
            ? ''
            : [
                active.className,
                active.streamName,
              ].where((e) => e != null && e.isNotEmpty).join(' ');

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Resources',
                  style: AppTypography.titleLarge.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  placement.isEmpty ? 'No class assigned' : placement,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: primaryColor),
                onPressed: active == null
                    ? null
                    : () => context.push('/staff/resources/upload'),
              ),
            ],
          ),
          body: active == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'You are not currently the Class Teacher for any '
                      'class, so there are no resources to show.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ),
                )
              : BlocConsumer<ClassResourceBloc, ClassResourceState>(
                  listenWhen: (previous, current) =>
                      previous.errorMessage != current.errorMessage ||
                      previous.successMessage != current.successMessage,
                  listener: (context, state) {
                    final message = state.successMessage ?? state.errorMessage;
                    if (message == null) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(message)));
                  },
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.resources.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            'No resources yet. Tap + to upload one for '
                            'your class.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => context
                          .read<ClassResourceBloc>()
                          .add(ClassResourcesRequested(active)),
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        children: [
                          if (state.folders.isNotEmpty) ...[
                            _buildCategoryHeader(
                              'Folders',
                              Icons.folder,
                              isDark,
                            ),
                            for (final folder in state.folders)
                              _buildResourceItem(
                                context,
                                folder,
                                isDark,
                                onTap: () =>
                                    context.push('/staff/resources/folders'),
                              ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                          if (state.files.isNotEmpty) ...[
                            _buildCategoryHeader(
                              'Files & Links',
                              Icons.auto_stories,
                              isDark,
                            ),
                            for (final file in state.files)
                              _buildResourceItem(
                                context,
                                file,
                                isDark,
                                onTap: () => context.push(
                                  '/staff/resources/details',
                                  extra: file,
                                ),
                              ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.royalBlue),
          const SizedBox(width: AppSpacing.s),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(
    BuildContext context,
    ClassResource resource,
    bool isDark, {
    required VoidCallback onTap,
  }) {
    final iconData = _iconFor(resource.kind);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: PulseCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: iconData.$2.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.s),
              ),
              child: Icon(iconData.$1, color: iconData.$2, size: 24),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    resource.isFolder
                        ? 'Folder'
                        : (resource.sizeLabel.isEmpty
                              ? resource.kind.name
                              : resource.sizeLabel),
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _iconFor(ClassResourceKind kind) => switch (kind) {
    ClassResourceKind.document => (Icons.picture_as_pdf, Colors.red),
    ClassResourceKind.spreadsheet => (Icons.grid_on, Colors.green),
    ClassResourceKind.presentation => (Icons.slideshow, Colors.orange),
    ClassResourceKind.image => (Icons.image, Colors.green),
    ClassResourceKind.audio => (Icons.audiotrack, Colors.teal),
    ClassResourceKind.video => (Icons.videocam, Colors.purple),
    ClassResourceKind.link => (Icons.link, Colors.blue),
    ClassResourceKind.folder => (Icons.folder, Colors.amber),
    ClassResourceKind.other => (
      Icons.insert_drive_file,
      AppColors.textMutedLight,
    ),
  };
}
