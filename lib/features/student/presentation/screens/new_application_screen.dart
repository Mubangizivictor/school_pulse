import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student_enums.dart';
import '../bloc/admission_bloc.dart';
import '../bloc/admission_event.dart';
import '../bloc/admission_state.dart';

class NewApplicationScreen extends StatelessWidget {
  final String schoolId;
  const NewApplicationScreen({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdmissionBloc>(),
      child: _NewApplicationView(schoolId: schoolId),
    );
  }
}

class _NewApplicationView extends StatefulWidget {
  final String schoolId;
  const _NewApplicationView({required this.schoolId});

  @override
  State<_NewApplicationView> createState() => _NewApplicationViewState();
}

class _NewApplicationViewState extends State<_NewApplicationView> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _previousSchoolController = TextEditingController();
  final _structureRepository = sl<StructureRepository>();

  DateTime? _dateOfBirth;
  Gender _gender = Gender.male;
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

  @override
  void dispose() {
    _classesSub?.cancel();
    _yearsSub?.cancel();
    _studentNameController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _previousSchoolController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 6),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid ||
        _dateOfBirth == null ||
        _selectedClass == null ||
        _selectedYear == null) {
      if (_dateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date of birth')),
        );
      } else if (_selectedClass == null || _selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a class and academic year'),
          ),
        );
      }
      return;
    }
    setState(() => _busy = true);
    final application = AdmissionApplication(
      id: const Uuid().v4(),
      schoolId: widget.schoolId,
      studentName: _studentNameController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      gender: _gender,
      targetClassId: _selectedClass!.id,
      academicYearId: _selectedYear!.id,
      previousSchool: _previousSchoolController.text.trim().isEmpty
          ? null
          : _previousSchoolController.text.trim(),
      applicantParentName: _parentNameController.text.trim(),
      applicantParentPhone: _parentPhoneController.text.trim(),
      status: AdmissionStatus.application,
      appliedAt: DateTime.now(),
    );
    context.read<AdmissionBloc>().add(CheckDuplicatesRequested(application));
  }

  Future<void> _confirmDuplicates(
    BuildContext context,
    DuplicatesFound state,
  ) async {
    if (!context.mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Possible Duplicate'),
        content: Text(
          'A student named "${state.pendingApplication.studentName}" with the same date '
          'of birth already has ${state.candidates.length == 1 ? "an application" : "applications"} '
          'on record. Submit anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit Anyway'),
          ),
        ],
      ),
    );
    if (proceed == true && context.mounted) {
      context.read<AdmissionBloc>().add(
        SubmitApplicationRequested(state.pendingApplication),
      );
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdmissionBloc, AdmissionState>(
      listener: (context, state) async {
        if (state is DuplicatesFound) {
          await _confirmDuplicates(context, state);
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
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('New Application')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _studentNameController,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Student full name',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primary(context),
                      width: 2,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dateOfBirth == null
                      ? 'Select date of birth'
                      : 'Date of birth: ${DateFormat('dd MMM yyyy').format(_dateOfBirth!)}',
                  style: TextStyle(
                    color: _dateOfBirth == null
                        ? AppColors.textSecondary(context)
                        : AppColors.textPrimary(context),
                  ),
                ),
                trailing: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary(context),
                ),
                onTap: _pickDateOfBirth,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                value: _gender,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                items: Gender.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v ?? _gender),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SchoolClass>(
                value: _selectedClass,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Target class',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                items: _classes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedClass = v),
                validator: (v) => v == null ? 'Required' : null,
                hint: Text(
                  _classes.isEmpty ? 'Loading classes…' : 'Select class',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AcademicYear>(
                value: _selectedYear,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Academic year',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                items: _academicYears
                    .map((y) => DropdownMenuItem(value: y, child: Text(y.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedYear = v),
                validator: (v) => v == null ? 'Required' : null,
                hint: Text(
                  _academicYears.isEmpty
                      ? 'Loading academic years…'
                      : 'Select year',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _previousSchoolController,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Previous school (optional)',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: AppColors.border(context)),
              const SizedBox(height: 8),
              Text(
                'Parent / Guardian',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _parentNameController,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Parent / guardian name',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _parentPhoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Parent / guardian phone',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
