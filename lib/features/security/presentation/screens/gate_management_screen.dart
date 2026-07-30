import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../data/models/security_models.dart';
import '../../domain/entities/security_entities.dart';
import '../../domain/entities/verification_method.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

class GateManagementScreen extends StatefulWidget {
  const GateManagementScreen({super.key});

  @override
  State<GateManagementScreen> createState() => _GateManagementScreenState();
}

class _GateManagementScreenState extends State<GateManagementScreen> {
  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<SecurityBloc>().add(WatchGatesRequested(_schoolId));
  }

  void _openGateForm({Gate? existing}) async {
    final staffResult = await di.sl<GetStaffMembers>()(NoParams());
    final staff = staffResult.fold(
      (failure) => <UserEntity>[],
      (members) => members.where((m) => m.schoolId == _schoolId).toList(),
    );
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: _GateFormSheet(
          existing: existing,
          schoolId: _schoolId,
          staff: staff,
          onSubmit: (gate) {
            if (existing == null) {
              context.read<SecurityBloc>().add(CreateGateRequested(gate));
            } else {
              context.read<SecurityBloc>().add(UpdateGateRequested(gate));
            }
            Navigator.pop(sheetContext);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gate Management')),
      body: BlocConsumer<SecurityBloc, SecurityState>(
        listenWhen: (previous, current) => !identical(previous.feedback, current.feedback) && current.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(feedback.message), backgroundColor: feedback.isError ? Colors.red : null),
          );
        },
        builder: (context, state) {
          if (state.gates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No gates configured yet. Tap + to add your first gate.', textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.gates.length,
            itemBuilder: (context, index) {
              final gate = state.gates[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.door_front_door_outlined)),
                  title: Text(gate.name),
                  subtitle: Text('${gate.type} • ${gate.location}\n'
                      '${gate.requiredVerificationMethods.map((id) => VerificationMethod.fromId(id)?.label ?? id).join(', ')}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _openGateForm(existing: gate),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openGateForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GateFormSheet extends StatefulWidget {
  final Gate? existing;
  final String schoolId;
  final List<UserEntity> staff;
  final void Function(Gate gate) onSubmit;

  const _GateFormSheet({
    required this.existing,
    required this.schoolId,
    required this.staff,
    required this.onSubmit,
  });

  @override
  State<_GateFormSheet> createState() => _GateFormSheetState();
}

class _GateFormSheetState extends State<_GateFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late String _type;
  late Set<String> _assignedOfficerIds;
  late Set<UserRole> _allowedRoles;
  late Set<VerificationMethod> _requiredMethods;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _locationController = TextEditingController(text: existing?.location ?? '');
    _type = existing?.type ?? kGateTypes.first;
    _assignedOfficerIds = {...(existing?.assignedOfficerIds ?? [])};
    _allowedRoles = {
      for (final id in (existing?.allowedUserRoles ?? []))
        ...UserRole.values.where((r) => r.name == id),
    };
    _requiredMethods = {
      for (final id in (existing?.requiredVerificationMethods ?? []))
        if (VerificationMethod.fromId(id) != null) VerificationMethod.fromId(id)!,
    };
    _openTime = _parseTime(existing?.operatingHours['open'] as String?) ?? const TimeOfDay(hour: 6, minute: 0);
    _closeTime = _parseTime(existing?.operatingHours['close'] as String?) ?? const TimeOfDay(hour: 18, minute: 0);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || !value.contains(':')) return null;
    final parts = value.split(':');
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }

  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  void _submit() {
    if (_nameController.text.trim().isEmpty || _locationController.text.trim().isEmpty) return;
    final gate = GateModel(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      type: _type,
      location: _locationController.text.trim(),
      assignedOfficerIds: _assignedOfficerIds.toList(),
      operatingHours: {'open': _formatTime(_openTime), 'close': _formatTime(_closeTime)},
      allowedUserRoles: _allowedRoles.map((r) => r.name).toList(),
      requiredVerificationMethods: _requiredMethods.map((m) => m.id).toList(),
      schoolId: widget.schoolId,
    );
    widget.onSubmit(gate);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            Text(
              widget.existing == null ? 'Add Gate' : 'Edit Gate',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Gate Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Gate Type', border: OutlineInputBorder()),
              items: kGateTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Text('Operating Hours', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _openTime);
                      if (picked != null) setState(() => _openTime = picked);
                    },
                    child: Text('Opens ${_formatTime(_openTime)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _closeTime);
                      if (picked != null) setState(() => _closeTime = picked);
                    },
                    child: Text('Closes ${_formatTime(_closeTime)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Required Verification Methods', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VerificationMethod.values.map((method) {
                final selected = _requiredMethods.contains(method);
                return FilterChip(
                  label: Text(method.label),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _requiredMethods.add(method);
                    } else {
                      _requiredMethods.remove(method);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Allowed User Roles', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserRole.values.map((role) {
                final selected = _allowedRoles.contains(role);
                return FilterChip(
                  label: Text(UserRoleDisplay.name(role)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _allowedRoles.add(role);
                    } else {
                      _allowedRoles.remove(role);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Assigned Security Officers', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (widget.staff.isEmpty)
              const Text('No staff found for this school.', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.staff.map((member) {
                  final selected = _assignedOfficerIds.contains(member.id);
                  return FilterChip(
                    label: Text(member.name),
                    selected: selected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _assignedOfficerIds.add(member.id);
                      } else {
                        _assignedOfficerIds.remove(member.id);
                      }
                    }),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.existing == null ? 'Create Gate' : 'Save Changes'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
