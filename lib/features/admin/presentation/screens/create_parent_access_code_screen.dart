import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Admin-facing "create parent" form. Issues a `parent_access_codes` code
/// tied to a phone number and one or more learners. The parent later signs
/// in with code + that exact phone number and is forced to set their own
/// 4-digit PIN on first login (see ParentPinScreen's `isFirstTime` branch) -
/// there is no SMS/OTP step anywhere in this flow.
class CreateParentAccessCodeScreen extends StatefulWidget {
  const CreateParentAccessCodeScreen({super.key});

  @override
  State<CreateParentAccessCodeScreen> createState() =>
      _CreateParentAccessCodeScreenState();
}

class _CreateParentAccessCodeScreenState
    extends State<CreateParentAccessCodeScreen> {
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentQueryController = TextEditingController();

  String _countryCode = '+256';
  final List<Student> _selectedStudents = [];
  bool _loadingStudents = true;
  List<Student> _students = [];
  String _studentQuery = '';
  bool _submitting = false;
  bool _submitted = false;
  String? _resultCode;

  String get _schoolId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.schoolId : '';
  }

  bool get _isNameValid => _parentNameController.text.trim().isNotEmpty;
  String get _e164Phone {
    final digits = _phoneController.text
        .replaceAll(RegExp(r'\D'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    return '$_countryCode$digits';
  }

  bool get _isPhoneValid => RegExp(r'^\+\d{8,15}$').hasMatch(_e164Phone);
  bool get _canSubmit =>
      _isNameValid && _isPhoneValid && _selectedStudents.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final result = await di.sl<GetAllStudents>()(schoolId: _schoolId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _loadingStudents = false),
      (students) => setState(() {
        _students = students;
        _loadingStudents = false;
      }),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    final result = await di.sl<CreateAccessCode>()(
      studentIds: _selectedStudents.map((s) => s.id).toList(),
      schoolId: _schoolId,
      phoneNumber: _e164Phone,
      parentName: _parentNameController.text.trim(),
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not create the access code: ${failure.message}'),
            backgroundColor: AppColors.danger(context),
          ),
        );
      },
      (code) => setState(() {
        _submitting = false;
        _resultCode = code;
      }),
    );
  }

  @override
  void dispose() {
    _parentNameController.dispose();
    _phoneController.dispose();
    _studentQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AdminAppBar(title: 'Create parent access code'),
      body: _resultCode != null ? _buildResult(context) : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final filtered = _students
        .where(
          (s) =>
              s.name.toLowerCase().contains(_studentQuery.toLowerCase()) ||
              s.studentCode.toLowerCase().contains(_studentQuery.toLowerCase()),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Parent details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _parentNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Parent or guardian name',
            errorText: _submitted && !_isNameValid ? 'Enter a name' : null,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CountryCodePicker(
              value: _countryCode,
              onChanged: (code) => setState(() => _countryCode = code),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '772 123 456',
                  errorText: _submitted && !_isPhoneValid
                      ? 'Enter a valid phone number'
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.textMuted(context)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This must be the exact number the parent will sign in with. '
                  'They will set their own PIN on first login - no SMS is sent.',
                  style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Linked learners (${_selectedStudents.length})',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedStudents.isEmpty && _submitted)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Select at least one learner.',
              style: TextStyle(color: AppColors.danger(context), fontSize: 12),
            ),
          ),
        ..._selectedStudents.map(
          (student) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        student.studentCode,
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: AppColors.textMuted(context)),
                  onPressed: () => setState(() => _selectedStudents.remove(student)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _studentQueryController,
          onChanged: (v) => setState(() => _studentQuery = v),
          decoration: const InputDecoration(
            hintText: 'Search students to add...',
            prefixIcon: Icon(Icons.search, size: 18),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _loadingStudents
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    final selected = _selectedStudents.any((s) => s.id == student.id);
                    return CheckboxListTile(
                      dense: true,
                      title: Text(student.name),
                      subtitle: Text(student.studentCode),
                      value: selected,
                      onChanged: (val) => setState(() {
                        if (val == true) {
                          _selectedStudents.add(student);
                        } else {
                          _selectedStudents.removeWhere((s) => s.id == student.id);
                        }
                      }),
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),
        PulseButton(
          label: 'Generate access code',
          isLoading: _submitting,
          isFullWidth: true,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 48, color: AppColors.textPrimary(context)),
            const SizedBox(height: 16),
            Text(
              'Access code created',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _resultCode!,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 1,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Give this code to ${_parentNameController.text.trim()}. They sign in '
              'with this code and the phone number $_e164Phone, then set their own PIN.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            PulseButton(
              label: 'Done',
              isFullWidth: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryCodePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CountryCodePicker({required this.value, required this.onChanged});

  static const _codes = [
    {'flag': '🇺🇬', 'code': '+256', 'name': 'Uganda'},
    {'flag': '🇰🇪', 'code': '+254', 'name': 'Kenya'},
    {'flag': '🇹🇿', 'code': '+255', 'name': 'Tanzania'},
    {'flag': '🇷🇼', 'code': '+250', 'name': 'Rwanda'},
    {'flag': '🇳🇬', 'code': '+234', 'name': 'Nigeria'},
    {'flag': '🇬🇭', 'code': '+233', 'name': 'Ghana'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: _codes
              .map(
                (c) => DropdownMenuItem(
                  value: c['code'],
                  child: Text('${c['flag']} ${c['code']}'),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
