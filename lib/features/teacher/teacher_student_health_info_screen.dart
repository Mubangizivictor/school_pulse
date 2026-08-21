import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:url_launcher/url_launcher.dart';

import 'domain/repositories/class_student_repository.dart';
import 'presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'presentation/widgets/teacher_student_detail_ui.dart';

/// The teacher-safe slice of a student's health information: what somebody
/// supervising this child needs in order to act, and nothing more.
///
/// Deliberately sourced from the `students` record rather than the Health
/// module's `health_profiles`. The Firestore rules only open `health_profiles`
/// and `clinic_visits` to `canManageClinicalRecords()` (nurse, admin, head,
/// deputy, director), parents, and the student themselves - a class teacher is
/// none of those. Rather than widen a clinical-records rule to fit a teacher
/// screen, this reads the emergency-response fields the student record already
/// carries and that staff may already read.
///
/// Shown: allergies, chronic-condition precautions, medication note, whether a
/// nurse-held alert exists, and the emergency contact.
/// Not shown: diagnosis history, clinic visit notes, medical documents, or any
/// other clinical record - those stay with the nurse.
class TeacherStudentHealthInfoScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentHealthInfoScreen({super.key, required this.studentId});

  @override
  State<TeacherStudentHealthInfoScreen> createState() =>
      _TeacherStudentHealthInfoScreenState();
}

class _TeacherStudentHealthInfoScreenState
    extends State<TeacherStudentHealthInfoScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Student? _student;

  /// The roster row carries the nurse-held alert flag, which the student
  /// record itself does not.
  bool _hasHealthAlert = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null) {
      setState(() {
        _errorMessage =
            'Your class responsibility is still loading. Try again in a moment.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Roster membership first: this both authorises the read and yields the
    // health-alert flag. A student outside this teacher's class stops here.
    final rosterResult = await di.sl<ClassStudentRepository>().getClassStudent(
      context: active,
      studentId: widget.studentId,
    );

    if (!mounted) return;

    final failure = rosterResult.fold((f) => f, (_) => null);
    if (failure != null) {
      setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
      });
      return;
    }

    _hasHealthAlert = rosterResult.fold(
      (_) => false,
      (summary) => summary.hasHealthAlert,
    );

    final studentResult = await di.sl<StudentRepository>().getStudentById(
      widget.studentId,
    );
    if (!mounted) return;

    studentResult.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
      }),
      (student) => setState(() {
        _student = student;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const TeacherStudentDetailAppBar(title: 'Health Information'),
      body: SafeArea(top: false, child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return TeacherStudentDetailErrorState(
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final student = _student;
    if (student == null) {
      return const TeacherStudentDetailEmptyState(
        icon: Icons.medical_information_outlined,
        title: 'No health information',
        message: 'This student has no health information on file.',
      );
    }

    final medical = student.medicalInfo;
    final allergies = medical?.allergies ?? const <String>[];
    final chronic = medical?.chronicConditions ?? const <String>[];
    final medications = (medical?.medications ?? '').trim();
    final contacts = student.emergencyContacts;

    final hasAnything =
        _hasHealthAlert ||
        allergies.isNotEmpty ||
        chronic.isNotEmpty ||
        medications.isNotEmpty ||
        contacts.isNotEmpty;

    if (!hasAnything) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
            const TeacherStudentDetailEmptyState(
              icon: Icons.medical_information_outlined,
              title: 'No health information',
              message:
                  'No allergies, conditions or emergency contacts are '
                  'recorded for this student. Contact the school nurse if '
                  'you believe something is missing.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _AlertBanner(hasAlert: _hasHealthAlert),
          if (allergies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            _HealthCard(
              icon: Icons.warning_amber_rounded,
              accent: AppColors.error,
              title: 'Allergies',
              subtitle: 'Avoid these and act at once if exposure happens.',
              items: allergies,
            ),
          ],
          if (chronic.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            _HealthCard(
              icon: Icons.monitor_heart_outlined,
              accent: AppColors.warning(context),
              title: 'Conditions to be aware of',
              subtitle:
                  'Precautions only. The full medical record stays with '
                  'the nurse.',
              items: chronic,
            ),
          ],
          if (medications.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            _HealthCard(
              icon: Icons.medication_outlined,
              accent: AppColors.primary(context),
              title: 'Medication',
              subtitle:
                  'Administered by the school nurse. Send the student to '
                  'the clinic at the stated time.',
              items: [medications],
            ),
          ],
          if (contacts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            _EmergencyContacts(contacts: contacts),
          ],
          const SizedBox(height: AppSpacing.l),
          _PrivacyNote(),
        ],
      ),
    );
  }
}

/// Whether the nurse holds an active alert for this student. The alert's
/// clinical content is not a teacher's to read - this says only that one
/// exists, and who to ask.
class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.hasAlert});

  final bool hasAlert;

  @override
  Widget build(BuildContext context) {
    final color = hasAlert ? AppColors.error : AppColors.success(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              hasAlert
                  ? 'This student has an active health alert on file with '
                        'the school nurse. Contact the clinic before any '
                        'strenuous activity.'
                  : 'No active health alert on file for this student.',
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

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmergencyContacts extends StatelessWidget {
  const _EmergencyContacts({required this.contacts});

  final List<EmergencyContact> contacts;

  Future<void> _call(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not start the call.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone_outlined,
                size: 18,
                color: AppColors.primary(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Emergency contact',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          for (final contact in contacts)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          contact.relationship.isEmpty
                              ? contact.phoneNumber
                              : '${contact.relationship} - '
                                    '${contact.phoneNumber}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (contact.phoneNumber.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.call_outlined,
                        color: AppColors.primary(context),
                      ),
                      tooltip: 'Call ${contact.name}',
                      onPressed: () => _call(context, contact.phoneNumber),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Says plainly where the line is, so a teacher knows this screen is a
/// deliberate summary rather than the whole record.
class _PrivacyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'This is the summary a teacher needs in order to respond. Diagnosis '
      'history, clinic notes and medical documents stay with the school '
      'nurse. Contact the clinic if you need more.',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textMuted(context),
      ),
    );
  }
}
