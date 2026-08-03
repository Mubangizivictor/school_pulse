import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';

const _kAccent = Color(0xFF6366F1);
const _kSurface = Color(0xFF1E293B);
const _kBackground = Color(0xFF0F172A);

String _classificationLabel(InstitutionClassification c) {
  switch (c) {
    case InstitutionClassification.kindergarten:
      return 'Kindergarten';
    case InstitutionClassification.primary:
      return 'Primary Institution';
    case InstitutionClassification.secondary:
      return 'Secondary Institution';
    case InstitutionClassification.combined:
      return 'Combined School';
    case InstitutionClassification.vocational:
      return 'Vocational Institution';
    case InstitutionClassification.technicalInstitute:
      return 'Technical Institute';
    case InstitutionClassification.college:
      return 'College';
    case InstitutionClassification.university:
      return 'University';
    case InstitutionClassification.specialNeeds:
      return 'Special-needs Institution';
    case InstitutionClassification.trainingCentre:
      return 'Training Centre';
    case InstitutionClassification.multiCampus:
      return 'Multi-purpose Education Institution';
    case InstitutionClassification.other:
      return 'Other';
  }
}

class CreateSchoolDialog extends StatefulWidget {
  const CreateSchoolDialog({super.key});

  @override
  State<CreateSchoolDialog> createState() => _CreateSchoolDialogState();
}

class _CreateSchoolDialogState extends State<CreateSchoolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tenantIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _displayLabelController = TextEditingController();
  final _classificationOtherController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _tempPasswordController = TextEditingController();

  String _selectedPlanId = 'starter';
  int _currentStep = 1;
  InstitutionClassification _classification = InstitutionClassification.primary;
  final List<_DivisionDraft> _divisions = [];

  @override
  void dispose() {
    _nameController.dispose();
    _tenantIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _displayLabelController.dispose();
    _classificationOtherController.dispose();
    _adminEmailController.dispose();
    _tempPasswordController.dispose();
    for (final d in _divisions) {
      d.nameController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 560,
        decoration: BoxDecoration(
          color: _kBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepIndicator(),
                      const SizedBox(height: 32),
                      if (_currentStep == 1)
                        _buildStep1()
                      else if (_currentStep == 2)
                        _buildStep2()
                      else
                        _buildStep3(),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add New Institution',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(1, 'Basic Info', _currentStep >= 1),
        Expanded(child: Container(height: 2, color: _currentStep >= 2 ? _kAccent : Colors.white.withValues(alpha: 0.1))),
        _buildStepCircle(2, 'Classification', _currentStep >= 2),
        Expanded(child: Container(height: 2, color: _currentStep >= 3 ? _kAccent : Colors.white.withValues(alpha: 0.1))),
        _buildStepCircle(3, 'Admin & Plan', _currentStep >= 3),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, bool active) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? _kAccent : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: active ? _kAccent : Colors.white.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(color: active ? Colors.white : Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Institution Name', _nameController, hint: 'e.g. Greenfield Academy'),
        const SizedBox(height: 20),
        _buildTextField(
          'Display Label (optional)',
          _displayLabelController,
          hint: 'e.g. Academy, Institute, University',
          required: false,
        ),
        const SizedBox(height: 20),
        _buildTextField('Tenant ID', _tenantIdController, hint: 'e.g. GREENFIELD'),
        const SizedBox(height: 20),
        _buildTextField('Physical Address', _addressController, hint: 'e.g. Kampala, Uganda'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField('Contact Email', _emailController, hint: 'info@school.com')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Contact Phone', _phoneController, hint: '+256...')),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Institution Classification', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Descriptive only - suggests defaults, never restricts features.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
        ),
        const SizedBox(height: 12),
        _buildClassificationDropdown(),
        if (_classification == InstitutionClassification.other) ...[
          const SizedBox(height: 20),
          _buildTextField('Describe this institution type', _classificationOtherController, hint: 'e.g. Adult Learning Centre'),
        ],
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Education Divisions', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _addDivision,
              icon: const Icon(Icons.add, size: 16, color: _kAccent),
              label: const Text('Add Division', style: TextStyle(color: _kAccent, fontSize: 12)),
            ),
          ],
        ),
        Text(
          'A single institution may contain one or many divisions (e.g. Kindergarten + Primary, or Undergraduate + Postgraduate).',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
        ),
        const SizedBox(height: 12),
        if (_divisions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              'No divisions added yet. Add at least one before continuing.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            ),
          )
        else
          ..._divisions.asMap().entries.map((entry) => _buildDivisionRow(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildDivisionRow(int index, _DivisionDraft draft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: draft.nameController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Division name (e.g. Kindergarten)',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<InstitutionClassification>(
                value: draft.levelHint,
                dropdownColor: _kSurface,
                isExpanded: true,
                isDense: true,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.5), size: 18),
                items: InstitutionClassification.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(_classificationLabel(c), overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => draft.levelHint = v!),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              draft.nameController.dispose();
              _divisions.removeAt(index);
            }),
            icon: const Icon(Icons.close, color: Colors.white38, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _addDivision() {
    setState(() => _divisions.add(_DivisionDraft()));
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Primary Institution Administrator', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField('Admin Email', _adminEmailController, hint: 'admin@school.com'),
        const SizedBox(height: 20),
        _buildTextField('Temporary Password', _tempPasswordController, hint: '••••••••', obscureText: true),
        const SizedBox(height: 32),
        const Text('Subscription Plan', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPlanDropdown(),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool obscureText = false,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
            validator: required ? (v) => v?.isEmpty ?? true ? 'Required' : null : null,
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<InstitutionClassification>(
          value: _classification,
          dropdownColor: _kSurface,
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.5)),
          items: InstitutionClassification.values
              .map((c) => DropdownMenuItem(value: c, child: Text(_classificationLabel(c), style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: (v) => setState(() => _classification = v!),
        ),
      ),
    );
  }

  Widget _buildPlanDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPlanId,
          dropdownColor: _kSurface,
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.5)),
          items: const [
            DropdownMenuItem(value: 'starter', child: Text('Starter (Yearly)', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'pro', child: Text('Professional (Termly)', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'enterprise', child: Text('Enterprise (Yearly)', style: TextStyle(fontSize: 13))),
          ],
          onChanged: (v) => setState(() => _selectedPlanId = v!),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              if (_currentStep == 1) {
                Navigator.pop(context);
              } else {
                setState(() => _currentStep -= 1);
              }
            },
            child: Text(
              _currentStep == 1 ? 'Cancel' : 'Back',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _handlePrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_currentStep == 3 ? 'Create Institution' : 'Next Step', style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _handlePrimaryAction() {
    if (_currentStep == 1) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 2);
      }
      return;
    }
    if (_currentStep == 2) {
      if (_divisions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one education division to continue.')),
        );
        return;
      }
      if (_classification == InstitutionClassification.other &&
          _classificationOtherController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Describe the institution type for "Other".')),
        );
        return;
      }
      setState(() => _currentStep = 3);
      return;
    }
    _submit();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final divisions = _divisions
          .where((d) => d.nameController.text.trim().isNotEmpty)
          .map((d) => InstitutionDivision(
                id: const Uuid().v4(),
                name: d.nameController.text.trim(),
                levelHint: d.levelHint,
              ))
          .toList();

      final school = School(
        id: const Uuid().v4(),
        name: _nameController.text,
        tenantId: _tenantIdController.text.toUpperCase(),
        address: _addressController.text,
        contactEmail: _emailController.text,
        contactPhone: _phoneController.text,
        status: SchoolStatus.active,
        subscriptionPlanId: _selectedPlanId,
        createdAt: DateTime.now(),
        subscriptionExpiry: DateTime.now().add(const Duration(days: 365)),
        enabledFeatures: const ['attendance', 'finance', 'exams'],
        classification: _classification,
        classificationOther: _classification == InstitutionClassification.other
            ? _classificationOtherController.text.trim()
            : null,
        divisions: divisions,
        displayLabel: _displayLabelController.text.trim().isEmpty
            ? null
            : _displayLabelController.text.trim(),
      );

      context.read<SuperAdminBloc>().add(
        CreateSchoolEvent(
          school: school,
          adminEmail: _adminEmailController.text,
          adminPassword: _tempPasswordController.text,
        ),
      );

      Navigator.pop(context);
    }
  }
}

class _DivisionDraft {
  final TextEditingController nameController = TextEditingController();
  InstitutionClassification levelHint = InstitutionClassification.other;
}
