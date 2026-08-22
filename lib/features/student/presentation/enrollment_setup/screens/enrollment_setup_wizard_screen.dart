import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/admission_application.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/hostel_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/teaching_assignment_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/curriculum_assignment_repository.dart';
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
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
    'Admission',
    'Academic Placement',
    'Finance',
    'Boarding / House',
    'Clubs & Activities',
    'Parent / Guardian',
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
            const SnackBar(content: Text('Student activated successfully.')),
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
                _StepIndicator(state: state, titles: _stepTitles),
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
        return _AdmissionStep(state: state, application: application);
      case 1:
        return _AcademicPlacementStep(state: state);
      case 2:
        return _FinanceStep(state: state);
      case 3:
        return _BoardingHouseStep(state: state);
      case 4:
        return _ClubsStep(state: state);
      case 5:
        return _ParentStep(state: state);
      case 6:
        return _IdentityStep(state: state);
      case 7:
      default:
        return _ReviewStep(state: state);
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final EnrollmentSetupWizardState state;
  final List<String> titles;
  const _StepIndicator({required this.state, required this.titles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            'Step ${state.currentStep + 1} of ${titles.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titles[state.currentStep],
              style: TextStyle(color: AppColors.textSecondary(context)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final EnrollmentSetupWizardState state;
  const _NavBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EnrollmentSetupWizardBloc>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          if (!state.isFirstStep)
            SecondaryButton(
              label: 'Back',
              onPressed: state.isLoading || state.isActivating
                  ? null
                  : () => bloc.add(const WizardPreviousStep()),
            ),
          const Spacer(),
          if (!state.isLastStep)
            PrimaryButton(
              label: 'Next',
              onPressed: state.isLoading
                  ? null
                  : () => bloc.add(const WizardNextStep()),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Step 1: Admission
// ---------------------------------------------------------------------
class _AdmissionStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  final AdmissionApplication application;
  const _AdmissionStep({required this.state, required this.application});

  @override
  State<_AdmissionStep> createState() => _AdmissionStepState();
}

class _AdmissionStepState extends State<_AdmissionStep> {
  late StudentBoardingType _boardingType;
  late final TextEditingController _joiningStatusController;

  @override
  void initState() {
    super.initState();
    _boardingType = widget.state.boardingType ?? StudentBoardingType.day;
    _joiningStatusController = TextEditingController(
      text: widget.state.joiningStatus ?? 'New admission',
    );
  }

  @override
  void dispose() {
    _joiningStatusController.dispose();
    super.dispose();
  }

  void _emit() {
    context.read<EnrollmentSetupWizardBloc>().add(
      AdmissionDetailsUpdated(
        boardingType: _boardingType,
        joiningStatus: _joiningStatusController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final application = widget.application;
    final state = widget.state;
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
                _kv(context, 'Admission number', state.admissionNumber),
                _kv(context, 'Student code', state.studentCode),
                _kv(context, 'Academic year', application.academicYearId),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Student Type'),
        SegmentedButton<StudentBoardingType>(
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
        const SizedBox(height: 20),
        const SectionHeader(title: 'Joining Status'),
        TextField(
          controller: _joiningStatusController,
          onChanged: (_) => _emit(),
          decoration: const InputDecoration(
            hintText: 'e.g. New admission, Transfer, Re-admission',
            border: OutlineInputBorder(),
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
          child: Text(v, style: TextStyle(color: AppColors.textPrimary(context))),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Class: ${state.classId}',
                    style: TextStyle(color: AppColors.textPrimary(context))),
                if (state.streamId != null)
                  Text('Stream: ${state.streamId}',
                      style: TextStyle(color: AppColors.textPrimary(context))),
                Text('Academic year: ${state.academicYearId}',
                    style: TextStyle(color: AppColors.textPrimary(context))),
              ],
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
                    return Column(
                      children: subjects.map((subject) {
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
                      }).toList(),
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
  String? _selectedFeeStructureId;
  final _termController = TextEditingController();
  final _totalBilledController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedFeeStructureId = widget.state.feeStructureId;
    _termController.text = widget.state.term ?? '';
    _totalBilledController.text = widget.state.totalBilled?.toString() ?? '';
  }

  @override
  void dispose() {
    _termController.dispose();
    _totalBilledController.dispose();
    super.dispose();
  }

  void _emit() {
    context.read<EnrollmentSetupWizardBloc>().add(
      FinanceDetailsUpdated(
        feeStructureId: _selectedFeeStructureId,
        term: _termController.text.trim().isEmpty
            ? null
            : _termController.text.trim(),
        totalBilled: double.tryParse(_totalBilledController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeRepo = sl<FinanceRepository>();
    final state = widget.state;
    return FutureBuilder(
      future: financeRepo.getFeeStructures(state.schoolId),
      builder: (context, snapshot) {
        final structures = snapshot.data?.fold((_) => <dynamic>[], (v) => v) ?? [];
        final filtered = structures.where((s) {
          final dyn = s as dynamic;
          final matchesYear = dyn.academicYear == state.academicYearId;
          final matchesType = state.boardingType == null
              ? true
              : dyn.studentCategory.toString().toLowerCase() ==
                  state.boardingType!.name.toLowerCase();
          return matchesYear && matchesType;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Fee Structure'),
            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No matching fee structures',
                message:
                    'No fee structure matches this student\'s year/type yet.',
              )
            else
              ...filtered.map((s) {
                final dyn = s as dynamic;
                return RadioListTile<String>(
                  value: dyn.id as String,
                  groupValue: _selectedFeeStructureId,
                  title: Text(dyn.name as String),
                  subtitle: Text(
                    'UGX ${dyn.totalAmount} • ${dyn.studentCategory}',
                  ),
                  onChanged: (v) {
                    setState(() => _selectedFeeStructureId = v);
                    _emit();
                  },
                );
              }),
            const SizedBox(height: 16),
            TextField(
              controller: _termController,
              onChanged: (_) => _emit(),
              decoration: const InputDecoration(
                labelText: 'Term',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalBilledController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _emit(),
              decoration: const InputDecoration(
                labelText: 'Total billed',
                border: OutlineInputBorder(),
              ),
            ),
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
      },
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
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('Day student — boarding not applicable.'),
          )
        else ...[
          const SectionHeader(title: 'Dormitory Assignment'),
          if (state.dormitoryAssigned)
            Text(
              'Assigned: ${state.hostelId} / room ${state.roomId} / bed ${state.bed}',
              style: TextStyle(color: AppColors.success(context)),
            )
          else
            StreamBuilder<List<Hostel>>(
              stream: structureRepo.watchHostels(state.schoolId),
              builder: (context, hostelSnap) {
                final hostels = hostelSnap.data ?? [];
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
                          onChanged: (v) =>
                              setState(() {
                                _hostelId = v;
                                _roomId = null;
                              }),
                          decoration: const InputDecoration(labelText: 'Hostel'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _roomId,
                          items: rooms
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r.id,
                                  child: Text(r.roomNumber),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _roomId = v),
                          decoration: const InputDecoration(labelText: 'Room'),
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
                          onPressed: _hostelId == null ||
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
        ],
        const SizedBox(height: 24),
        const SectionHeader(title: 'House (optional)'),
        StreamBuilder<List<House>>(
          stream: structureRepo.watchHouses(state.schoolId),
          builder: (context, houseSnap) {
            final houses = houseSnap.data ?? [];
            if (houses.isEmpty) {
              return const Text('No houses configured.');
            }
            return Wrap(
              spacing: 8,
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
            return Column(
              children: clubs
                  .map(
                    (c) => CheckboxListTile(
                      title: Text(c.name),
                      subtitle: Text(c.category),
                      value: state.selectedClubIds.contains(c.id),
                      onChanged: (v) => context
                          .read<EnrollmentSetupWizardBloc>()
                          .add(ClubMembershipToggled(c.id, v ?? false)),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SecondaryButton(
              label: 'Skip',
              onPressed: () => context
                  .read<EnrollmentSetupWizardBloc>()
                  .add(const ClubMembershipsSaveRequested()),
            ),
            const SizedBox(width: 12),
            PrimaryButton(
              label: state.clubsSaved ? 'Saved' : 'Save Selections',
              onPressed: state.clubsSaved
                  ? null
                  : () => context
                      .read<EnrollmentSetupWizardBloc>()
                      .add(const ClubMembershipsSaveRequested()),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Step 6: Parent / Guardian
// ---------------------------------------------------------------------
class _ParentStep extends StatefulWidget {
  final EnrollmentSetupWizardState state;
  const _ParentStep({required this.state});

  @override
  State<_ParentStep> createState() => _ParentStepState();
}

class _ParentStepState extends State<_ParentStep> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLegalGuardian = false;
  bool _isPrimaryGuardian = true;
  bool _financialAccess = false;
  bool _pickupAuthorized = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.parentLinked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Parent / Guardian'),
          Text(
            'Linked — parent access code: ${state.parentAccessCode}',
            style: TextStyle(color: AppColors.success(context)),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Parent / Guardian'),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Parent/guardian name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            border: OutlineInputBorder(),
          ),
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
          title: const Text('Financial access'),
          value: _financialAccess,
          onChanged: (v) => setState(() => _financialAccess = v),
        ),
        SwitchListTile(
          title: const Text('Pickup authorized'),
          value: _pickupAuthorized,
          onChanged: (v) => setState(() => _pickupAuthorized = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SecondaryButton(
              label: 'Skip',
              onPressed: () => context
                  .read<EnrollmentSetupWizardBloc>()
                  .add(const ParentLinkSkipped()),
            ),
            const SizedBox(width: 12),
            PrimaryButton(
              label: 'Link Parent',
              onPressed: _phoneController.text.trim().isEmpty
                  ? null
                  : () => _link(context),
            ),
          ],
        ),
      ],
    );
  }

  void _link(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<EnrollmentSetupWizardBloc>().add(
      ParentLinkRequested(
        operatorUser: authState.user,
        phoneNumber: _phoneController.text.trim(),
        parentName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        isLegalGuardian: _isLegalGuardian,
        isPrimaryGuardian: _isPrimaryGuardian,
        financialAccess: _financialAccess,
        pickupAuthorized: _pickupAuthorized,
      ),
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
                Text('Student code: ${state.studentCode}',
                    style: TextStyle(color: AppColors.textPrimary(context))),
                Text('Admission number: ${state.admissionNumber}',
                    style: TextStyle(color: AppColors.textPrimary(context))),
                const SizedBox(height: 8),
                Text(
                  state.identityExists
                      ? 'QR identity is ready.'
                      : 'QR identity will be generated on activation.',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'NFC Card'),
        if (state.nfcRegistered)
          Text('NFC registered.', style: TextStyle(color: AppColors.success(context)))
        else if (state.nfcSkipped)
          const Text('NFC registration skipped.')
        else ...[
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
              SecondaryButton(
                label: 'Skip',
                onPressed: () => context
                    .read<EnrollmentSetupWizardBloc>()
                    .add(const NfcRegistrationSkipped()),
              ),
              const SizedBox(width: 12),
              PrimaryButton(
                label: 'Register NFC',
                onPressed: _nfcController.text.trim().isEmpty
                    ? null
                    : () => _register(context),
              ),
            ],
          ),
        ],
      ],
    );
  }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Required'),
        _checkItem(context, 'Academic year set', state.academicYearId.isNotEmpty),
        _checkItem(context, 'Class assigned', state.classId.isNotEmpty),
        _checkItem(context, 'Student code issued', state.studentCode.isNotEmpty),
        _checkItem(
          context,
          'Parent linked (or explicitly skipped)',
          state.parentLinked || state.parentLinkSkippedFlag,
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Optional'),
        _checkItem(context, 'NFC card registered', state.nfcRegistered),
        _checkItem(
          context,
          state.boardingType?.name == 'boarding'
              ? 'Dormitory assigned'
              : 'Boarding not applicable (day student)',
          state.boardingType?.name != 'boarding' || state.dormitoryAssigned,
        ),
        _checkItem(context, 'House selected', state.houseId != null),
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
