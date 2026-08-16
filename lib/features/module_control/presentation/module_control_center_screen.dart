import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import '../data/module_control_repository.dart';
import '../domain/module_dependency_resolver.dart';
import '../domain/module_registry.dart';

class ModuleControlCenterScreen extends StatelessWidget {
  const ModuleControlCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to manage institution modules.')),
      );
    }
    final repository = ModuleControlRepository();
    return Scaffold(
      appBar: const AdminAppBar(title: 'Module Control Center'),
      body: StreamBuilder<Map<String, ModuleConfiguration>>(
        stream: repository.watchModules(auth.user.schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load modules: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final configurations = snapshot.data!;
          final enabled = configurations.values
              .where((item) => item.enabled)
              .map((item) => item.moduleKey)
              .toSet();
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                '${enabled.length} enabled modules',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...ModuleRegistry.all.map((module) {
                final config =
                    configurations[module.key] ??
                    ModuleConfiguration(moduleKey: module.key);
                final missing = const ModuleDependencyResolver().missing(
                  module,
                  enabled,
                );
                final status = !config.entitled
                    ? 'Add-on required'
                    : missing.isNotEmpty
                    ? 'Dependency missing: ${missing.map((item) => item.name).join(', ')}'
                    : config.enabled
                    ? 'Enabled'
                    : 'Disabled';
                return Card(
                  child: ListTile(
                    leading: Icon(module.icon),
                    title: Text(module.name),
                    subtitle: Text(
                      '${module.description}\n$status${config.updatedBy == null ? '' : '\nLast changed by ${config.updatedBy}'}',
                    ),
                    isThreeLine: true,
                    trailing: Switch(
                      value: config.enabled,
                      onChanged:
                          !auth.user.roles.any(
                                (role) => const {
                                  'schoolAdmin',
                                  'director',
                                  'headTeacher',
                                  'deputyHead',
                                }.contains(role.name),
                              ) ||
                              !config.entitled ||
                              (!config.enabled && missing.isNotEmpty)
                          ? null
                          : (value) => _confirmModuleChange(
                              context: context,
                              repository: repository,
                              schoolId: auth.user.schoolId,
                              actorId: auth.user.id,
                              module: module,
                              enabled: value,
                            ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _confirmModuleChange({
  required BuildContext context,
  required ModuleControlRepository repository,
  required String schoolId,
  required String actorId,
  required ModuleDefinition module,
  required bool enabled,
}) async {
  final reasonController = TextEditingController();
  final reason = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('${enabled ? 'Enable' : 'Disable'} ${module.name}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            enabled
                ? 'This changes local availability; permissions still control access.'
                : 'Existing records are retained and may remain read-only.',
          ),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: 'Reason (required)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final reason = reasonController.text.trim();
            if (reason.isNotEmpty) Navigator.pop(dialogContext, reason);
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
  if (reason == null) return;
  await repository.setModuleEnabled(
    schoolId: schoolId,
    moduleKey: module.key,
    enabled: enabled,
    actorId: actorId,
    reason: reason,
  );
}
