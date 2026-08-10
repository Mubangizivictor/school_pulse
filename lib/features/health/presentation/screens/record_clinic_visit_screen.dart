import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/medical_inventory.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:uuid/uuid.dart';

class RecordClinicVisitScreen extends StatefulWidget {
  final String studentId;

  const RecordClinicVisitScreen({super.key, required this.studentId});

  @override
  State<RecordClinicVisitScreen> createState() =>
      _RecordClinicVisitScreenState();
}

class _RecordClinicVisitScreenState extends State<RecordClinicVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _tempController = TextEditingController();
  final _bpController = TextEditingController();
  final _pulseController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _weightController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();

  VisitOutcome _outcome = VisitOutcome.sentBackToClass;
  bool _followUp = false;
  final List<AdministeredMedication> _medications = [];

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomsController.dispose();
    _tempController.dispose();
    _bpController.dispose();
    _pulseController.dispose();
    _spo2Controller.dispose();
    _weightController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final visit = ClinicVisit(
      id: const Uuid().v4(),
      studentId: widget.studentId,
      dateTime: DateTime.now(),
      reason: _reasonController.text,
      symptoms: _symptomsController.text,
      temperature: double.tryParse(_tempController.text),
      bloodPressure: _bpController.text.isEmpty ? null : _bpController.text,
      pulseRate: int.tryParse(_pulseController.text),
      oxygenSaturation: int.tryParse(_spo2Controller.text),
      weight: double.tryParse(_weightController.text),
      diagnosis: _diagnosisController.text.isEmpty
          ? null
          : _diagnosisController.text,
      treatmentProvided: _treatmentController.text.isEmpty
          ? null
          : _treatmentController.text,
      medicationsGiven: _medications,
      outcome: _outcome,
      followUpRequired: _followUp,
      recordedBy: authState.user.id,
      schoolId: authState.user.schoolId,
    );

    context.read<HealthBloc>().add(RecordNewClinicVisit(visit));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';

    return BlocListener<HealthBloc, HealthState>(
      listener: (context, state) {
        if (state is HealthActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.pop();
        } else if (state is HealthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.deepOrange,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070914),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'New Clinic Visit',
            style: AppTypography.titleLarge.copyWith(color: Colors.white),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle('Reason & Symptoms'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _reasonController,
                label: 'Reason for Visit',
                hint: 'e.g., Headache, Fever, Injury',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _symptomsController,
                label: 'Observed Symptoms',
                hint: 'Detailed description of symptoms',
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Vitals'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _tempController,
                      label: 'Temp (°C)',
                      hint: '36.5',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final temp = double.tryParse(v);
                        if (temp == null) return 'Invalid number';
                        if (temp < 30 || temp > 45)
                          return 'Out of range (30-45)';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _bpController,
                      label: 'Blood Pressure',
                      hint: '120/80',
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final regExp = RegExp(r'^\d{2,3}/\d{2,3}$');
                        if (!regExp.hasMatch(v)) return 'Use format SYS/DIA';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _pulseController,
                      label: 'Pulse (bpm)',
                      hint: '72',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final pulse = int.tryParse(v);
                        if (pulse == null) return 'Invalid';
                        if (pulse < 30 || pulse > 250) return '30-250';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _spo2Controller,
                      label: 'SpO2 (%)',
                      hint: '98',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final spo2 = int.tryParse(v);
                        if (spo2 == null) return 'Invalid';
                        if (spo2 < 50 || spo2 > 100) return '50-100';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      hint: '45.0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Diagnosis & Treatment'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _diagnosisController,
                label: 'Diagnosis',
                hint: 'Preliminary diagnosis',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _treatmentController,
                label: 'Treatment Provided',
                hint: 'Action taken or first aid',
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Medication Administered'),
              const SizedBox(height: 12),
              _MedicationAdministeredSection(
                medications: _medications,
                schoolId: schoolId,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Outcome'),
              const SizedBox(height: 12),
              _buildDropdown(),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Follow-up Required',
                  style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                ),
                value: _followUp,
                onChanged: (v) => setState(() => _followUp = v),
                activeThumbColor: AppColors.deepOrange,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Record',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleSmall.copyWith(
        color: const Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        hintStyle: const TextStyle(color: Color(0xFF334155)),
        filled: true,
        fillColor: const Color(0xFF151929),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E293B)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E293B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.deepOrange.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<VisitOutcome>(
          value: _outcome,
          dropdownColor: const Color(0xFF151929),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => setState(() => _outcome = v!),
          items: VisitOutcome.values.map((outcome) {
            return DropdownMenuItem(
              value: outcome,
              child: Text(outcome.name.splitCamelCase()),
            );
          }).toList(),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String splitCamelCase() {
    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match m) => '${m[1]} ${m[2]}',
    ).capitalize();
  }

  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class _MedicationAdministeredSection extends StatelessWidget {
  final List<AdministeredMedication> medications;
  final String schoolId;
  final VoidCallback onChanged;

  const _MedicationAdministeredSection({
    required this.medications,
    required this.schoolId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (medications.isNotEmpty)
          ...medications.asMap().entries.map((entry) {
            final index = entry.key;
            final med = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF151929),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.medicationName,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${med.dosage} (${med.quantity} unit)',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      medications.removeAt(index);
                      onChanged();
                    },
                  ),
                ],
              ),
            );
          }),
        OutlinedButton.icon(
          onPressed: () => _showAddMedicationDialog(context),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Medication'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.deepOrange,
            side: const BorderSide(color: AppColors.deepOrange),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddMedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AddMedicationDialog(
        schoolId: schoolId,
        onAdd: (med) {
          medications.add(med);
          onChanged();
        },
      ),
    );
  }
}

class _AddMedicationDialog extends StatefulWidget {
  final String schoolId;
  final Function(AdministeredMedication) onAdd;

  const _AddMedicationDialog({required this.schoolId, required this.onAdd});

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _dosageController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  MedicalInventoryItem? _selectedItem;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<HealthBloc>().add(FetchInventory(widget.schoolId));
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final nurseName = authState is AuthAuthenticated ? authState.user.name : '';

    return Dialog(
      backgroundColor: const Color(0xFF151929),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Administer Medication',
                style: AppTypography.titleLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 20),
              BlocBuilder<HealthBloc, HealthState>(
                builder: (context, state) {
                  if (state is HealthLoading) {
                    return const Center(child: SchoolPulseLoader());
                  }
                  if (state is InventoryLoaded) {
                    final meds = state.items
                        .where((i) => i.type == MedicalItemType.medication)
                        .toList();
                    return DropdownButtonFormField<MedicalInventoryItem>(
                      initialValue: _selectedItem,
                      dropdownColor: const Color(0xFF151929),
                      decoration: const InputDecoration(
                        labelText: 'Select Medication',
                        labelStyle: TextStyle(color: Color(0xFF64748B)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: meds.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            '${item.name} (${item.quantity} ${item.unit} left)',
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedItem = v),
                      validator: (v) => v == null ? 'Required' : null,
                    );
                  }
                  return const Text('Failed to load inventory');
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 2 tablets, 5ml',
                  labelStyle: TextStyle(color: Color(0xFF64748B)),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to decrement',
                  hintText: '1',
                  labelStyle: TextStyle(color: Color(0xFF64748B)),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Invalid quantity';
                  if (_selectedItem != null && n > _selectedItem!.quantity) {
                    return 'Insufficient stock';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      widget.onAdd(
                        AdministeredMedication(
                          medicationId: _selectedItem!.id,
                          medicationName: _selectedItem!.name,
                          dosage: _dosageController.text,
                          quantity: int.parse(_quantityController.text),
                          timeAdministered: DateTime.now(),
                          administeredBy: nurseName,
                          notes: _notesController.text,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.deepOrange,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
