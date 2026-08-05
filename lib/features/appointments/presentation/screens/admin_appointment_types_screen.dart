import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/appointment_type.dart';
import '../bloc/appointment_settings_bloc.dart';
import '../bloc/appointment_settings_event.dart';
import '../bloc/appointment_settings_state.dart';

class AdminAppointmentTypesScreen extends StatelessWidget {
  const AdminAppointmentTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';

    return BlocProvider(
      create: (_) =>
          di.sl<AppointmentSettingsBloc>()
            ..add(WatchAppointmentTypesEvent(schoolId)),
      child: _AdminAppointmentTypesView(schoolId: schoolId),
    );
  }
}

class _AdminAppointmentTypesView extends StatelessWidget {
  final String schoolId;
  const _AdminAppointmentTypesView({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Appointment Types'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Type',
            onPressed: () => _showEditDialog(context, schoolId: schoolId),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<AppointmentSettingsBloc, AppointmentSettingsState>(
          listener: (context, state) {
            if (state is AppointmentSettingsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is! AppointmentSettingsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.types.isEmpty) {
              return EmptyState(
                icon: Icons.event_note_outlined,
                title: 'No appointment types yet',
                message:
                    'Add categories like "Parent ↔ Class Teacher" or "Parent ↔ Bursar" so '
                    'parents and staff can start booking meetings.',
                ctaLabel: 'New Type',
                onCtaPressed: () =>
                    _showEditDialog(context, schoolId: schoolId),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.types.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final type = state.types[index];
                return AppCard(
                  onTap: () => _showEditDialog(
                    context,
                    schoolId: schoolId,
                    existing: type,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${type.department} • ${type.defaultDurationMinutes} min'
                              '${type.requiresApproval ? '' : ' • Auto-approved'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!type.active)
                        const StatusBadge(label: 'Inactive', color: Colors.grey)
                      else
                        StatusBadge(
                          label: type.category.name,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          final confirmed = await confirmActionDialog(
                            context,
                            title: 'Delete Type?',
                            message:
                                'Remove "${type.name}"? Existing appointments of this type are unaffected.',
                            isDestructive: true,
                          );
                          if (confirmed == true && context.mounted) {
                            context.read<AppointmentSettingsBloc>().add(
                              DeleteAppointmentTypeEvent(type.id),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String schoolId,
    AppointmentType? existing,
  }) {
    final bloc = context.read<AppointmentSettingsBloc>();
    final nameController = TextEditingController(text: existing?.name);
    final departmentController = TextEditingController(
      text: existing?.department,
    );
    int duration = existing?.defaultDurationMinutes ?? 20;
    var category = existing?.category ?? AppointmentCategory.parentStaff;
    var requiresApproval = existing?.requiresApproval ?? true;
    var active = existing?.active ?? true;
    final targetRoles = <UserRole>{...(existing?.targetRoles ?? const [])};

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            existing == null ? 'New Appointment Type' : 'Edit Appointment Type',
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name (e.g. Parent ↔ Bursar)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department / Office',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AppointmentCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: AppointmentCategory.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(_categoryLabel(c)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => category = v ?? category),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: duration,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    items: const [15, 20, 30, 45, 60]
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text('$m minutes'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => duration = v ?? duration),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Requires staff approval'),
                    value: requiresApproval,
                    onChanged: (v) =>
                        setDialogState(() => requiresApproval = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: active,
                    onChanged: (v) => setDialogState(() => active = v),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Eligible staff roles (leave empty for any staff)',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      shrinkWrap: true,
                      children: UserRole.values
                          .where(
                            (r) =>
                                r != UserRole.parent && r != UserRole.student,
                          )
                          .map(
                            (r) => CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(UserRoleDisplay.name(r)),
                              value: targetRoles.contains(r),
                              onChanged: (checked) => setDialogState(() {
                                if (checked == true) {
                                  targetRoles.add(r);
                                } else {
                                  targetRoles.remove(r);
                                }
                              }),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    departmentController.text.trim().isEmpty)
                  return;
                bloc.add(
                  SaveAppointmentTypeEvent(
                    AppointmentType(
                      id:
                          existing?.id ??
                          DateTime.now().microsecondsSinceEpoch.toString(),
                      schoolId: schoolId,
                      name: nameController.text.trim(),
                      department: departmentController.text.trim(),
                      category: category,
                      defaultDurationMinutes: duration,
                      requiresApproval: requiresApproval,
                      active: active,
                      targetRoles: targetRoles.toList(),
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: Text(existing == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(AppointmentCategory c) {
    switch (c) {
      case AppointmentCategory.parentStaff:
        return 'Parent ↔ Staff';
      case AppointmentCategory.internalStaff:
        return 'Staff ↔ Staff';
      case AppointmentCategory.external:
        return 'External';
    }
  }
}
