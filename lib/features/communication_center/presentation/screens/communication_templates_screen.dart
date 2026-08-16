import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_template.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_bloc.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_event.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class CommunicationTemplatesScreen extends StatelessWidget {
  const CommunicationTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    return BlocProvider(
      create: (_) => di.sl<CommunicationBloc>()
        ..add(
          WatchCommunicationTemplatesRequested(schoolId: auth.user.schoolId),
        ),
      child: const _TemplatesView(),
    );
  }
}

class _TemplatesView extends StatelessWidget {
  const _TemplatesView();

  Future<void> _editTemplate(
    BuildContext context, {
    CommunicationTemplate? existing,
  }) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final nameController = TextEditingController(text: existing?.name);
    final bodyController = TextEditingController(text: existing?.body);
    var type = existing?.communicationType ?? CommunicationType.custom;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'New template' : 'Edit template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Template name'),
                ),
                DropdownButtonFormField<CommunicationType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: CommunicationType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                      )
                      .toList(),
                  onChanged: (t) => setState(() => type = t ?? type),
                ),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Body'),
                  maxLines: 6,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !context.mounted) return;
    if (nameController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty) {
      return;
    }
    context.read<CommunicationBloc>().add(
      SaveCommunicationTemplateRequested(
        schoolId: auth.user.schoolId,
        template: CommunicationTemplate(
          templateId: existing?.templateId ?? '',
          schoolId: auth.user.schoolId,
          name: nameController.text.trim(),
          communicationType: type,
          body: bodyController.text.trim(),
        ),
        templateId: existing?.templateId,
        operatorUser: auth.user,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Communication templates'),
      body: BlocConsumer<CommunicationBloc, CommunicationState>(
        listener: (context, state) {
          if (state is CommunicationActionDenied ||
              state is CommunicationError) {
            final message = state is CommunicationActionDenied
                ? state.message
                : (state as CommunicationError).message;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) {
          if (state is! CommunicationLoaded) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state.templates.isEmpty) {
            return const EmptyState(
              icon: Icons.description_outlined,
              title: 'No templates yet',
              message:
                  'Save reusable wording for fee reminders, closures, and more.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.templates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final template = state.templates[index];
              return Card(
                child: ListTile(
                  title: Text(template.name),
                  subtitle: Text(template.communicationType.label),
                  onTap: () => context.push(
                    '/staff/admin/communication-center/compose?templateId=${template.templateId}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            _editTemplate(context, existing: template),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          final auth = context.read<AuthBloc>().state;
                          if (auth is AuthAuthenticated) {
                            context.read<CommunicationBloc>().add(
                              DeleteCommunicationTemplateRequested(
                                schoolId: auth.user.schoolId,
                                templateId: template.templateId,
                                operatorUser: auth.user,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editTemplate(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
