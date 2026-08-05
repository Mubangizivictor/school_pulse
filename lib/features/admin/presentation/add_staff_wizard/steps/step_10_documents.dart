import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';
import '../models/add_staff_draft.dart';

class Step10Documents extends StatelessWidget {
  const Step10Documents({super.key});

  Future<void> _pickForType(
    BuildContext context,
    AddStaffWizardController controller,
    StaffDocumentType type,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;
    final file = result.files.single;
    controller.draft.documents.removeWhere((d) => d.type == type);
    controller.draft.documents.add(
      StagedDocument(type: type, file: File(file.path!), fileName: file.name),
    );
    controller.notifyDraftChanged();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.documents),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        onNext: () => controller.next(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStepCaption(
            number: 10,
            title: 'Documents (Optional)',
            subtitle: 'Upload supporting documents',
          ),
          const SizedBox(height: 16),
          ...StaffDocumentType.values.map((type) {
            final staged = draft.documents
                .where((d) => d.type == type)
                .toList();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => _pickForType(context, controller, type),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.label,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            staged.isEmpty
                                ? 'Upload document'
                                : staged.first.fileName,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      staged.isEmpty
                          ? Icons.upload_outlined
                          : Icons.check_circle,
                      color: staged.isEmpty
                          ? AppColors.textMuted(context)
                          : AppColors.success(context),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
