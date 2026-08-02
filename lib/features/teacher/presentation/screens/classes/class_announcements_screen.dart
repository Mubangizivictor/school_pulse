import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_announcement.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_announcements/class_announcements_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';

class ClassAnnouncementsScreen extends StatefulWidget {
  final String classId;
  const ClassAnnouncementsScreen({super.key, required this.classId});

  @override
  State<ClassAnnouncementsScreen> createState() =>
      _ClassAnnouncementsScreenState();
}

class _ClassAnnouncementsScreenState extends State<ClassAnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context
          .read<ClassAnnouncementsBloc>()
          .add(ClassAnnouncementsRequested(active));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
      builder: (context, contextState) {
        final active = contextState.active;
        final placement = active == null
            ? ''
            : [active.className, active.streamName]
                .where((e) => e != null && e.isNotEmpty)
                .join(' ');

        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
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
                  'Announcements',
                  style: AppTypography.titleLarge
                      .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
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
          ),
          body: active == null
              ? _message(
                  context,
                  isDark,
                  'You are not currently the Class Teacher for any class, so '
                  'there are no announcements to post.',
                )
              : BlocConsumer<ClassAnnouncementsBloc, ClassAnnouncementsState>(
                  listenWhen: (previous, current) =>
                      previous.errorMessage != current.errorMessage ||
                      previous.successMessage != current.successMessage,
                  listener: (context, state) {
                    final message = state.successMessage ?? state.errorMessage;
                    if (message == null) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(message),
                        backgroundColor: state.successMessage != null
                            ? AppColors.success(context)
                            : AppColors.danger(context),
                      ));
                    context
                        .read<ClassAnnouncementsBloc>()
                        .add(const ClassAnnouncementsFeedbackCleared());
                  },
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary(context),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: state.announcements.isEmpty
                              ? _message(
                                  context,
                                  isDark,
                                  'No announcements have been posted to your '
                                  'class yet.',
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  itemCount: state.announcements.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: AppSpacing.m),
                                  itemBuilder: (context, index) =>
                                      _buildAnnouncementItem(
                                    context,
                                    state,
                                    state.announcements[index],
                                    isDark,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: PulseButton(
                            label: 'New Announcement',
                            icon: Icons.add,
                            onPressed: () => _showComposer(context, state),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _message(BuildContext context, bool isDark, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem(
    BuildContext context,
    ClassAnnouncementsState state,
    ClassAnnouncement announcement,
    bool isDark,
  ) {
    final status = announcement.effectiveStatus();
    final color = _colorFor(context, status);

    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.s),
                ),
                child: Icon(_iconFor(status), color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _subtitleFor(announcement, status),
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                onSelected: (value) {
                  final bloc = context.read<ClassAnnouncementsBloc>();
                  if (value == 'publish') {
                    bloc.add(ClassAnnouncementPublished(announcement));
                  } else if (value == 'archive') {
                    bloc.add(ClassAnnouncementArchived(announcement));
                  }
                },
                itemBuilder: (menuContext) => [
                  // Sending is offered only on drafts, and only to a teacher
                  // who holds the publish permission.
                  if (announcement.isDraft && state.canPublish)
                    const PopupMenuItem(value: 'publish', child: Text('Send now')),
                  if (status != ClassAnnouncementStatus.archived)
                    const PopupMenuItem(value: 'archive', child: Text('Archive')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            announcement.body,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Delivery is stated, not implied: a teacher should be able to see that a
  /// notice actually reached somebody.
  static String _subtitleFor(
    ClassAnnouncement announcement,
    ClassAnnouncementStatus status,
  ) {
    final when = announcement.publishedAt ??
        announcement.scheduledFor ??
        announcement.createdAt;
    final stamp = DateFormat('d MMM yyyy • HH:mm').format(when);

    return switch (status) {
      ClassAnnouncementStatus.published =>
        '$stamp • sent to ${announcement.recipientCount}',
      ClassAnnouncementStatus.scheduled => 'Scheduled for $stamp',
      ClassAnnouncementStatus.draft => 'Draft • $stamp',
      ClassAnnouncementStatus.expired => 'Expired • $stamp',
      ClassAnnouncementStatus.archived => 'Archived • $stamp',
    };
  }

  static IconData _iconFor(ClassAnnouncementStatus status) => switch (status) {
        ClassAnnouncementStatus.published => Icons.campaign,
        ClassAnnouncementStatus.scheduled => Icons.schedule,
        ClassAnnouncementStatus.draft => Icons.edit_note,
        ClassAnnouncementStatus.expired => Icons.history_toggle_off,
        ClassAnnouncementStatus.archived => Icons.inventory_2_outlined,
      };

  static Color _colorFor(BuildContext context, ClassAnnouncementStatus status) =>
      switch (status) {
        ClassAnnouncementStatus.published => AppColors.successGreen,
        ClassAnnouncementStatus.scheduled => AppColors.royalBlue,
        ClassAnnouncementStatus.draft => AppColors.textMuted(context),
        ClassAnnouncementStatus.expired ||
        ClassAnnouncementStatus.archived =>
          AppColors.textMuted(context),
      };

  Future<void> _showComposer(
    BuildContext context,
    ClassAnnouncementsState state,
  ) async {
    final bloc = context.read<ClassAnnouncementsBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: _AnnouncementComposer(canPublish: state.canPublish),
      ),
    );
  }
}

class _AnnouncementComposer extends StatefulWidget {
  final bool canPublish;

  const _AnnouncementComposer({required this.canPublish});

  @override
  State<_AnnouncementComposer> createState() => _AnnouncementComposerState();
}

class _AnnouncementComposerState extends State<_AnnouncementComposer> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  ClassAnnouncementAudience _audience = ClassAnnouncementAudience.both;
  DateTime? _expiresAt;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New Announcement',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _bodyController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Message'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.m),
            // Both options stay inside the class either way - this only picks
            // whether the students, the guardians, or both are told.
            DropdownButtonFormField<ClassAnnouncementAudience>(
              initialValue: _audience,
              decoration: const InputDecoration(labelText: 'Send to'),
              items: const [
                DropdownMenuItem(
                  value: ClassAnnouncementAudience.both,
                  child: Text('Students and guardians'),
                ),
                DropdownMenuItem(
                  value: ClassAnnouncementAudience.students,
                  child: Text('Students only'),
                ),
                DropdownMenuItem(
                  value: ClassAnnouncementAudience.guardians,
                  child: Text('Guardians only'),
                ),
              ],
              onChanged: (value) => setState(
                () => _audience = value ?? ClassAnnouncementAudience.both,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Expires',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              subtitle: Text(
                _expiresAt == null
                    ? 'Stays until archived'
                    : DateFormat('d MMM yyyy').format(_expiresAt!),
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
              trailing:
                  Icon(Icons.calendar_today, color: AppColors.primary(context)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _expiresAt ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _expiresAt = picked);
              },
            ),
            const SizedBox(height: AppSpacing.l),
            if (widget.canPublish) ...[
              PulseButton(
                label: 'Send Now',
                onPressed: _canSave ? () => _submit(publish: true) : null,
              ),
              const SizedBox(height: AppSpacing.m),
            ],
            PulseButton(
              label: 'Save as Draft',
              variant: PulseButtonVariant.secondary,
              onPressed: _canSave ? () => _submit(publish: false) : null,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  bool get _canSave =>
      _titleController.text.trim().length >= 3 &&
      _bodyController.text.trim().length >= 5;

  void _submit({required bool publish}) {
    context.read<ClassAnnouncementsBloc>().add(ClassAnnouncementSaved(
          ClassAnnouncement(
            id: '',
            // Coordinates are stamped by the repository from the verified
            // context; the composer supplies only what the teacher typed.
            schoolId: '',
            classId: '',
            academicYearId: '',
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            audience: _audience,
            expiresAt: _expiresAt,
            createdAt: DateTime.now(),
          ),
          publish: publish,
        ));
    Navigator.of(context).pop();
  }
}
