import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_attendance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_attendance/class_attendance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_dashboard/class_teacher_dashboard_bloc.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  void _open() {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null) return;
    context.read<ClassAttendanceBloc>().add(
      ClassAttendanceOpened(active, date: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Take Attendance',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: AppColors.primary(context)),
            onPressed: () => context.go('/staff/roll-call/history'),
          ),
        ],
      ),
      body: BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
        builder: (context, contextState) {
          if (contextState.active == null) {
            return const EmptyState(
              icon: Icons.class_outlined,
              title: 'No class assigned',
              message:
                  'Your account has no active Class Teacher assignment, so '
                  'there is no register to take. Ask your school admin to '
                  'assign you a class.',
            );
          }

          return BlocConsumer<ClassAttendanceBloc, ClassAttendanceState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage ||
                previous.successMessage != current.successMessage ||
                previous.isSubmitted != current.isSubmitted,
            listener: (context, state) {
              // The Home tab's attendance card and "Needs your attention"
              // both read ClassTeacherDashboardBloc, which has no way to
              // know a register was just submitted here - without this, a
              // teacher who submits and taps Home sees stale "Not taken"
              // figures until something else happens to trigger a refetch.
              if (state.isSubmitted && contextState.active != null) {
                context.read<ClassTeacherDashboardBloc>().add(
                  ClassDashboardRequested(
                    contextState.active!,
                    forceRefresh: true,
                  ),
                );
              }
              final message = state.successMessage ?? state.errorMessage;
              if (message == null) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: state.successMessage != null
                        ? AppColors.success(context)
                        : AppColors.danger(context),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              context.read<ClassAttendanceBloc>().add(
                const ClassAttendanceFeedbackCleared(),
              );
            },
            builder: (context, state) {
              if (state.isLoading) return const _AttendanceSkeleton();

              if (state.students.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No students yet',
                  message:
                      'No students have been placed in your class for this '
                      'academic year, so there is nobody to mark.',
                );
              }

              final visible = state.visibleStudents;

              return Column(
                children: [
                  _buildStatusBanner(context, state),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                      vertical: AppSpacing.s,
                    ),
                    child: AppSearchField(
                      hintText: 'Search students...',
                      onChanged: (value) => context
                          .read<ClassAttendanceBloc>()
                          .add(ClassAttendanceSearched(value)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                      vertical: AppSpacing.s,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${visible.length} Students',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: state.isSaving || !state.isEditable
                              ? null
                              : () => context.read<ClassAttendanceBloc>().add(
                                  ClassAttendanceAllMarked(_presentCode(state)),
                                ),
                          icon: Icon(
                            Icons.done_all,
                            size: 18,
                            color: AppColors.primary(context),
                          ),
                          label: Text(
                            'Mark all present',
                            style: TextStyle(color: AppColors.primary(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off,
                            title: 'No results',
                            message:
                                'No students found matching your search query.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.l,
                            ),
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final student = visible[index];
                              return FadeInSlide(
                                delay: Duration(milliseconds: index * 30),
                                child: AppCard(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  color: AppColors.surfaceElevated(context),
                                  child: Row(
                                    children: [
                                      AvatarInitials(
                                        name: student.name,
                                        size: 40,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name,
                                              style: TextStyle(
                                                color: AppColors.textPrimary(
                                                  context,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              student.admissionNumber,
                                              style: AppTypography.labelSmall
                                                  .copyWith(
                                                    color: AppColors.textMuted(
                                                      context,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildStatusToggle(
                                        context,
                                        state,
                                        student.studentId,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  _buildSubmitBar(context, state),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// The code the "Mark all present" shortcut uses. Taken from the school's
  /// configured options rather than assumed, so a school whose present status
  /// is called something else still gets a working shortcut.
  static String _presentCode(ClassAttendanceState state) {
    final present = state.options
        .where((o) => o.classification == AttendanceClassification.present)
        .firstOrNull;
    return present?.code ?? 'present';
  }

  /// Says what state the register is in, because "why can't I tap anything"
  /// is otherwise the teacher's first question on a submitted register.
  Widget _buildStatusBanner(BuildContext context, ClassAttendanceState state) {
    final (message, color, icon) = state.isLocked
        ? (
            'Closed by the academic office.',
            AppColors.danger(context),
            Icons.lock_outline,
          )
        : state.isSubmitted
        ? (
            state.isEditable
                ? 'Submitted. Tap a student to correct their mark.'
                : 'Submitted. You do not have permission to change it.',
            AppColors.success(context),
            Icons.check_circle_outline,
          )
        : state.unmarkedCount > 0
        ? (
            '${state.unmarkedCount} of ${state.students.length} still '
                'to mark.',
            AppColors.warning(context),
            Icons.pending_outlined,
          )
        : (
            'All students marked. Ready to submit.',
            AppColors.primary(context),
            Icons.done_all,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One button per status the school configured - not a fixed three.
  Widget _buildStatusToggle(
    BuildContext context,
    ClassAttendanceState state,
    String studentId,
  ) {
    final current = state.statusOf(studentId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in state.options) ...[
          if (option != state.options.first) const SizedBox(width: 4),
          _StatusButton(
            icon: _iconFor(option),
            color: _colorFor(context, option),
            isSelected: current == option.code,
            tooltip: option.label,
            onTap: state.isSaving
                ? null
                : () => _mark(context, state, studentId, option.code),
          ),
        ],
      ],
    );
  }

  /// Marking a submitted register asks for a reason first - the audit trail
  /// records the change against it, so it cannot be an afterthought.
  Future<void> _mark(
    BuildContext context,
    ClassAttendanceState state,
    String studentId,
    String statusCode,
  ) async {
    final bloc = context.read<ClassAttendanceBloc>();

    if (!state.isSubmitted) {
      bloc.add(ClassAttendanceStudentMarked(studentId, statusCode));
      return;
    }

    final reason = await _askReason(context);
    if (reason == null || !context.mounted) return;

    bloc.add(
      state.isEditable
          ? ClassAttendanceCorrected(
              studentId: studentId,
              statusCode: statusCode,
              reason: reason,
            )
          : ClassAttendanceCorrectionRequested(
              studentId: studentId,
              statusCode: statusCode,
              reason: reason,
            ),
    );
  }

  Future<String?> _askReason(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated(dialogContext),
        title: Text(
          'Reason for the change',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary(dialogContext),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'e.g. Marked absent in error - arrived late',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.length < 5) return;
              Navigator.of(dialogContext).pop(text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(ClassAttendanceOption option) =>
      switch (option.classification) {
        AttendanceClassification.present =>
          option.code.toLowerCase().contains('late')
              ? Icons.access_time
              : Icons.check,
        AttendanceClassification.authorisedAbsence => Icons.event_busy,
        AttendanceClassification.unauthorisedAbsence => Icons.close,
      };

  static Color _colorFor(BuildContext context, ClassAttendanceOption option) =>
      switch (option.classification) {
        AttendanceClassification.present =>
          option.code.toLowerCase().contains('late')
              ? AppColors.warning(context)
              : AppColors.success(context),
        AttendanceClassification.authorisedAbsence => AppColors.information(
          context,
        ),
        AttendanceClassification.unauthorisedAbsence => AppColors.danger(
          context,
        ),
      };

  Widget _buildSubmitBar(BuildContext context, ClassAttendanceState state) {
    final canSubmit = !state.isSubmitted && !state.isLocked;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (canSubmit) ...[
              Expanded(
                child: SecondaryButton(
                  label: 'Save draft',
                  onPressed: state.isSaving
                      ? null
                      : () => context.read<ClassAttendanceBloc>().add(
                          const ClassAttendanceDraftSaved(),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
            ],
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: state.isSubmitted ? 'Submitted' : 'Submit Attendance',
                isLoading: state.isSaving,
                onPressed: canSubmit
                    ? () => context.read<ClassAttendanceBloc>().add(
                        const ClassAttendanceSubmitted(),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceSkeleton extends StatelessWidget {
  const _AttendanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Skeleton(height: 70),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Skeleton(width: 100, height: 20),
              Skeleton(width: 120, height: 20),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: 10,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Skeleton(height: 60, borderRadius: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final String tooltip;
  final VoidCallback? onTap;

  const _StatusButton({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? color : color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: isSelected ? Colors.white : color),
        ),
      ),
    );
  }
}
