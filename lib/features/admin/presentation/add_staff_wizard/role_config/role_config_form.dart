import 'package:flutter/material.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

import '../models/role_assignment_draft.dart';
import 'role_assignment_config_registry.dart';

/// Renders whichever fields RoleAssignmentConfigSpec lists for a role. One
/// generic widget for every role instead of a file per role.
class RoleConfigForm extends StatefulWidget {
  final RoleAssignmentDraft draft;
  final RoleAssignmentConfigSpec spec;
  final List<String> classNames;
  final List<String> subjectNames;
  final String? academicYearId;
  final VoidCallback onChanged;

  const RoleConfigForm({
    super.key,
    required this.draft,
    required this.spec,
    required this.classNames,
    required this.subjectNames,
    required this.academicYearId,
    required this.onChanged,
  });

  @override
  State<RoleConfigForm> createState() => _RoleConfigFormState();
}

class _RoleConfigFormState extends State<RoleConfigForm> {
  final _departmentController = TextEditingController();
  final _facilityController = TextEditingController();
  final _routeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _departmentController.text = widget.draft.departmentId ?? '';
    _facilityController.text = widget.draft.facilityId ?? '';
    _routeController.text = widget.draft.routeId ?? '';
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _facilityController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spec.isEmpty) {
      return Text(
        '${UserRoleDisplay.name(widget.spec.role)} needs no additional configuration.',
        style: TextStyle(color: AppColors.textMuted(context)),
      );
    }

    widget.draft.academicYearId ??= widget.academicYearId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.spec.fields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildField(field),
        );
      }).toList(),
    );
  }

  Widget _buildField(RoleFieldKind kind) {
    switch (kind) {
      case RoleFieldKind.academicYearAndClass:
        return _classAndStreamPicker();
      case RoleFieldKind.subjectClassList:
        return _subjectAssignmentsList();
      case RoleFieldKind.department:
        return TextField(
          controller: _departmentController,
          decoration: const InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.apartment_outlined),
          ),
          onChanged: (v) {
            widget.draft.departmentId = v.trim().isEmpty ? null : v.trim();
            widget.onChanged();
          },
        );
      case RoleFieldKind.dormitoryWing:
        final wing = UserRoleDisplay.matronGenderScope(widget.spec.role);
        widget.draft.dormitoryWing ??= wing;
        return InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Dormitory Wing',
            prefixIcon: Icon(Icons.night_shelter_outlined),
          ),
          child: Text(wing ?? 'Unassigned'),
        );
      case RoleFieldKind.route:
        return TextField(
          controller: _routeController,
          decoration: const InputDecoration(
            labelText: 'Transport Route',
            prefixIcon: Icon(Icons.directions_bus_outlined),
          ),
          onChanged: (v) {
            widget.draft.routeId = v.trim().isEmpty ? null : v.trim();
            widget.onChanged();
          },
        );
      case RoleFieldKind.facility:
        return TextField(
          controller: _facilityController,
          decoration: const InputDecoration(
            labelText: 'Facility / Area',
            prefixIcon: Icon(Icons.room_outlined),
          ),
          onChanged: (v) {
            widget.draft.facilityId = v.trim().isEmpty ? null : v.trim();
            widget.onChanged();
          },
        );
      case RoleFieldKind.approvalScope:
        const scopes = ['School-wide', 'Class-level', 'Department-level'];
        widget.draft.approvalScope ??= scopes.first;
        return DropdownButtonFormField<String>(
          initialValue: widget.draft.approvalScope,
          decoration: const InputDecoration(
            labelText: 'Approval Scope',
            prefixIcon: Icon(Icons.verified_outlined),
          ),
          items: scopes
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            widget.draft.approvalScope = v;
            widget.onChanged();
          },
        );
    }
  }

  Widget _classAndStreamPicker() {
    if (widget.classNames.isEmpty) {
      return Text(
        'No classes registered yet. Add classes in School Structure first.',
        style: TextStyle(fontSize: 12, color: AppColors.danger(context)),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: widget.classNames.contains(widget.draft.className)
          ? widget.draft.className
          : null,
      decoration: const InputDecoration(
        labelText: 'Class *',
        prefixIcon: Icon(Icons.meeting_room_outlined),
      ),
      items: widget.classNames
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) {
        widget.draft.className = v;
        widget.onChanged();
      },
    );
  }

  Widget _subjectAssignmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Assignments',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.draft.subjectAssignments.map(
          (assignment) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${assignment.subjectName} (${assignment.className})',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.danger(context),
                  ),
                  onPressed: () {
                    widget.draft.subjectAssignments.remove(assignment);
                    widget.onChanged();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
        TextButton.icon(
          onPressed: (widget.subjectNames.isEmpty || widget.classNames.isEmpty)
              ? null
              : _showAddSubjectDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Subject & Class'),
        ),
      ],
    );
  }

  Future<void> _showAddSubjectDialog() async {
    String selectedSub = widget.subjectNames.first;
    String selectedCls = widget.classNames.first;
    final result = await showDialog<SubjectAssignment>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Subject & Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedSub,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: widget.subjectNames
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedSub = v ?? selectedSub),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCls,
                decoration: const InputDecoration(labelText: 'Class'),
                items: widget.classNames
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedCls = v ?? selectedCls),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                SubjectAssignment(
                  subjectName: selectedSub,
                  className: selectedCls,
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      widget.draft.subjectAssignments.add(result);
      widget.onChanged();
      setState(() {});
    }
  }
}
