import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Admin screen for issuing and managing parent access codes for already
/// enrolled students. The admission-approval flow creates a code
/// automatically when a new student is enrolled; this screen is for every
/// other case (a code was never issued, was lost, or needs deactivating).
class AccessCodesScreen extends StatefulWidget {
  const AccessCodesScreen({super.key});

  @override
  State<AccessCodesScreen> createState() => _AccessCodesScreenState();
}

class _AccessCodesScreenState extends State<AccessCodesScreen> {
  bool _isLoading = true;
  List<ParentAccessCode> _codes = [];
  String _searchQuery = '';

  String get _schoolId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await di.sl<GetAllAccessCodes>()(schoolId: _schoolId);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        _showError('Could not load access codes: ${failure.message}');
      },
      (codes) => setState(() {
        _codes = codes;
        _isLoading = false;
      }),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger(context),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleActive(ParentAccessCode code) async {
    final result = await di.sl<ToggleAccessCodeStatus>()(
      code.code,
      !code.isActive,
    );
    if (!mounted) return;
    result.fold(
      (failure) => _showError('Could not update: ${failure.message}'),
      (_) {
        _showSuccess(
          code.isActive ? 'Access code deactivated' : 'Access code reactivated',
        );
        _load();
      },
    );
  }

  Future<void> _delete(ParentAccessCode code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete access code?'),
        content: Text(
          'This permanently removes ${code.code} for ${code.parentName ?? 'this parent'}. They will no longer be able to sign in with it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await di.sl<DeleteAccessCode>()(code.code);
    if (!mounted) return;
    result.fold(
      (failure) => _showError('Could not delete: ${failure.message}'),
      (_) {
        _showSuccess('Access code deleted');
        _load();
      },
    );
  }

  Future<void> _openCreateDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _CreateAccessCodeDialog(schoolId: _schoolId),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _codes.where((c) {
      final q = _searchQuery.toLowerCase();
      if (q.isEmpty) return true;
      return c.code.toLowerCase().contains(q) ||
          (c.parentName ?? '').toLowerCase().contains(q) ||
          (c.phoneNumber ?? '').toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AdminAppBar(
        title: 'Access Codes',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Issue new access code',
            onPressed: _openCreateDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: SchoolPulseLoader())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by code, parent name, or phone...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceContainer(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _buildCodeCard(filtered[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDialog,
        icon: const Icon(Icons.vpn_key_outlined),
        label: const Text('Issue Code'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.vpn_key_outlined,
              size: 48,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 12),
            Text(
              _codes.isEmpty
                  ? 'No access codes yet'
                  : 'No codes match your search',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Issue a code so a parent can sign in to the Parent Portal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeCard(ParentAccessCode code) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      code.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(isActive: code.isActive),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  code.parentName ?? 'Unnamed parent',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (code.phoneNumber != null)
                  Text(
                    code.phoneNumber!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${code.studentIds.length} ${code.studentIds.length == 1 ? 'child' : 'children'}'
                  '${code.studentNames.isNotEmpty ? ': ${code.studentNames.join(', ')}' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle') _toggleActive(code);
              if (value == 'delete') _delete(code);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(code.isActive ? 'Deactivate' : 'Reactivate'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.danger(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.success(context)
        : AppColors.danger(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _CreateAccessCodeDialog extends StatefulWidget {
  final String schoolId;
  const _CreateAccessCodeDialog({required this.schoolId});

  @override
  State<_CreateAccessCodeDialog> createState() =>
      _CreateAccessCodeDialogState();
}

class _CreateAccessCodeDialogState extends State<_CreateAccessCodeDialog> {
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoadingStudents = true;
  bool _isSaving = false;
  List<Student> _students = [];
  final Set<String> _selectedStudentIds = {};
  String _studentQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _parentNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final result = await di.sl<GetAllStudents>()(schoolId: widget.schoolId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _isLoadingStudents = false),
      (students) => setState(() {
        _students = students;
        _isLoadingStudents = false;
      }),
    );
  }

  Future<void> _submit() async {
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one student.')),
      );
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the parent\'s phone number.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final result = await di.sl<CreateAccessCode>()(
      studentIds: _selectedStudentIds.toList(),
      schoolId: widget.schoolId,
      phoneNumber: _phoneController.text.trim(),
      parentName: _parentNameController.text.trim().isEmpty
          ? null
          : _parentNameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not issue code: ${failure.message}'),
          backgroundColor: AppColors.danger(context),
        ),
      ),
      (code) {
        Navigator.pop(context, true);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Access code issued'),
            content: SelectableText(
              'Share this code with the parent along with their phone number:\n\n$code',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _students
        .where(
          (s) => s.name.toLowerCase().contains(_studentQuery.toLowerCase()),
        )
        .toList();

    return AlertDialog(
      title: const Text('Issue Access Code'),
      content: SizedBox(
        width: 420,
        height: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _parentNameController,
              decoration: const InputDecoration(
                labelText: 'Parent name (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Parent phone number',
                hintText: '+256700000000',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Children (${_selectedStudentIds.length} selected)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => setState(() => _studentQuery = v),
              decoration: InputDecoration(
                hintText: 'Search students...',
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoadingStudents
                  ? const Center(child: SchoolPulseLoader())
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final selected = _selectedStudentIds.contains(
                          student.id,
                        );
                        return CheckboxListTile(
                          dense: true,
                          title: Text(student.name),
                          subtitle: Text(student.studentCode),
                          value: selected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedStudentIds.add(student.id);
                              } else {
                                _selectedStudentIds.remove(student.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Issue Code'),
        ),
      ],
    );
  }
}
