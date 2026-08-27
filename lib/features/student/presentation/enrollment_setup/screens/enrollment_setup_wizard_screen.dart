import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/student/domain/entities/admission_application.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/hostel_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/transport_structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/repositories/enrollment_setup_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/teaching_assignment_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/curriculum_assignment_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_billing_repository.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_plan.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import '../bloc/enrollment_setup_wizard_bloc.dart';
import '../bloc/enrollment_setup_wizard_event.dart';
import '../bloc/enrollment_setup_wizard_state.dart';

/// `state.extra` payload for the `/staff/admin/admissions/review/enroll`
/// route - carries everything AdmissionReviewScreen already resolved
/// (school code prefix, the codes admitStudent() minted) so the wizard
/// never has to re-derive them.
class EnrollmentSetupWizardRouteExtra {
  final AdmissionApplication application;
  final String studentId;
  final String schoolCode;
  final String uniqueSystemId;
  final String studentCode;

  const EnrollmentSetupWizardRouteExtra({
    required this.application,
    required this.studentId,
    required this.schoolCode,
    required this.uniqueSystemId,
    required this.studentCode,
  });
}

/// Entry point for the post-approval Enrollment Setup Wizard. Launched
/// from AdmissionReviewScreen once an application is approved and has
/// been through admitStudent() (status admitted), replacing the previous
/// direct-enroll button.
class EnrollmentSetupWizardScreen extends StatelessWidget {
  final AdmissionApplication application;
  final String studentId;
  final String schoolCode;
  final String uniqueSystemId;
  final String studentCode;

  const EnrollmentSetupWizardScreen({
    super.key,
    required this.application,
    required this.studentId,
    required this.schoolCode,
    required this.uniqueSystemId,
    required this.studentCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<EnrollmentSetupWizardBloc>();
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          bloc.add(
            WizardStarted(
              operatorUser: authState.user,
              studentId: studentId,
              schoolId: application.schoolId,
              schoolCode: schoolCode,
              uniqueSystemId: uniqueSystemId,
              studentCode: studentCode,
              admissionNumber: application.id,
              academicYearId: application.academicYearId,
              classId: application.targetClassId,
              streamId: application.targetStreamId,
            ),
          );
        }
        return bloc;
      },
      child: _WizardView(application: application),
    );
  }
}

class _WizardView extends StatelessWidget {
  final AdmissionApplication application;
  const _WizardView({required this.application});

  static const _stepTitles = [
    'Basic Info',
    'Class & Stream',
    'Guardians',
    'Health & Emergency',
    'Transport',
    'Admission',
    'Academic Placement',
    'Finance',
    'Boarding / House',
    'Clubs & Activities',
    'Student Identity',
    'Review & Activate',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      listenWhen: (prev, curr) =>
          curr.error != null || (curr.activated && !prev.activated),
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.danger(context),
            ),
          );
        }
        if (state.activated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.infoMessage ?? 'Student activated successfully.',
              ),
            ),
          );
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Enroll ${application.studentName}')),
        body: BlocBuilder<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
          builder: (context, state) {
            return Column(
              children: [
                if (state.resumedFromDraft)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: AlertBanner(
                      title: 'Enrollment Setup - Resumed',
                      message:
                          '${state.completedStepCount} of $kWizardStepCount '
                          'steps completed. Continuing from where you left '
                          'off.',
                      color: AppColors.information(context),
                      icon: Icons.history,
                    ),
                  ),
                WizardStepProgress(
                  currentStep: state.currentStep,
                  stepCount: _stepTitles.length,
                  stepTitle: _stepTitles[state.currentStep],
                ),
                const Divider(height: 1),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: SchoolPulseLoader())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildStep(context, state, application),
                        ),
                ),
                _NavBar(state: state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    EnrollmentSetupWizardState state,
    AdmissionApplication application,
  ) {
    switch (state.currentStep) {
      case 0:
        return _BasicInfoStep(state: state, application: application);
      case 1:
        return _ClassStreamStep(state: state);
      case 2:
        return _GuardiansStep(state: state);
      case 3:
        return _HealthEmergencyStep(state: state);
      case 4:
        return _TransportStep(state: state);
      case 5:
        return _AdmissionStep(state: state, application: application);
      case 6:
        return _AcademicPlacementStep(state: state);
      case 7:
        return _FinanceStep(state: state);
      case 8:
        return _BoardingHouseStep(state: state);
      case 9:
        return _ClubsStep(state: state);
      case 10:
        return _IdentityStep(state: state);
      case 11:
      default:
        return _ReviewStep(state: state);
    }
  }
}

class _NavBar extends StatelessWidget {
  final EnrollmentSetupWizardState state;
  const _NavBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EnrollmentSetupWizardBloc>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.border(context))),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!state.isFirstStep)
              Expanded(
                child: SecondaryButton(
                  label: 'Back',
                  onPressed: state.isLoading || state.isActivating
                      ? null
                      : () => bloc.add(const WizardPreviousStep()),
                ),
              ),
            if (!state.isFirstStep && !state.isLastStep)
              const SizedBox(width: 12),
            if (!state.isLastStep)
              Expanded(
                child: PrimaryButton(
                  label: 'Next',
                  onPressed: state.isLoading
                      ? null
                      : () => bloc.add(const WizardNextStep()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Step 0: Basic Info
// ---------------------------------------------------------------------
class _BasicInfoStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  final AdmissionApplication application;
  const _BasicInfoStep({required this.state, required this.application});

  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _religionController;
  late final TextEditingController _nationalityController;
  DateTime? _dateOfBirth;
  late Gender _gender;

  @override
  void initState() {
    super.initState();
    final state = widget.state;
    _nameController = TextEditingController(
      text: state.studentName.isNotEmpty
          ? state.studentName
          : widget.application.studentName,
    );
    _religionController = TextEditingController(text: state.religion ?? '');
    _nationalityController = TextEditingController(
      text: state.nationality ?? '',
    );
    _dateOfBirth = state.dateOfBirth ?? widget.application.dateOfBirth;
    _gender = state.gender;
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _religionController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  void _emit() {
    if (_dateOfBirth == null || _nameController.text.trim().isEmpty) return;
    context.read<EnrollmentSetupWizardBloc>().add(
      BasicInfoUpdated(
        name: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender,
        religion: _religionController.text.trim().isEmpty
            ? null
            : _religionController.text.trim(),
        nationality: _nationalityController.text.trim().isEmpty
            ? null
            : _nationalityController.text.trim(),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 6),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = _dateOfBirth == null
        ? null
        : DateTime.now().difference(_dateOfBirth!).inDays ~/ 365;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Basic Information'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                onChanged: (_) => _emit(),
                decoration: const InputDecoration(
                  labelText: 'Student full name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dateOfBirth == null
                      ? 'Select date of birth'
                      : 'Date of birth: ${DateFormat('dd MMM yyyy').format(_dateOfBirth!)}'
                            '${age != null ? ' (age $age)' : ''}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickDateOfBirth,
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<Gender>(
                initialValue: _gender,
                items: Gender.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _gender = v ?? _gender);
                  _emit();
                },
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Background (optional)'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _religionController,
                onChanged: (_) => _emit(),
                decoration: const InputDecoration(
                  labelText: 'Religion (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nationalityController,
                onChanged: (_) => _emit(),
                decoration: const InputDecoration(
                  labelText: 'Nationality (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 1: Class & Stream
// ---------------------------------------------------------------------
class _ClassStreamStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  const _ClassStreamStep({required this.state});

  @override
  State<_ClassStreamStep> createState() => _ClassStreamStepState();
}

class _ClassStreamStepState extends State<_ClassStreamStep> {
  String? _classId;
  String? _streamId;

  @override
  void initState() {
    super.initState();
    _classId = widget.state.selectedClassId.isNotEmpty
        ? widget.state.selectedClassId
        : widget.state.classId.isNotEmpty
        ? widget.state.classId
        : null;
    _streamId = widget.state.selectedStreamId ?? widget.state.streamId;
  }

  void _emit() {
    if (_classId == null) return;
    context.read<EnrollmentSetupWizardBloc>().add(
      ClassStreamSelected(classId: _classId!, streamId: _streamId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final structureRepo = sl<StructureRepository>();
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Class & Stream'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<List<SchoolClass>>(
                stream: structureRepo.watchClasses(state.schoolId),
                builder: (context, classSnap) {
                  final classes = classSnap.data ?? [];
                  return DropdownButtonFormField<String>(
                    initialValue: _classId,
                    items: classes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _classId = v;
                        _streamId = null;
                      });
                      _emit();
                    },
                    decoration: const InputDecoration(labelText: 'Class'),
                    hint: Text(
                      classes.isEmpty ? 'Loading classes…' : 'Select class',
                    ),
                  );
                },
              ),
              if (_classId != null)
                StreamBuilder<List<ClassStream>>(
                  stream: structureRepo.watchStreams(state.schoolId),
                  builder: (context, streamSnap) {
                    final streams = (streamSnap.data ?? [])
                        .where((s) => s.classId == _classId)
                        .toList();
                    if (streams.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: DropdownButtonFormField<String>(
                        initialValue: _streamId,
                        items: streams
                            .map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() => _streamId = v);
                          _emit();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Stream (optional)',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 2: Guardians (multi-guardian list)
// ---------------------------------------------------------------------
class _GuardiansStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  const _GuardiansStep({required this.state});

  @override
  State<_GuardiansStep> createState() => _GuardiansStepState();
}

class _GuardiansStepState extends State<_GuardiansStep> {
  late List<GuardianDraft> _guardians;
  final _siblingSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _guardians = List.of(widget.state.guardians);
  }

  @override
  void dispose() {
    _siblingSearchController.dispose();
    super.dispose();
  }

  void _emit() {
    context.read<EnrollmentSetupWizardBloc>().add(
      GuardiansListUpdated(List.of(_guardians)),
    );
  }

  Future<void> _addOrEditGuardian({int? index}) async {
    final result = await showDialog<GuardianDraft>(
      context: context,
      builder: (_) =>
          _GuardianDialog(initial: index != null ? _guardians[index] : null),
    );
    if (result == null) return;
    setState(() {
      if (index != null) {
        _guardians[index] = result;
      } else {
        _guardians.add(result);
      }
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.guardiansLinked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Guardians'),
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success(context),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Linked ${state.parentAccessCodes.length} guardian(s). '
                    'Access codes: ${state.parentAccessCodes.join(', ')}',
                    style: TextStyle(
                      color: AppColors.success(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Guardians'),
        if (_guardians.isEmpty)
          EmptyState(
            icon: Icons.family_restroom_outlined,
            title: 'No guardians added yet',
            message: 'Add at least one parent or guardian to continue.',
            ctaLabel: 'Add Guardian',
            onCtaPressed: () => _addOrEditGuardian(),
          )
        else ...[
          ..._guardians.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    g.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${g.relationshipLabel} • ${g.phoneNumber}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _addOrEditGuardian(index: i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() => _guardians.removeAt(i));
                          _emit();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          SecondaryButton(
            label: 'Add Guardian',
            icon: Icons.person_add_outlined,
            onPressed: () => _addOrEditGuardian(),
          ),
        ],
        const SizedBox(height: 20),
        const SectionHeader(title: 'Link Existing Sibling (optional)'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _siblingSearchController,
                decoration: const InputDecoration(
                  labelText: 'Sibling student code',
                  hintText:
                      'Enter an existing student\'s code to link as sibling',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (v) {
                  if (v.trim().isEmpty) return;
                  context.read<EnrollmentSetupWizardBloc>().add(
                    SiblingLinkRequested(v.trim()),
                  );
                },
              ),
              if (state.siblingStudentId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Linked sibling: ${state.siblingStudentId}',
                    style: TextStyle(
                      color: AppColors.success(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Link Guardians',
          onPressed: _guardians.isEmpty
              ? null
              : () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthAuthenticated) return;
                  context.read<EnrollmentSetupWizardBloc>().add(
                    GuardiansLinkRequested(authState.user),
                  );
                },
        ),
      ],
    );
  }
}

class _GuardianDialog extends StatefulWidget {
  final GuardianDraft? initial;
  const _GuardianDialog({this.initial});

  @override
  State<_GuardianDialog> createState() => _GuardianDialogState();
}

class _GuardianDialogState extends State<_GuardianDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  String _relationshipLabel = 'Guardian';
  bool _isLegalGuardian = false;
  bool _isPrimaryGuardian = false;
  bool _pickupAuthorized = false;

  static const _relationshipOptions = ['Father', 'Mother', 'Guardian', 'Other'];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _phoneController = TextEditingController(text: initial?.phoneNumber ?? '');
    _emailController = TextEditingController(text: initial?.email ?? '');
    _relationshipLabel = initial?.relationshipLabel ?? 'Guardian';
    if (!_relationshipOptions.contains(_relationshipLabel)) {
      _relationshipLabel = 'Other';
    }
    _isLegalGuardian = initial?.isLegalGuardian ?? false;
    _isPrimaryGuardian = initial?.isPrimaryGuardian ?? false;
    _pickupAuthorized = initial?.pickupAuthorized ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  RelationshipType get _type => switch (_relationshipLabel) {
    'Father' || 'Mother' => RelationshipType.parent,
    'Guardian' => RelationshipType.guardian,
    _ => RelationshipType.custom,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Guardian' : 'Edit Guardian'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _relationshipLabel,
              items: _relationshipOptions
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _relationshipLabel = v ?? _relationshipLabel),
              decoration: const InputDecoration(labelText: 'Relationship'),
            ),
            SwitchListTile(
              title: const Text('Legal guardian'),
              value: _isLegalGuardian,
              onChanged: (v) => setState(() => _isLegalGuardian = v),
            ),
            SwitchListTile(
              title: const Text('Primary guardian'),
              value: _isPrimaryGuardian,
              onChanged: (v) => setState(() => _isPrimaryGuardian = v),
            ),
            SwitchListTile(
              title: const Text('Pickup authorized'),
              value: _pickupAuthorized,
              onChanged: (v) => setState(() => _pickupAuthorized = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty ||
                _phoneController.text.trim().isEmpty) {
              return;
            }
            Navigator.pop(
              context,
              GuardianDraft(
                name: _nameController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                type: _type,
                relationshipLabel: _relationshipLabel,
                email: _emailController.text.trim().isEmpty
                    ? null
                    : _emailController.text.trim(),
                isLegalGuardian: _isLegalGuardian,
                isPrimaryGuardian: _isPrimaryGuardian,
                pickupAuthorized: _pickupAuthorized,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 3: Health & Emergency
// ---------------------------------------------------------------------
class _HealthEmergencyStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  const _HealthEmergencyStep({required this.state});

  @override
  State<_HealthEmergencyStep> createState() => _HealthEmergencyStepState();
}

class _HealthEmergencyStepState extends State<_HealthEmergencyStep> {
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _chronicController;
  late final TextEditingController _medicationsController;
  late final TextEditingController _disabilitiesController;
  late List<EmergencyContact> _contacts;

  @override
  void initState() {
    super.initState();
    final medical = widget.state.medicalInfo;
    _bloodGroupController = TextEditingController(
      text: medical?.bloodGroup ?? '',
    );
    _allergiesController = TextEditingController(
      text: (medical?.allergies ?? const []).join(', '),
    );
    _chronicController = TextEditingController(
      text: (medical?.chronicConditions ?? const []).join(', '),
    );
    _medicationsController = TextEditingController(
      text: medical?.medications ?? '',
    );
    _disabilitiesController = TextEditingController(
      text: medical?.disabilities ?? '',
    );
    _contacts = List.of(widget.state.emergencyContacts);
  }

  @override
  void dispose() {
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _chronicController.dispose();
    _medicationsController.dispose();
    _disabilitiesController.dispose();
    super.dispose();
  }

  List<String> _splitList(String text) =>
      text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  void _emit() {
    context.read<EnrollmentSetupWizardBloc>().add(
      HealthInfoUpdated(
        medicalInfo: MedicalInfo(
          bloodGroup: _bloodGroupController.text.trim().isEmpty
              ? null
              : _bloodGroupController.text.trim(),
          allergies: _splitList(_allergiesController.text),
          chronicConditions: _splitList(_chronicController.text),
          medications: _medicationsController.text.trim().isEmpty
              ? null
              : _medicationsController.text.trim(),
          disabilities: _disabilitiesController.text.trim().isEmpty
              ? null
              : _disabilitiesController.text.trim(),
        ),
        emergencyContacts: List.of(_contacts),
      ),
    );
  }

  Future<void> _addContact() async {
    final result = await showDialog<EmergencyContact>(
      context: context,
      builder: (_) => const _EmergencyContactDialog(),
    );
    if (result == null) return;
    setState(() => _contacts.add(result));
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Medical Information (optional)'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _bloodGroupController,
                onChanged: (_) => _emit(),
                decoration: const InputDecoration(
                  labelText: 'Blood group',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _allergiesController,
                onChanged: (_) => _emit(),
                decoration: const InputDecoration(
                  labelText: 'Allergies (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _chronicController,
                onChanged: (_) => _emit(),
                decoration: const InputDecoration(
                  labelText: 'Chronic conditions (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _medicationsController,
                onChanged: (_) => _emit(),
                decoration: const InputDecoration(
                  labelText: 'Medications',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _disabilitiesController,
                onChanged: (_) => _emit(),
                decoration: const InputDecoration(
                  labelText: 'Disabilities',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Emergency Contacts (optional)'),
        if (_contacts.isEmpty)
          EmptyState(
            icon: Icons.contact_phone_outlined,
            title: 'No emergency contacts yet',
            message: 'Add someone to notify in case of an emergency.',
            ctaLabel: 'Add Emergency Contact',
            onCtaPressed: _addContact,
          )
        else ...[
          ..._contacts.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    entry.value.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${entry.value.relationship} • ${entry.value.phoneNumber}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => _contacts.removeAt(entry.key));
                      _emit();
                    },
                  ),
                ),
              ),
            ),
          ),
          SecondaryButton(
            label: 'Add Emergency Contact',
            icon: Icons.contact_phone_outlined,
            onPressed: _addContact,
          ),
        ],
      ],
    );
  }
}

class _EmergencyContactDialog extends StatefulWidget {
  const _EmergencyContactDialog();
  @override
  State<_EmergencyContactDialog> createState() =>
      _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<_EmergencyContactDialog> {
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Emergency Contact'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(labelText: 'Relationship'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty ||
                _phoneController.text.trim().isEmpty) {
              return;
            }
            Navigator.pop(
              context,
              EmergencyContact(
                name: _nameController.text.trim(),
                relationship: _relationshipController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                email: _emailController.text.trim().isEmpty
                    ? null
                    : _emailController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 4: Transport
// ---------------------------------------------------------------------
class _TransportStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  const _TransportStep({required this.state});

  @override
  State<_TransportStep> createState() => _TransportStepState();
}

class _TransportStepState extends State<_TransportStep> {
  String? _selectedRouteName;

  @override
  void initState() {
    super.initState();
    _selectedRouteName = widget.state.transportInfo;
  }

  void _emit(String? routeName) {
    setState(() => _selectedRouteName = routeName);
    context.read<EnrollmentSetupWizardBloc>().add(
      TransportInfoUpdated(routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final structureRepo = sl<StructureRepository>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Transport (optional)'),
        AppCard(
          child: StreamBuilder<List<TransportRoute>>(
            stream: structureRepo.watchTransportRoutes(widget.state.schoolId),
            builder: (context, snap) {
              final routes = (snap.data ?? [])
                  .where((r) => r.isActive)
                  .toList();
              final currentValue =
                  routes.any((r) => r.name == _selectedRouteName)
                  ? _selectedRouteName
                  : null;
              return DropdownButtonFormField<String?>(
                initialValue: currentValue,
                decoration: const InputDecoration(
                  labelText: 'Bus route',
                  hintText: 'Select a route (optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No transport'),
                  ),
                  ...routes.map(
                    (r) => DropdownMenuItem<String?>(
                      value: r.name,
                      child: Text(r.name),
                    ),
                  ),
                ],
                onChanged: _emit,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 5: Admission
// ---------------------------------------------------------------------
class _AdmissionStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  final AdmissionApplication application;
  const _AdmissionStep({required this.state, required this.application});

  @override
  State<_AdmissionStep> createState() => _AdmissionStepState();
}

class _AdmissionStepState extends State<_AdmissionStep> {
  static const _joiningStatusOptions = [
    'New admission',
    'Transfer',
    'Re-admission',
  ];

  late StudentBoardingType _boardingType;
  late String _joiningStatus;

  @override
  void initState() {
    super.initState();
    _boardingType = widget.state.boardingType ?? StudentBoardingType.day;
    final current = widget.state.joiningStatus;
    _joiningStatus = _joiningStatusOptions.contains(current)
        ? current!
        : _joiningStatusOptions.first;
  }

  void _emit() {
    context.read<EnrollmentSetupWizardBloc>().add(
      AdmissionDetailsUpdated(
        boardingType: _boardingType,
        joiningStatus: _joiningStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final structureRepo = sl<StructureRepository>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Admission Summary'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 20,
                      color: AppColors.textMuted(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.studentCode,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Admission #${state.admissionNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                StreamBuilder<List<AcademicYear>>(
                  stream: structureRepo.watchAcademicYears(state.schoolId),
                  builder: (context, snap) {
                    final years = snap.data ?? const <AcademicYear>[];
                    final match = years
                        .where((y) => y.id == widget.application.academicYearId)
                        .toList();
                    final label = match.isNotEmpty
                        ? match.first.name
                        : (years.isEmpty ? 'Loading…' : 'Unknown year');
                    return _kv(context, 'Academic year', label);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Student Type'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<StudentBoardingType>(
                  segments: const [
                    ButtonSegment(
                      value: StudentBoardingType.day,
                      label: Text('Day'),
                    ),
                    ButtonSegment(
                      value: StudentBoardingType.boarding,
                      label: Text('Boarding'),
                    ),
                  ],
                  selected: {_boardingType},
                  onSelectionChanged: (selection) {
                    setState(() => _boardingType = selection.first);
                    _emit();
                  },
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _joiningStatus,
                items: _joiningStatusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _joiningStatus = v);
                  _emit();
                },
                decoration: const InputDecoration(labelText: 'Joining status'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(k, style: TextStyle(color: AppColors.textMuted(context))),
        ),
        Expanded(
          child: Text(
            v,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------
// Step 2: Academic Placement
// ---------------------------------------------------------------------
class _AcademicPlacementStep extends StatelessWidget {
  final EnrollmentSetupWizardState state;
  const _AcademicPlacementStep({required this.state});

  @override
  Widget build(BuildContext context) {
    final structureRepo = sl<StructureRepository>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Placement'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<List<SchoolClass>>(
              stream: structureRepo.watchClasses(state.schoolId),
              builder: (context, classSnap) {
                final classes = classSnap.data ?? const <SchoolClass>[];
                final classMatch = classes.where((c) => c.id == state.classId);
                final classLabel = classMatch.isNotEmpty
                    ? classMatch.first.name
                    : (classes.isEmpty ? 'Loading…' : 'Unknown class');
                return StreamBuilder<List<ClassStream>>(
                  stream: structureRepo.watchStreams(state.schoolId),
                  builder: (context, streamSnap) {
                    final streams = streamSnap.data ?? const <ClassStream>[];
                    final streamMatch = streams.where(
                      (s) => s.id == state.streamId,
                    );
                    final streamLabel = streamMatch.isNotEmpty
                        ? streamMatch.first.name
                        : (streams.isEmpty ? 'Loading…' : 'Unknown stream');
                    return StreamBuilder<List<AcademicYear>>(
                      stream: structureRepo.watchAcademicYears(state.schoolId),
                      builder: (context, yearSnap) {
                        final years = yearSnap.data ?? const <AcademicYear>[];
                        final yearMatch = years.where(
                          (y) => y.id == state.academicYearId,
                        );
                        final yearLabel = yearMatch.isNotEmpty
                            ? yearMatch.first.name
                            : (years.isEmpty ? 'Loading…' : 'Unknown year');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Class: $classLabel',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            if (state.streamId != null)
                              Text(
                                'Stream: $streamLabel',
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            Text(
                              'Academic year: $yearLabel',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Subjects & Teachers'),
        StreamBuilder<List<Subject>>(
          stream: structureRepo.watchSubjects(state.schoolId),
          builder: (context, subjectSnap) {
            final subjects = (subjectSnap.data ?? [])
                .where((s) => s.assignedClassIds.contains(state.classId))
                .toList();
            if (subjects.isEmpty) {
              return const EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No subjects configured',
                message: 'No subjects are assigned to this class yet.',
              );
            }
            return StreamBuilder<List<dynamic>>(
              stream: sl<CurriculumAssignmentRepository>().watchAssignments(),
              builder: (context, curriculumSnap) {
                return StreamBuilder<List<dynamic>>(
                  stream: sl<TeachingAssignmentRepository>().watchAssignments(),
                  builder: (context, teachingSnap) {
                    final teaching = teachingSnap.data ?? [];
                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final subject in subjects) ...[
                            Builder(
                              builder: (context) {
                                final match = teaching.where((a) {
                                  final dyn = a as dynamic;
                                  return dyn.classId == state.classId &&
                                      dyn.subjectId == subject.id &&
                                      dyn.isActive == true;
                                });
                                final teacherLabel = match.isEmpty
                                    ? 'Teacher not assigned'
                                    : 'Assigned (staffId: ${(match.first as dynamic).staffId})';
                                return ListTile(
                                  title: Text(subject.name),
                                  subtitle: Text(teacherLabel),
                                  leading: const Icon(Icons.book_outlined),
                                );
                              },
                            ),
                            if (subject != subjects.last)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 3: Finance
// ---------------------------------------------------------------------
class _FinanceStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  const _FinanceStep({required this.state});

  @override
  State<_FinanceStep> createState() => _FinanceStepState();
}

class _FinanceStepState extends State<_FinanceStep> {
  // The current academic period (year+term) the school admin has flagged in
  // Structure > Academics, resolved once so the fee-plan match query is
  // scoped to it exactly like the backend expects.
  late Future<AcademicPeriod> _currentPeriodFuture;

  // Guards a single findMatchingFeePlan call per resolved period so it
  // doesn't refire on every rebuild.
  Future<Either<Failure, MatchedFeePlan?>>? _matchFuture;
  String? _matchedForKey;

  @override
  void initState() {
    super.initState();
    _currentPeriodFuture = sl<AcademicCalendarService>().getCurrentPeriod(
      widget.state.schoolId,
    );
  }

  /// Maps the wizard's boarding-type selection to the studentCategory string
  /// `findMatchingFeePlan`/`publishFeePlan` key their selector on. Defaults
  /// to 'day' (the backend's own default) when boarding type isn't set yet
  /// - matching AdmissionService's existing 'day' fallback behaviour.
  String _studentCategory(EnrollmentSetupWizardState state) =>
      state.boardingType?.name ?? 'day';

  void _lookupMatch(EnrollmentSetupWizardState state, AcademicPeriod period) {
    final key =
        '${period.academicYearId}|${period.termId}|${state.classId}|${_studentCategory(state)}';
    if (_matchedForKey == key) return;
    _matchedForKey = key;

    if (!period.hasYear || !period.hasTerm || state.classId.isEmpty) {
      _matchFuture = Future.value(const Right(null));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<EnrollmentSetupWizardBloc>().add(
          const FeePlanMatchUpdated(billingPending: true),
        );
      });
      return;
    }

    final future = sl<FeeBillingRepository>().findMatchingFeePlan(
      schoolId: state.schoolId,
      academicYearId: period.academicYearId,
      termId: period.termId,
      classId: state.classId,
      studentCategory: _studentCategory(state),
    );
    _matchFuture = future;
    future.then((result) {
      if (!mounted) return;
      final match = result.fold((_) => null, (m) => m);
      context.read<EnrollmentSetupWizardBloc>().add(
        FeePlanMatchUpdated(
          planId: match?.planId,
          versionId: match?.versionId,
          planName: match?.name,
          totalUgx: match?.totalUgx,
          lines: (match?.lines ?? const [])
              .map(
                (l) => FeePlanLineData(
                  chargeId: l.chargeId,
                  name: l.name,
                  amountUgx: l.amountUgx,
                  required: l.required,
                  serviceKey: l.serviceKey,
                ),
              )
              .toList(),
          billingPending: match == null,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return FutureBuilder<AcademicPeriod>(
      future: _currentPeriodFuture,
      builder: (context, periodSnapshot) {
        final period = periodSnapshot.data;
        if (period == null) {
          return const Center(child: SchoolPulseLoader());
        }
        _lookupMatch(state, period);
        return FutureBuilder<Either<Failure, MatchedFeePlan?>>(
          future: _matchFuture,
          builder: (context, matchSnapshot) {
            final loading = !matchSnapshot.hasData;
            final match = matchSnapshot.data?.fold((_) => null, (m) => m);
            return _buildContent(context, state, period, loading, match);
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    EnrollmentSetupWizardState state,
    AcademicPeriod period,
    bool loading,
    MatchedFeePlan? match,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Fee Plan'),
        if (period.termName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Current term: ${period.termName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (loading)
          const AppCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: SchoolPulseLoader()),
            ),
          )
        else if (match == null)
          _billingPendingCard(context)
        else
          _matchedPlanCard(context, match),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Scholarship / Discount'),
        if (state.hasScholarshipAward)
          Text(
            'A scholarship/discount award has been recorded for this student.',
            style: TextStyle(color: AppColors.success(context)),
          )
        else
          SecondaryButton(
            label: 'Add scholarship / discount',
            icon: Icons.card_giftcard_outlined,
            onPressed: () => _showScholarshipDialog(context),
          ),
      ],
    );
  }

  Widget _billingPendingCard(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hourglass_top_outlined,
                  color: AppColors.warning(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Billing pending',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'No published fee plan matches this class, term and student '
              'category yet. You can continue enrolling this student - '
              'billing will stay pending and visible on Review until a fee '
              'plan is published for this selection in Structure > '
              'Academics > Fee Plans.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Open Fee Plans',
              icon: Icons.receipt_long_outlined,
              onPressed: () =>
                  context.push('/staff/admin/structure/academics/fee-structures'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchedPlanCard(BuildContext context, MatchedFeePlan match) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              match.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final line in match.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(line.name)),
                    Text(CurrencyFormatter.ugx(line.amountUgx.toDouble())),
                  ],
                ),
              ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total billed',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  CurrencyFormatter.ugx(match.totalUgx.toDouble()),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showScholarshipDialog(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final result = await showDialog<_ScholarshipInput>(
      context: context,
      builder: (_) => const _ScholarshipDialog(),
    );
    if (result == null || !context.mounted) return;
    context.read<EnrollmentSetupWizardBloc>().add(
      ScholarshipAwardRequested(
        operatorUser: authState.user,
        type: result.type,
        amountOrPercentage: result.amount,
        isPercentage: result.isPercentage,
        effectiveStart: DateTime.now(),
        reason: result.reason,
      ),
    );
  }
}

class _ScholarshipInput {
  final ScholarshipAwardType type;
  final double amount;
  final bool isPercentage;
  final String reason;
  _ScholarshipInput(this.type, this.amount, this.isPercentage, this.reason);
}

class _ScholarshipDialog extends StatefulWidget {
  const _ScholarshipDialog();
  @override
  State<_ScholarshipDialog> createState() => _ScholarshipDialogState();
}

class _ScholarshipDialogState extends State<_ScholarshipDialog> {
  ScholarshipAwardType _type = ScholarshipAwardType.partial;
  bool _isPercentage = true;
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scholarship / Discount'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<ScholarshipAwardType>(
              initialValue: _type,
              items: ScholarshipAwardType.values
                  .where((t) => t != ScholarshipAwardType.none)
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Value'),
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('%'),
                  selected: _isPercentage,
                  onSelected: (v) => setState(() => _isPercentage = true),
                ),
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('Amount'),
                  selected: !_isPercentage,
                  onSelected: (v) => setState(() => _isPercentage = false),
                ),
              ],
            ),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text.trim());
            if (amount == null) return;
            Navigator.pop(
              context,
              _ScholarshipInput(
                _type,
                amount,
                _isPercentage,
                _reasonController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 4: Boarding / House
// ---------------------------------------------------------------------
class _BoardingHouseStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  const _BoardingHouseStep({required this.state});

  @override
  State<_BoardingHouseStep> createState() => _BoardingHouseStepState();
}

class _BoardingHouseStepState extends State<_BoardingHouseStep> {
  String? _hostelId;
  String? _roomId;
  final _bedController = TextEditingController();

  @override
  void dispose() {
    _bedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final structureRepo = sl<StructureRepository>();
    final isBoarding = state.boardingType == StudentBoardingType.boarding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isBoarding)
          AppCard(
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textMuted(context)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Day student — boarding not applicable.'),
                ),
              ],
            ),
          )
        else ...[
          const SectionHeader(title: 'Dormitory Assignment'),
          if (state.dormitoryAssigned)
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success(context),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Assigned: ${state.hostelId} / room ${state.roomId} / '
                      'bed ${state.bed}',
                      style: TextStyle(
                        color: AppColors.success(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            AppCard(
              child: StreamBuilder<List<Hostel>>(
                stream: structureRepo.watchHostels(state.schoolId),
                builder: (context, hostelSnap) {
                  final hostels = hostelSnap.data ?? [];
                  final selectedHostel = hostels
                      .where((h) => h.id == _hostelId)
                      .firstOrNull;
                  return StreamBuilder<List<HostelRoom>>(
                    stream: structureRepo.watchHostelRooms(state.schoolId),
                    builder: (context, roomSnap) {
                      final rooms = (roomSnap.data ?? [])
                          .where((r) => r.hostelId == _hostelId)
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _hostelId,
                            items: hostels
                                .map(
                                  (h) => DropdownMenuItem(
                                    value: h.id,
                                    child: Text(h.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              _hostelId = v;
                              _roomId = null;
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Hostel',
                            ),
                          ),
                          if (selectedHostel != null)
                            _HostelWardenLabel(hostel: selectedHostel),
                          const SizedBox(height: 12),
                          StreamBuilder<Map<String, int>>(
                            stream: _hostelId == null
                                ? const Stream.empty()
                                : sl<EnrollmentSetupRepository>()
                                      .watchOccupiedBedCounts(
                                        state.schoolId,
                                        _hostelId!,
                                      ),
                            builder: (context, occupiedSnap) {
                              final occupied = occupiedSnap.data ?? const {};
                              return DropdownButtonFormField<String>(
                                initialValue: _roomId,
                                items: rooms.map((r) {
                                  final taken = occupied[r.id] ?? 0;
                                  final label = r.bedCapacity > 0
                                      ? '${r.roomNumber} '
                                            '($taken/${r.bedCapacity} beds free: '
                                            '${(r.bedCapacity - taken).clamp(0, r.bedCapacity)})'
                                      : r.roomNumber;
                                  return DropdownMenuItem(
                                    value: r.id,
                                    child: Text(label),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _roomId = v),
                                decoration: const InputDecoration(
                                  labelText: 'Room',
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _bedController,
                            decoration: const InputDecoration(
                              labelText: 'Bed identifier',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            label: 'Assign Bed',
                            onPressed:
                                _hostelId == null ||
                                    _roomId == null ||
                                    _bedController.text.trim().isEmpty
                                ? null
                                : () => _assign(context),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
        ],
        const SizedBox(height: 24),
        const SectionHeader(title: 'House (optional)'),
        StreamBuilder<List<House>>(
          stream: structureRepo.watchHouses(state.schoolId),
          builder: (context, houseSnap) {
            final houses = houseSnap.data ?? [];
            if (houses.isEmpty) {
              return const EmptyState(
                icon: Icons.holiday_village_outlined,
                title: 'No houses configured',
                message:
                    'No houses/dorms have been set up for this school yet.',
              );
            }
            return AppCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: houses
                    .map(
                      (h) => ChoiceChip(
                        label: Text(h.name),
                        selected: state.houseId == h.id,
                        onSelected: (_) => context
                            .read<EnrollmentSetupWizardBloc>()
                            .add(HouseSelected(h.id)),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _assign(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<EnrollmentSetupWizardBloc>().add(
      DormitoryAssignmentRequested(
        operatorUser: authState.user,
        hostelId: _hostelId!,
        roomId: _roomId!,
        bed: _bedController.text.trim(),
      ),
    );
  }
}

/// Shows the hostel's assigned Matron/Patron staff record when one exists
/// (`Hostel.wardenStaffId`), falling back to the free-text warden fields
/// entered before any formal staff assignment was made.
class _HostelWardenLabel extends StatelessWidget {
  final Hostel hostel;
  const _HostelWardenLabel({required this.hostel});

  @override
  Widget build(BuildContext context) {
    final staffId = hostel.wardenStaffId;
    if (staffId == null || staffId.isEmpty) {
      return _label(context, hostel.wardenName, hostel.wardenContact);
    }
    return FutureBuilder(
      future: sl<GetStaffMembers>()(NoParams()),
      builder: (context, snap) {
        final staff = snap.data
            ?.getOrElse(() => const [])
            .where((s) => s.id == staffId)
            .firstOrNull;
        if (staff == null) {
          return _label(context, hostel.wardenName, hostel.wardenContact);
        }
        return _label(
          context,
          staff.name,
          staff.phoneNumber ?? staff.alternatePhone ?? '',
        );
      },
    );
  }

  Widget _label(BuildContext context, String name, String contact) {
    if (name.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        'Warden: $name${contact.isNotEmpty ? ' • $contact' : ''}',
        style: TextStyle(fontSize: 12.5, color: AppColors.textMuted(context)),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Step 5: Clubs
// ---------------------------------------------------------------------
class _ClubsStep extends StatelessWidget {
  final EnrollmentSetupWizardState state;
  const _ClubsStep({required this.state});

  @override
  Widget build(BuildContext context) {
    final structureRepo = sl<StructureRepository>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Clubs & Activities (optional)'),
        StreamBuilder<List<Club>>(
          stream: structureRepo.watchClubs(state.schoolId),
          builder: (context, snapshot) {
            final clubs = snapshot.data ?? [];
            if (clubs.isEmpty) {
              return const EmptyState(
                icon: Icons.groups_outlined,
                title: 'No clubs configured',
                message: 'No clubs/societies have been set up yet.',
              );
            }
            return AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final c in clubs) ...[
                    CheckboxListTile(
                      title: Text(
                        c.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(c.category),
                      value: state.selectedClubIds.contains(c.id),
                      onChanged: (v) => context
                          .read<EnrollmentSetupWizardBloc>()
                          .add(ClubMembershipToggled(c.id, v ?? false)),
                    ),
                    if (c != clubs.last) const Divider(height: 1),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SecondaryButton(
              label: 'Skip',
              onPressed: () => context.read<EnrollmentSetupWizardBloc>().add(
                const ClubMembershipsSaveRequested(),
              ),
            ),
            const SizedBox(width: 12),
            PrimaryButton(
              label: state.clubsSaved ? 'Saved' : 'Save Selections',
              onPressed: state.clubsSaved
                  ? null
                  : () => context.read<EnrollmentSetupWizardBloc>().add(
                      const ClubMembershipsSaveRequested(),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 7: Student Identity
// ---------------------------------------------------------------------
class _IdentityStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  const _IdentityStep({required this.state});

  @override
  State<_IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<_IdentityStep> {
  final _nfcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Issue-or-load the QR identity immediately rather than deferring to
    // activation - getStudentIdentity is idempotent (issues once, loads
    // thereafter), so this is safe to fire every time the step is shown.
    if (!widget.state.identityExists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final authState = context.read<AuthBloc>().state;
        if (authState is! AuthAuthenticated) return;
        context.read<EnrollmentSetupWizardBloc>().add(
          IdentityPreviewRequested(authState.user),
        );
      });
    }
  }

  @override
  void dispose() {
    _nfcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Student Identity'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv(context, 'Student code', state.studentCode),
                const SizedBox(height: 8),
                _kv(context, 'Admission number', state.admissionNumber),
                const Divider(height: 24),
                if (state.identityExists && state.qrCodeData != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        color: AppColors.success(context),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'QR identity: ${state.qrCodeData}',
                          style: TextStyle(
                            color: AppColors.success(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                else if (state.identityExists)
                  Text(
                    'QR identity is ready.',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  )
                else
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Generating QR identity…',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'NFC Card'),
        AppCard(
          child: state.nfcRegistered
              ? Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success(context)),
                    const SizedBox(width: 10),
                    Text(
                      'NFC registered.',
                      style: TextStyle(
                        color: AppColors.success(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : state.nfcSkipped
              ? const Text('NFC registration skipped.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Only needed if a physical NFC card is being bound to '
                      'this student now. Skip to proceed with the QR '
                      'identity above - a card can be registered later '
                      'from Verification.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nfcController,
                      decoration: const InputDecoration(
                        labelText: 'Scan/enter card UID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: 'Skip',
                            onPressed: () => context
                                .read<EnrollmentSetupWizardBloc>()
                                .add(const NfcRegistrationSkipped()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Register NFC',
                            onPressed: _nfcController.text.trim().isEmpty
                                ? null
                                : () => _register(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Row(
    children: [
      SizedBox(
        width: 150,
        child: Text(k, style: TextStyle(color: AppColors.textMuted(context))),
      ),
      Expanded(
        child: Text(
          v,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  void _register(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<EnrollmentSetupWizardBloc>().add(
      NfcRegistrationRequested(
        operatorUser: authState.user,
        credentialValue: _nfcController.text.trim(),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Step 8: Review & Activate
// ---------------------------------------------------------------------
class _ReviewStep extends StatelessWidget {
  final EnrollmentSetupWizardState state;
  const _ReviewStep({required this.state});

  @override
  Widget build(BuildContext context) {
    final required = <_ChecklistEntry>[
      _ChecklistEntry('Academic year set', state.academicYearId.isNotEmpty),
      _ChecklistEntry('Class assigned', state.classId.isNotEmpty),
      _ChecklistEntry('Student code issued', state.studentCode.isNotEmpty),
      _ChecklistEntry(
        'At least one guardian added',
        state.guardians.isNotEmpty,
      ),
      _ChecklistEntry('Guardians linked', state.guardiansLinked),
    ];
    final optional = <_ChecklistEntry>[
      _ChecklistEntry('NFC card registered', state.nfcRegistered),
      _ChecklistEntry(
        state.boardingType?.name == 'boarding'
            ? 'Dormitory assigned'
            : 'Boarding not applicable (day student)',
        state.boardingType?.name != 'boarding' || state.dormitoryAssigned,
      ),
      _ChecklistEntry('House selected', state.houseId != null),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Billing'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  state.billingPending
                      ? Icons.hourglass_top_outlined
                      : Icons.check_circle_outline,
                  color: state.billingPending
                      ? AppColors.warning(context)
                      : AppColors.success(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.billingPending
                        ? 'Billing pending - no published fee plan matched '
                              'this class/term/category. Activation will '
                              'still proceed; a bill can be issued once a '
                              'fee plan is published.'
                        : '${state.matchedFeePlanName ?? 'Fee plan'} - '
                              '${CurrencyFormatter.ugx((state.matchedFeePlanTotalUgx ?? 0).toDouble())} '
                              'will be billed on activation.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Required'),
        _checklistCard(context, required),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Optional'),
        _checklistCard(context, optional),
        const SizedBox(height: 24),
        PrimaryButton(
          label: state.activated ? 'Activated' : 'Activate Student',
          isLoading: state.isActivating,
          onPressed: !state.canActivate || state.isActivating || state.activated
              ? null
              : () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthAuthenticated) return;
                  context.read<EnrollmentSetupWizardBloc>().add(
                    ActivationRequested(authState.user),
                  );
                },
        ),
      ],
    );
  }

  Widget _checklistCard(BuildContext context, List<_ChecklistEntry> items) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final item in items) ...[
            _checkItem(context, item.label, item.done),
            if (item != items.last) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _checkItem(BuildContext context, String label, bool done) {
    return ListTile(
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? AppColors.success(context) : AppColors.textMuted(context),
      ),
      title: Text(label),
    );
  }
}

class _ChecklistEntry {
  final String label;
  final bool done;
  _ChecklistEntry(this.label, this.done);
}
