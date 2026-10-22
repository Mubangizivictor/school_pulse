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
import '../widgets/custom_field_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

class CustomFieldsScreen extends StatelessWidget {
  const CustomFieldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: 'Custom Fields'),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final bloc = context.read<StructureBloc>();
          final schoolId = (context.read<AuthBloc>().state as AuthAuthenticated)
              .user
              .schoolId;
          return state.customFields.isEmpty
              ? const StructureEmptyHint(
                  'No custom fields defined yet.\ne.g. Blood Group, Religion, Passport Number.',
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.l),
                  itemCount: state.customFields.length,
                  itemBuilder: (context, index) {
                    final field = state.customFields[index];
                    return StructureListRow(
                      icon: Icons.dynamic_form_outlined,
                      color: Colors.black,
                      title: field.fieldName,
                      subtitle:
                          '${field.appliesTo} - ${field.fieldType}${field.isRequired ? ' - Required' : ''}',
                      isActive: field.isActive,
                      badge: StructureStatusBadge(
                        label: 'Active',
                        isActive: field.isActive,
                      ),
                      onEdit: () => showCustomFieldFormDialog(
                        context,
                        existing: field,
                        schoolId: schoolId,
                        onSave: (u) => bloc.add(SaveCustomFieldRequested(u)),
                      ),
                      onDelete: () async {
                        final confirmed = await showDeleteConfirmDialog(
                          context,
                          title: 'Delete Field',
                          message: 'Delete "${field.fieldName}"?',
                        );
                        if (confirmed == true) {
                          bloc.add(DeleteCustomFieldRequested(field.id));
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
            onPressed: () => showCustomFieldFormDialog(
              context,
              schoolId: schoolId,
              onSave: (f) => bloc.add(SaveCustomFieldRequested(f)),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Field'),
          );
        },
      ),
    );
  }
}
