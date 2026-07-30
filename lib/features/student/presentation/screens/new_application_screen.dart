import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/injection_container.dart';
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
  final _classIdController = TextEditingController();
  final _academicYearIdController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _previousSchoolController = TextEditingController();
  DateTime? _dateOfBirth;
  Gender _gender = Gender.male;
  bool _busy = false;

  @override
  void dispose() {
    _studentNameController.dispose();
    _classIdController.dispose();
    _academicYearIdController.dispose();
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
    if (!formValid || _dateOfBirth == null) {
      if (_dateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date of birth')),
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
      targetClassId: _classIdController.text.trim(),
      academicYearId: _academicYearIdController.text.trim(),
      previousSchool:
          _previousSchoolController.text.trim().isEmpty ? null : _previousSchoolController.text.trim(),
      applicantParentName: _parentNameController.text.trim(),
      applicantParentPhone: _parentPhoneController.text.trim(),
      status: AdmissionStatus.application,
      appliedAt: DateTime.now(),
    );
    context.read<AdmissionBloc>().add(SubmitApplicationRequested(application));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdmissionBloc, AdmissionState>(
      listener: (context, state) {
        if (state is AdmissionActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.of(context).pop(true);
        } else if (state is AdmissionError) {
          setState(() => _busy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                decoration: const InputDecoration(labelText: 'Student full name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_dateOfBirth == null
                    ? 'Select date of birth'
                    : 'Date of birth: ${_dateOfBirth!.toLocal().toString().split(' ').first}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickDateOfBirth,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: Gender.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                onChanged: (v) => setState(() => _gender = v ?? _gender),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _classIdController,
                decoration: const InputDecoration(
                  labelText: 'Target class ID',
                  helperText: 'Temporary free-text entry until a class picker is wired in',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _academicYearIdController,
                decoration: const InputDecoration(
                  labelText: 'Academic year ID',
                  helperText: 'Temporary free-text entry until an academic-year picker is wired in',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _previousSchoolController,
                decoration:
                    const InputDecoration(labelText: 'Previous school (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              Text('Parent / Guardian', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _parentNameController,
                decoration:
                    const InputDecoration(labelText: 'Parent / guardian name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _parentPhoneController,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Parent / guardian phone', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
