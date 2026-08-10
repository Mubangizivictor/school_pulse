import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/entities/student_enums.dart';
import '../bloc/enrollment_wizard_bloc.dart';
import '../bloc/enrollment_wizard_event.dart';
import '../bloc/enrollment_wizard_state.dart';

class EnrollmentWizardScreen extends StatelessWidget {
  final String schoolId;

  const EnrollmentWizardScreen({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EnrollmentWizardBloc>(),
      child: _EnrollmentWizardView(schoolId: schoolId),
    );
  }
}

class _EnrollmentWizardView extends StatefulWidget {
  final String schoolId;

  const _EnrollmentWizardView({required this.schoolId});

  @override
  State<_EnrollmentWizardView> createState() => _EnrollmentWizardViewState();
}

class _EnrollmentWizardViewState extends State<_EnrollmentWizardView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int step) {
    _pageController.animateToPage(
      step - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnrollmentWizardBloc, EnrollmentWizardState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        _onStepChanged(state.currentStep);
      },
      child: BlocBuilder<EnrollmentWizardBloc, EnrollmentWizardState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Student Enrollment'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: AppColors.primary(context).withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary(context),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                if (state.currentStep > 1 && state.currentStep < 12)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ProgressCard(
                      title: 'Step ${state.currentStep} of 12',
                      progress: state.progress,
                      subtitle: _getStepTitle(state.currentStep),
                    ),
                  ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _Step1AdmissionType(schoolId: widget.schoolId),
                      _Step2Overview(),
                      _Step3ProcessInfo(),
                      _Step4StudentBasicInfo(),
                      _Step5StudentExtraInfo(),
                      _Step6GuardianInfo(),
                      _Step7AcademicPlacement(schoolId: widget.schoolId),
                      _Step8PreviousSchool(),
                      _Step9DocumentUpload(),
                      _Step10Review(),
                      _Step11Submitting(),
                      _Step12Success(),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: state.currentStep < 11
                ? _buildNavigation(context, state)
                : null,
          );
        },
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Admission Type';
      case 2:
        return 'Enrollment Overview';
      case 3:
        return 'Requirements';
      case 4:
        return 'Student Details';
      case 5:
        return 'Additional Info';
      case 6:
        return 'Guardian Details';
      case 7:
        return 'Academic Placement';
      case 8:
        return 'Previous Education';
      case 9:
        return 'Document Upload';
      case 10:
        return 'Review Application';
      case 11:
        return 'Submitting';
      case 12:
        return 'Success';
      default:
        return '';
    }
  }

  Widget _buildNavigation(BuildContext context, EnrollmentWizardState state) {
    if (state.currentStep == 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (state.currentStep > 2)
            Expanded(
              child: SecondaryButton(
                label: 'Back',
                onPressed: () => context.read<EnrollmentWizardBloc>().add(
                  PreviousStepRequested(),
                ),
              ),
            ),
          if (state.currentStep > 2) const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              label: state.currentStep == 10
                  ? 'Submit Application'
                  : 'Continue',
              isLoading: state.status == EnrollmentWizardStatus.submitting,
              onPressed:
                  (!state.canContinue ||
                      state.status == EnrollmentWizardStatus.submitting)
                  ? null
                  : () {
                      if (state.currentStep == 10) {
                        context.read<EnrollmentWizardBloc>().add(
                          SubmitEnrollmentRequested(widget.schoolId),
                        );
                      } else {
                        context.read<EnrollmentWizardBloc>().add(
                          NextStepRequested(),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _Step1AdmissionType extends StatelessWidget {
  final String schoolId;
  const _Step1AdmissionType({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Select Admission Type',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how you want to enroll the student',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: 32),
        _TypeCard(
          title: 'New Student',
          description:
              'Fresh enrollment for a student never registered in this school.',
          icon: Icons.person_add_alt_1_rounded,
          onTap: () => context.read<EnrollmentWizardBloc>().add(
            const AdmissionTypeSelected('New Student'),
          ),
        ),
        const SizedBox(height: 16),
        _TypeCard(
          title: 'Transfer Student',
          description:
              'Student coming from another school with existing records.',
          icon: Icons.swap_horiz_rounded,
          onTap: () => context.read<EnrollmentWizardBloc>().add(
            const AdmissionTypeSelected('Transfer'),
          ),
        ),
        const SizedBox(height: 16),
        _TypeCard(
          title: 'Readmission',
          description:
              'Former student returning to the school after a period of absence.',
          icon: Icons.replay_rounded,
          onTap: () => context.read<EnrollmentWizardBloc>().add(
            const AdmissionTypeSelected('Readmission'),
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary(context), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
        ],
      ),
    );
  }
}

class _Step2Overview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.school_outlined, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          'Enrollment Process',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'You are about to start the multi-step enrollment process. Please ensure you have all required information and documents ready.',
        ),
        const SizedBox(height: 24),
        _buildBullet(context, 'Student Personal Information'),
        _buildBullet(context, 'Guardian / Parent Details'),
        _buildBullet(context, 'Academic Placement (Class/Year)'),
        _buildBullet(context, 'Supporting Documents (ID, Birth Cert)'),
      ],
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.success(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Step3ProcessInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Requirements',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please ensure you have the following documents ready for upload in the final steps.',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: 32),
        _RequirementItem(
          title: 'Birth Certificate',
          description:
              'A clear copy of the student\'s official birth certificate.',
          icon: Icons.child_care_rounded,
        ),
        const SizedBox(height: 16),
        _RequirementItem(
          title: 'Previous Report Cards',
          description:
              'Academic records from the last two terms (for transfers).',
          icon: Icons.assessment_rounded,
        ),
        const SizedBox(height: 16),
        _RequirementItem(
          title: 'Parent/Guardian ID',
          description: 'National ID or Passport of the primary guardian.',
          icon: Icons.badge_rounded,
        ),
        const SizedBox(height: 16),
        _RequirementItem(
          title: 'Passport Photos',
          description: 'Two recent passport-sized color photographs.',
          icon: Icons.add_a_photo_rounded,
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _RequirementItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary(context), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
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

class _Step4StudentBasicInfo extends StatefulWidget {
  @override
  State<_Step4StudentBasicInfo> createState() => _Step4StudentBasicInfoState();
}

class _Step4StudentBasicInfoState extends State<_Step4StudentBasicInfo> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = context
        .read<EnrollmentWizardBloc>()
        .state
        .studentName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnrollmentWizardBloc, EnrollmentWizardState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Student Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => context.read<EnrollmentWizardBloc>().add(
                StudentInfoUpdated(name: v),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                state.dateOfBirth == null
                    ? 'Select Date of Birth'
                    : 'DOB: ${DateFormat('dd MMM yyyy').format(state.dateOfBirth!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.border(context)),
                borderRadius: BorderRadius.circular(4),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(
                    const Duration(days: 365 * 10),
                  ),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  context.read<EnrollmentWizardBloc>().add(
                    StudentInfoUpdated(dateOfBirth: picked),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Gender>(
              initialValue: state.gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: Gender.values
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => context.read<EnrollmentWizardBloc>().add(
                StudentInfoUpdated(gender: v),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Step5StudentExtraInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Additional Details',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Nationality',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Residential Address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home_outlined),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Blood Group (Optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.bloodtype_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Medical Conditions / Allergies',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.medical_services_outlined),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _Step6GuardianInfo extends StatefulWidget {
  @override
  State<_Step6GuardianInfo> createState() => _Step6GuardianInfoState();
}

class _Step6GuardianInfoState extends State<_Step6GuardianInfo> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<EnrollmentWizardBloc>().state;
    _nameController.text = state.applicantParentName;
    _phoneController.text = state.applicantParentPhone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Guardian Information',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Guardian Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => context.read<EnrollmentWizardBloc>().add(
            ParentInfoUpdated(name: v),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (v) => context.read<EnrollmentWizardBloc>().add(
            ParentInfoUpdated(phone: v),
          ),
        ),
      ],
    );
  }
}

class _Step7AcademicPlacement extends StatelessWidget {
  final String schoolId;
  const _Step7AcademicPlacement({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final repo = sl<StructureRepository>();
    return BlocBuilder<EnrollmentWizardBloc, EnrollmentWizardState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Academic Placement',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Assign the student to a class and academic year.',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<SchoolClass>>(
              stream: repo.watchClasses(schoolId),
              builder: (context, snapshot) {
                final classes = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: state.targetClassId,
                  decoration: const InputDecoration(
                    labelText: 'Target Class',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.class_outlined),
                  ),
                  items: classes
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => context.read<EnrollmentWizardBloc>().add(
                    AcademicPlacementUpdated(targetClassId: v),
                  ),
                  hint: const Text('Select Class'),
                );
              },
            ),
            const SizedBox(height: 16),
            if (state.targetClassId != null)
              StreamBuilder<List<ClassStream>>(
                stream: repo.watchStreams(schoolId),
                builder: (context, snapshot) {
                  final allStreams = snapshot.data ?? [];
                  final filteredStreams = allStreams
                      .where((s) => s.classId == state.targetClassId)
                      .toList();

                  if (filteredStreams.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<String>(
                      initialValue: state.targetStreamId,
                      decoration: const InputDecoration(
                        labelText: 'Stream / Section (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.alt_route_rounded),
                      ),
                      items: filteredStreams
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => context
                          .read<EnrollmentWizardBloc>()
                          .add(AcademicPlacementUpdated(targetStreamId: v)),
                      hint: const Text('Select Stream'),
                    ),
                  );
                },
              ),
            StreamBuilder<List<AcademicYear>>(
              stream: repo.watchAcademicYears(schoolId),
              builder: (context, snapshot) {
                final years = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: state.academicYearId,
                  decoration: const InputDecoration(
                    labelText: 'Academic Year',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  items: years
                      .map(
                        (y) =>
                            DropdownMenuItem(value: y.id, child: Text(y.name)),
                      )
                      .toList(),
                  onChanged: (v) => context.read<EnrollmentWizardBloc>().add(
                    AcademicPlacementUpdated(academicYearId: v),
                  ),
                  hint: const Text('Select Year'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _Step8PreviousSchool extends StatefulWidget {
  @override
  State<_Step8PreviousSchool> createState() => _Step8PreviousSchoolState();
}

class _Step8PreviousSchoolState extends State<_Step8PreviousSchool> {
  final _schoolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _schoolController.text =
        context.read<EnrollmentWizardBloc>().state.previousSchool ?? '';
  }

  @override
  void dispose() {
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Previous Education',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _schoolController,
          decoration: const InputDecoration(
            labelText: 'Last School Attended',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.school_outlined),
          ),
          onChanged: (v) => context.read<EnrollmentWizardBloc>().add(
            AcademicPlacementUpdated(previousSchool: v),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Last Grade/Class',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Reason for Leaving',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _Step9DocumentUpload extends StatelessWidget {
  Future<void> _pickAndUpload(BuildContext context, String type) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;
    final file = File(result.files.single.path!);
    context.read<EnrollmentWizardBloc>().add(
      DocumentUploadRequested(type, file),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnrollmentWizardBloc, EnrollmentWizardState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.danger(context),
          ),
        );
      },
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Document Upload',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload the required documents to proceed.',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            _UploadTile(
              label: 'Birth Certificate',
              isUploaded: state.attachedDocuments.containsKey(
                'birth_certificate',
              ),
              isUploading: state.uploadingDocuments.contains(
                'birth_certificate',
              ),
              onTap: () => _pickAndUpload(context, 'birth_certificate'),
            ),
            const SizedBox(height: 16),
            _UploadTile(
              label: 'Previous Report Card',
              isUploaded: state.attachedDocuments.containsKey('report_card'),
              isUploading: state.uploadingDocuments.contains('report_card'),
              onTap: () => _pickAndUpload(context, 'report_card'),
            ),
            const SizedBox(height: 16),
            _UploadTile(
              label: 'Guardian ID Copy',
              isUploaded: state.attachedDocuments.containsKey('guardian_id'),
              isUploading: state.uploadingDocuments.contains('guardian_id'),
              onTap: () => _pickAndUpload(context, 'guardian_id'),
            ),
          ],
        );
      },
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final bool isUploaded;
  final bool isUploading;
  final VoidCallback onTap;

  const _UploadTile({
    required this.label,
    required this.isUploaded,
    this.isUploading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: isUploading ? null : onTap,
      borderColor: isUploaded ? AppColors.success(context) : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (isUploaded
                          ? AppColors.success(context)
                          : AppColors.primary(context))
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isUploading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary(context),
                    ),
                  )
                : Icon(
                    isUploaded
                        ? Icons.check_circle_rounded
                        : Icons.cloud_upload_outlined,
                    color: isUploaded
                        ? AppColors.success(context)
                        : AppColors.primary(context),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (isUploading)
            Text(
              'Uploading…',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            )
          else if (isUploaded)
            Text(
              'Uploaded',
              style: TextStyle(
                color: AppColors.success(context),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          else
            const Icon(Icons.add, size: 20),
        ],
      ),
    );
  }
}

class _Step10Review extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnrollmentWizardBloc, EnrollmentWizardState>(
      listenWhen: (previous, current) =>
          current.status == EnrollmentWizardStatus.failure &&
          previous.status != current.status,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'Submission failed. Please try again.',
            ),
            backgroundColor: AppColors.danger(context),
          ),
        );
      },
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Review Application',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please review the information below before submitting.',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            _ReviewSection(
              title: 'Student Details',
              children: [
                _ReviewRow(label: 'Name', value: state.studentName),
                _ReviewRow(
                  label: 'DOB',
                  value: state.dateOfBirth != null
                      ? DateFormat('dd MMM yyyy').format(state.dateOfBirth!)
                      : 'Not set',
                ),
                _ReviewRow(
                  label: 'Gender',
                  value: state.gender.name.toUpperCase(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ReviewSection(
              title: 'Guardian Details',
              children: [
                _ReviewRow(label: 'Guardian', value: state.applicantParentName),
                _ReviewRow(label: 'Phone', value: state.applicantParentPhone),
              ],
            ),
            const SizedBox(height: 16),
            _ReviewSection(
              title: 'Academic Placement',
              children: [
                _ReviewRow(label: 'Admission Type', value: state.admissionType),
                _ReviewRow(
                  label: 'Previous School',
                  value: state.previousSchool ?? 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ReviewSection(
              title: 'Documents',
              children: [
                _ReviewRow(
                  label: 'Files Attached',
                  value: '${state.attachedDocuments.length} files',
                ),
              ],
            ),
            const SizedBox(height: 24),
            AlertBanner(
              title: 'Final Confirmation',
              message:
                  'By submitting, you certify that all information provided is accurate and truthful.',
              color: AppColors.information(context),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ReviewSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primary(context),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Step11Submitting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary(context),
              ),
              backgroundColor: AppColors.primary(context).withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Submitting Application',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We are processing the enrollment request...',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}

class _Step12Success extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success(context),
                size: 80,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Application Submitted!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'The enrollment application has been submitted successfully. You can track the status in the applications list.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Go to Dashboard',
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
