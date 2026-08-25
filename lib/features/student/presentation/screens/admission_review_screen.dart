import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student_enums.dart';
import '../../domain/services/admission_service.dart';
import '../../domain/services/parent_linking_service.dart';
import '../bloc/admission_bloc.dart';
import '../bloc/admission_event.dart';
import '../bloc/admission_state.dart';
import '../enrollment_setup/screens/enrollment_setup_wizard_screen.dart';
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
        operatorUser: authState.user,
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

  // Runs Steps 1-3 of admission (mints the admission number + student/QR
  // codes, sets status to StudentStatus.admitted) directly via
  // AdmissionService, then hands off to the Enrollment Setup Wizard for
  // everything the old direct-EnrollStudentRequested flow used to skip
  // (finance/boarding/clubs/parent-link/identity confirmation) before the
  // wizard itself calls AdmissionService.enrollStudent to finish the
  // status transition to active. Deliberately bypasses AdmissionBloc's
  // EnrollStudentRequested handler - that handler still exists unmodified
  // for any other caller, but it inlines admit+enroll as one step, which
  // would activate the student before the wizard ever runs.
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
    final admissionService = sl<AdmissionService>();

    final admitResult = await admissionService.admitStudent(
      application.id,
      application.schoolId,
      schoolCode.trim(),
      application.academicYearId,
      application.academicYearId,
    );

    if (!mounted) return;
    setState(() => _busy = false);

    await admitResult.fold(
      (failure) async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.danger(context),
          ),
        );
      },
      (studentId) async {
        final studentResult = await admissionService.repository
            .getStudentById(studentId);
        final codes = studentResult.fold(
          (failure) => null,
          (student) => (
            uniqueSystemId: student.qrReference ?? '',
            studentCode: student.studentCode,
          ),
        );
        if (!mounted || codes == null) return;

        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => EnrollmentSetupWizardScreen(
              application: application,
              studentId: studentId,
              schoolCode: schoolCode.trim(),
              uniqueSystemId: codes.uniqueSystemId,
              studentCode: codes.studentCode,
            ),
          ),
        );
        if (mounted) Navigator.of(context).pop(true);
      },
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
            const SectionHeader(title: 'Application Details'),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _InfoRow(
                    'Date of birth',
                    application.dateOfBirth.toLocal().toString().split(
                      ' ',
                    )[0],
                  ),
                  Divider(color: AppColors.border(context)),
                  _InfoRow('Gender', application.gender.name),
                  Divider(color: AppColors.border(context)),
                  StreamBuilder<List<SchoolClass>>(
                    stream: sl<StructureRepository>().watchClasses(
                      application.schoolId,
                    ),
                    builder: (context, snap) {
                      final classes = snap.data ?? const <SchoolClass>[];
                      final match = classes
                          .where((c) => c.id == application.targetClassId)
                          .toList();
                      final label = match.isNotEmpty
                          ? match.first.name
                          : (classes.isEmpty ? 'Loading…' : 'Unknown class');
                      return _InfoRow('Target class', label);
                    },
                  ),
                  if (application.targetStreamId != null) ...[
                    Divider(color: AppColors.border(context)),
                    _InfoRow('Stream', application.targetStreamId!),
                  ],
                  Divider(color: AppColors.border(context)),
                  StreamBuilder<List<AcademicYear>>(
                    stream: sl<StructureRepository>().watchAcademicYears(
                      application.schoolId,
                    ),
                    builder: (context, snap) {
                      final years = snap.data ?? const <AcademicYear>[];
                      final match = years
                          .where((y) => y.id == application.academicYearId)
                          .toList();
                      final label = match.isNotEmpty
                          ? match.first.name
                          : (years.isEmpty ? 'Loading…' : 'Unknown year');
                      return _InfoRow('Academic year', label);
                    },
                  ),
                  if (application.previousSchool != null) ...[
                    Divider(color: AppColors.border(context)),
                    _InfoRow('Previous school', application.previousSchool!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Parent / Guardian'),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _InfoRow(
                    'Parent / guardian',
                    application.applicantParentName,
                  ),
                  Divider(color: AppColors.border(context)),
                  _InfoRow('Parent phone', application.applicantParentPhone),
                  if (application.reviewComments != null) ...[
                    Divider(color: AppColors.border(context)),
                    _InfoRow('Review comments', application.reviewComments!),
                  ],
                ],
              ),
            ),
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
              const Center(child: SchoolPulseLoader()),
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
