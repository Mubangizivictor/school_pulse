import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student_enums.dart';
import '../../domain/services/admission_service.dart';
import '../enrollment_setup/screens/enrollment_setup_wizard_screen.dart';

/// Admin-initiated direct registration: skips the submit -> review ->
/// approve flow entirely (that flow is for applications coming through the
/// public website / staff-mediated applicant intake, still handled by
/// NewApplicationScreen -> AdmissionReviewScreen).
///
/// This screen now only creates a bare student stub (a minimal
/// AdmissionApplication + admitStudent() call, both requiring a class and
/// academic year up front since admitStudent() needs them to mint a
/// student code) and pushes straight into the Enrollment Setup Wizard,
/// whose new front-loaded steps (Basic Info, Class & Stream, Guardians,
/// Health & Emergency, Transport) collect everything this screen used to
/// ask for. admitStudent() still requires an AdmissionApplication document
/// to exist (finalizeAdmission reads it by id), so this creates one at
/// AdmissionStatus.approved - a data carrier for this flow, not a
/// pending-review item.
class DirectStudentRegistrationScreen extends StatefulWidget {
  final String schoolId;
  const DirectStudentRegistrationScreen({super.key, required this.schoolId});

  @override
  State<DirectStudentRegistrationScreen> createState() =>
      _DirectStudentRegistrationScreenState();
}

class _DirectStudentRegistrationScreenState
    extends State<DirectStudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolCodeController = TextEditingController();
  final _structureRepository = sl<StructureRepository>();

  bool _busy = false;
  List<SchoolClass> _classes = [];
  List<AcademicYear> _academicYears = [];
  SchoolClass? _selectedClass;
  AcademicYear? _selectedYear;
  StreamSubscription<List<SchoolClass>>? _classesSub;
  StreamSubscription<List<AcademicYear>>? _yearsSub;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolName = authState is AuthAuthenticated
        ? authState.user.schoolName
        : null;
    _schoolCodeController.text = _prefixFrom(schoolName);
    _classesSub = _structureRepository.watchClasses(widget.schoolId).listen((
      classes,
    ) {
      setState(() => _classes = classes);
    });
    _yearsSub = _structureRepository.watchAcademicYears(widget.schoolId).listen(
      (years) {
        setState(() {
          _academicYears = years;
          if (_selectedYear == null) {
            for (final year in years) {
              if (year.isCurrent) {
                _selectedYear = year;
                break;
              }
            }
          }
        });
      },
    );
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
    _classesSub?.cancel();
    _yearsSub?.cancel();
    _schoolCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _selectedClass == null || _selectedYear == null) {
      if (_selectedClass == null || _selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a class and academic year'),
          ),
        );
      }
      return;
    }
    if (_schoolCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a school code prefix')),
      );
      return;
    }

    setState(() => _busy = true);
    final admissionService = sl<AdmissionService>();

    // Placeholder name/DOB/gender - the wizard's Basic Info step collects
    // and overwrites the real values before the student can be activated.
    final application = AdmissionApplication(
      id: const Uuid().v4(),
      schoolId: widget.schoolId,
      studentName: 'New Student',
      dateOfBirth: DateTime(DateTime.now().year - 6),
      gender: Gender.other,
      targetClassId: _selectedClass!.id,
      academicYearId: _selectedYear!.id,
      applicantParentName: '',
      applicantParentPhone: '',
      status: AdmissionStatus.approved,
      appliedAt: DateTime.now(),
    );

    final createResult = await admissionService.submitApplication(application);

    if (!mounted) return;

    final Either<String, String> admitResult = await createResult.fold(
      (failure) async => Left(failure.message),
      (_) async {
        final result = await admissionService.admitStudent(
          application.id,
          application.schoolId,
          _schoolCodeController.text.trim(),
          application.academicYearId,
          application.academicYearId,
        );
        return result.fold(
          (failure) => Left(failure.message),
          (studentId) => Right(studentId),
        );
      },
    );

    if (!mounted) return;
    setState(() => _busy = false);

    await admitResult.fold(
      (message) async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.danger(context),
          ),
        );
      },
      (studentId) async {
        final studentResult = await admissionService.repository.getStudentById(
          studentId,
        );
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
              schoolCode: _schoolCodeController.text.trim(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Register Student')),
      body: _busy
          ? const Center(child: SchoolPulseLoader())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const WizardStepProgress(
                    currentStep: 0,
                    stepCount: 2,
                    stepTitle: 'Register Student',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Creates the student record and continues straight into '
                    'enrollment setup, where full details are collected.',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: [
                        DropdownButtonFormField<SchoolClass>(
                          initialValue: _selectedClass,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Class',
                            labelStyle: TextStyle(
                              color: AppColors.textSecondary(context),
                            ),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.border(context),
                              ),
                            ),
                          ),
                          items: _classes
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedClass = v),
                          validator: (v) => v == null ? 'Required' : null,
                          hint: Text(
                            _classes.isEmpty
                                ? 'Loading classes…'
                                : 'Select class',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<AcademicYear>(
                          initialValue: _selectedYear,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Academic year',
                            labelStyle: TextStyle(
                              color: AppColors.textSecondary(context),
                            ),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.border(context),
                              ),
                            ),
                          ),
                          items: _academicYears
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(y.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedYear = v),
                          validator: (v) => v == null ? 'Required' : null,
                          hint: Text(
                            _academicYears.isEmpty
                                ? 'Loading academic years…'
                                : 'Select year',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _schoolCodeController,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                          ),
                          decoration: InputDecoration(
                            labelText: 'School code prefix',
                            helperText:
                                'Used to build the student\'s human-readable code, e.g. "MH"',
                            labelStyle: TextStyle(
                              color: AppColors.textSecondary(context),
                            ),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.border(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Create Student & Continue',
                    isLoading: _busy,
                    onPressed: _busy ? null : _register,
                  ),
                ],
              ),
            ),
    );
  }
}
