import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student_enums.dart';
import '../../domain/services/parent_linking_service.dart';
import '../bloc/admission_bloc.dart';
import '../bloc/admission_event.dart';
import '../bloc/admission_state.dart';
import 'admissions_list_screen.dart' show admissionStatusLabel;

class AdmissionReviewScreen extends StatelessWidget {
  final AdmissionApplication application;
  const AdmissionReviewScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdmissionBloc>(),
      child: _AdmissionReviewView(application: application),
    );
  }
}

class _AdmissionReviewView extends StatefulWidget {
  final AdmissionApplication application;
  const _AdmissionReviewView({required this.application});

  @override
  State<_AdmissionReviewView> createState() => _AdmissionReviewViewState();
}

class _AdmissionReviewViewState extends State<_AdmissionReviewView> {
  final _commentsController = TextEditingController();
  String _schoolCodeDefault = 'SCH';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolName = authState is AuthAuthenticated
        ? authState.user.schoolName
        : null;
    _schoolCodeDefault = _prefixFrom(schoolName);
  }

  String _prefixFrom(String? schoolName) {
    if (schoolName == null || schoolName.trim().isEmpty) return 'SCH';
    final letters = schoolName
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w[0])
        .take(3)
        .join();
    return letters.toUpperCase();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _review(bool approve) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() => _busy = true);
    context.read<AdmissionBloc>().add(
      ReviewApplicationRequested(
        applicationId: widget.application.id,
        reviewerId: authState.user.id,
        approve: approve,
        comments: _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
      ),
    );
  }

  // admitStudent() never touched ParentAccessCode, so a newly enrolled
  // student otherwise has no route to a parent login until an admin
  // separately remembers to create one from User Management. Prompt for
  // it right here, using the phone/name already collected on the
  // application - reuses the sibling-linking logic in
  // ParentLinkingService if this phone number already has a code.
  Future<void> _maybeLinkParent(BuildContext context, String studentId) async {
    final linkingService = sl<ParentLinkingService>();
    final application = widget.application;

    final existingResult = await linkingService.findExistingCodeForPhone(
      schoolId: application.schoolId,
      phoneNumber: application.applicantParentPhone,
    );
    final existing = existingResult.fold((_) => null, (code) => code);

    if (!context.mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Link Parent Access'),
        content: Text(
          existing == null
              ? 'Create a parent access code for ${application.applicantParentName} '
                    '(${application.applicantParentPhone})?'
              : '${application.applicantParentPhone} already has a parent access code '
                    '(${existing.parentCode}) for ${existing.studentNames.join(', ')}. '
                    'Add ${application.studentName} to it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Link'),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;

    final authState = context.read<AuthBloc>().state;
    final linkResult = await linkingService.linkStudentToParent(
      studentId: studentId,
      studentName: application.studentName,
      schoolId: application.schoolId,
      phoneNumber: application.applicantParentPhone,
      parentName: application.applicantParentName,
      createdBy: authState is AuthAuthenticated ? authState.user.id : '',
    );
    if (!context.mounted) return;

    linkResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not link parent: ${failure.message}'),
          backgroundColor: AppColors.danger(context),
        ),
      ),
      (code) => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Parent Access Code'),
          content: SelectableText(
            'Give this code to the parent to sign in:\n\n$code',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enroll() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final schoolCode = await showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _EnrollDialog(initialSchoolCode: _schoolCodeDefault),
    );
    if (schoolCode == null || schoolCode.trim().isEmpty || !mounted) return;

    setState(() => _busy = true);
    final application = widget.application;
    // Financial account setup (term/feeStructureId/totalBilled) is
    // deliberately left unset here - AdmissionService only initializes
    // billing when all three are supplied, so enrollment still succeeds
    // without them; wiring a fee-structure picker into this screen is
    // follow-up work for the billing/bursar flow.
    context.read<AdmissionBloc>().add(
      EnrollStudentRequested(
        operatorUser: authState.user,
        applicationId: application.id,
        schoolId: application.schoolId,
        schoolCode: schoolCode.trim(),
        academicYear: application.academicYearId,
        academicYearId: application.academicYearId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final application = widget.application;
    return BlocListener<AdmissionBloc, AdmissionState>(
      listener: (context, state) async {
        if (state is AdmissionEnrollSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          await _maybeLinkParent(context, state.studentId);
          if (context.mounted) Navigator.of(context).pop(true);
        } else if (state is AdmissionActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.of(context).pop(true);
        } else if (state is AdmissionError) {
          setState(() => _busy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger(context),
            ),
          );
        } else if (state is AdmissionActionDenied) {
          setState(() => _busy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger(context),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(application.studentName)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: admissionStatusLabel(application.status).toUpperCase(),
                color: _getStatusColor(application.status, context),
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              'Date of birth',
              application.dateOfBirth.toLocal().toString().split(' ').first,
            ),
            _InfoRow('Gender', application.gender.name),
            _InfoRow('Target class', application.targetClassId),
            if (application.targetStreamId != null)
              _InfoRow('Stream', application.targetStreamId!),
            _InfoRow('Academic year', application.academicYearId),
            if (application.previousSchool != null)
              _InfoRow('Previous school', application.previousSchool!),
            _InfoRow('Parent / guardian', application.applicantParentName),
            _InfoRow('Parent phone', application.applicantParentPhone),
            if (application.reviewComments != null)
              _InfoRow('Review comments', application.reviewComments!),
            const SizedBox(height: 24),
            if (application.status == AdmissionStatus.application ||
                application.status == AdmissionStatus.review) ...[
              TextField(
                controller: _commentsController,
                maxLines: 3,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Review comments (optional)',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => _review(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger(context),
                        side: BorderSide(color: AppColors.danger(context)),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : () => _review(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success(context),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ] else if (application.status == AdmissionStatus.approved) ...[
              FilledButton.icon(
                onPressed: _busy ? null : _enroll,
                icon: const Icon(Icons.how_to_reg),
                label: const Text('Enroll Student'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AdmissionStatus status, BuildContext context) {
    switch (status) {
      case AdmissionStatus.approved:
      case AdmissionStatus.admitted:
        return AppColors.success(context);
      case AdmissionStatus.application:
        return AppColors.information(context);
      case AdmissionStatus.review:
        return AppColors.warning(context);
      case AdmissionStatus.rejected:
        return AppColors.danger(context);
    }
  }
}

class _EnrollDialog extends StatefulWidget {
  final String initialSchoolCode;
  const _EnrollDialog({required this.initialSchoolCode});

  @override
  State<_EnrollDialog> createState() => _EnrollDialogState();
}

class _EnrollDialogState extends State<_EnrollDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSchoolCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Enrollment'),
      content: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'School code prefix',
          helperText:
              'Used to build the student\'s human-readable code, e.g. "MH"',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Enroll'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textMuted(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildInfoRow(context, label, value);
  }
}
