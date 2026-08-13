import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/document_template_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

class DocumentTemplatesScreen extends StatelessWidget {
  const DocumentTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: 'Document Templates'),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final bloc = context.read<StructureBloc>();
          final schoolId = (context.read<AuthBloc>().state as AuthAuthenticated)
              .user
              .schoolId;
          return state.documentTemplates.isEmpty
              ? const StructureEmptyHint(
                  'No document templates defined yet.\ne.g. Student ID Card, Report Card, Certificate.',
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.l),
                  itemCount: state.documentTemplates.length,
                  itemBuilder: (context, index) {
                    final template = state.documentTemplates[index];
                    return StructureListRow(
                      icon: Icons.description_outlined,
                      color: Colors.indigo,
                      title: template.name,
                      subtitle: template.templateType,
                      isActive: template.isActive,
                      badge: StructureStatusBadge(
                        label: 'Active',
                        isActive: template.isActive,
                      ),
                      onEdit: () => showDocumentTemplateFormDialog(
                        context,
                        existing: template,
                        schoolId: schoolId,
                        onSave: (u) =>
                            bloc.add(SaveDocumentTemplateRequested(u)),
                      ),
                      onDelete: () async {
                        final confirmed = await showDeleteConfirmDialog(
                          context,
                          title: 'Delete Template',
                          message: 'Delete "${template.name}"?',
                        );
                        if (confirmed == true) {
                          bloc.add(
                            DeleteDocumentTemplateRequested(template.id),
                          );
                        }
                      },
                    );
                  },
                );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final bloc = context.read<StructureBloc>();
          final schoolId = (context.read<AuthBloc>().state as AuthAuthenticated)
              .user
              .schoolId;
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary(context),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => showDocumentTemplateFormDialog(
              context,
              schoolId: schoolId,
              onSave: (t) => bloc.add(SaveDocumentTemplateRequested(t)),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Template'),
          );
        },
      ),
    );
  }
}
