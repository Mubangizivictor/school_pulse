import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/injection_container.dart' as di;

import 'domain/entities/class_student_summary.dart';
import 'domain/entities/lesson_attendance.dart';
import 'domain/entities/student_guardian_contact.dart';
import 'domain/services/student_guardian_contact_service.dart';
import 'presentation/bloc/class_students/class_students_bloc.dart';
import 'presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

class TeacherStudentProfileScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentProfileScreen({super.key, required this.studentId});

  @override
  State<TeacherStudentProfileScreen> createState() =>
      _TeacherStudentProfileScreenState();
}

class _TeacherStudentProfileScreenState
    extends State<TeacherStudentProfileScreen> {
  late Future<StudentGuardianContact?>? _guardianFuture;
  String? _loadedForContextId;

  @override
  void initState() {
    super.initState();
    _guardianFuture = null;
  }

  void _loadGuardianIfNeeded(BuildContext context) {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null || _loadedForContextId == active.roleAssignmentId) {
      return;
    }
    _loadedForContextId = active.roleAssignmentId;
    _guardianFuture = di
        .sl<StudentGuardianContactService>()
        .getPrimaryGuardian(context: active, studentId: widget.studentId)
        .then((result) => result.fold((_) => null, (contact) => contact));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _loadGuardianIfNeeded(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Student Profile',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: AppColors.textPrimary(context)),
            onPressed: () => context.push(
              '/staff/students/${widget.studentId}/more-options',
            ),
          ),
        ],
      ),
      body: BlocBuilder<ClassStudentsBloc, ClassStudentsState>(
        builder: (context, state) {
          final student = state.students
              .where((s) => s.studentId == widget.studentId)
              .firstOrNull;

          if (state.isLoading && student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (student == null) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'This student is not on your class roster.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
            );
          }

          final status = state.statusOf(student.studentId);

          return RefreshIndicator(
            onRefresh: () async {
              _loadedForContextId = null;
              _loadGuardianIfNeeded(context);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  _buildHeader(context, student, status),
                  const SizedBox(height: AppSpacing.x2l),
                  _buildProfileTabs(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPersonalInfo(context, student),
                  const SizedBox(height: AppSpacing.l),
                  FutureBuilder<StudentGuardianContact?>(
                    future: _guardianFuture,
                    builder: (context, snapshot) {
                      return _buildContactCard(
                        context,
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
                        guardian: snapshot.data,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  FutureBuilder<StudentGuardianContact?>(
                    future: _guardianFuture,
                    builder: (context, snapshot) {
                      return _buildMessageParentButton(
                        context,
                        guardian: snapshot.data,
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ClassStudentSummary student,
    LessonAttendanceStatus status,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary(context), width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary(context),
            backgroundImage: (student.photoUrl?.isNotEmpty ?? false)
                ? NetworkImage(student.photoUrl!)
                : null,
            child: (student.photoUrl?.isNotEmpty ?? false)
                ? null
                : Text(
                    student.initials,
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary(context),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.l),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Admission No: ${student.admissionNumber}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(context, status).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSpacing.s),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: _statusColor(context, status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: _statusColor(context, status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _ProfileTabItem(
          icon: Icons.person,
          label: 'Profile',
          isSelected: true,
        ),
        _ProfileTabItem(
          icon: Icons.calendar_today,
          label: 'Attendance',
          onTap: () =>
              context.push('/staff/students/${widget.studentId}/attendance'),
        ),
        _ProfileTabItem(
          icon: Icons.analytics_outlined,
          label: 'Performance',
          onTap: () =>
              context.push('/staff/students/${widget.studentId}/performance'),
        ),
        _ProfileTabItem(
          icon: Icons.gavel,
          label: 'Behaviour',
          onTap: () =>
              context.push('/staff/students/${widget.studentId}/behaviour'),
        ),
        _ProfileTabItem(
          icon: Icons.grid_view,
          label: 'More',
          onTap: () =>
              context.push('/staff/students/${widget.studentId}/more-options'),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo(BuildContext context, ClassStudentSummary student) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Information',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _InfoRow(label: 'Class', value: student.placementLabel),
          if (student.gender != null)
            _InfoRow(label: 'Gender', value: student.gender!),
          _InfoRow(
            label: 'Residency',
            value: switch (student.residency) {
              ResidencyType.boarding => 'Boarding',
              ResidencyType.day => 'Day',
              ResidencyType.unknown => 'Not recorded',
            },
          ),
          if (student.houseName != null)
            _InfoRow(label: 'House', value: student.houseName!),
          if (student.hasHealthAlert)
            _InfoRow(label: 'Health', value: 'Has an active alert'),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required bool isLoading,
    required StudentGuardianContact? guardian,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.forum_outlined, color: AppColors.primary(context)),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent / Guardian',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
                const SizedBox(height: 2),
                if (isLoading)
                  Text(
                    'Loading…',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  )
                else if (guardian == null)
                  Text(
                    'No guardian is linked to this student yet.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  )
                else ...[
                  Text(
                    guardian.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (guardian.hasPhone)
                    Text(
                      guardian.phoneNumber,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (guardian != null && guardian.hasPhone)
            IconButton(
              icon: Icon(Icons.phone, color: AppColors.success(context)),
              onPressed: () => _callGuardian(context, guardian),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageParentButton(
    BuildContext context, {
    required StudentGuardianContact? guardian,
    required bool isLoading,
  }) {
    final canMessage = guardian?.canMessage ?? false;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading || !canMessage
            ? null
            : () => _messageGuardian(context, guardian!),
        icon: Icon(
          Icons.chat_bubble_outline,
          color: canMessage || isLoading
              ? Colors.white
              : AppColors.textMuted(context),
        ),
        label: Text(
          canMessage || isLoading
              ? 'Message Parent'
              : 'Parent has no messaging account yet',
          style: TextStyle(
            color: canMessage || isLoading
                ? Colors.white
                : AppColors.textMuted(context),
          ),
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          disabledBackgroundColor: AppColors.surfaceElevated(context),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.m),
          ),
        ),
      ),
    );
  }

  Future<void> _callGuardian(
    BuildContext context,
    StudentGuardianContact guardian,
  ) async {
    final uri = Uri(scheme: 'tel', path: guardian.phoneNumber);
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone dialer.')),
      );
    }
  }

  Future<void> _messageGuardian(
    BuildContext context,
    StudentGuardianContact guardian,
  ) async {
    final result = await context.dispatchMessagingAction(
      DirectConversationRequested(
        MessageContact(
          id: guardian.userId!,
          name: guardian.name,
          role: 'Parent',
        ),
      ),
    );
    if (!context.mounted) return;

    if (result.actionStatus == MessagingActionStatus.success &&
        result.createdConversationId != null) {
      context.push('/messages/chat/${result.createdConversationId}');
    } else {
      context.showMessagingSnack(
        result.lastDecision?.message ??
            'Could not open the chat: ${result.lastActionError}',
      );
    }
  }

  static Color _statusColor(
    BuildContext context,
    LessonAttendanceStatus status,
  ) {
    if (status == LessonAttendanceStatus.notMarked) {
      return AppColors.textMuted(context);
    }
    if (status.countsAsPresent) return AppColors.success(context);
    if (status.isAuthorisedAbsence) return AppColors.warning(context);
    return AppColors.danger(context);
  }
}

class _ProfileTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ProfileTabItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.m),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary(context)
                  : AppColors.surfaceElevated(context),
              borderRadius: BorderRadius.circular(AppSpacing.m),
              border: isSelected
                  ? null
                  : Border.all(color: AppColors.border(context)),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textMuted(context),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected
                  ? AppColors.primary(context)
                  : AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
