import 'package:flutter/material.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/onboarding_step_scaffold.dart';

String _classificationLabel(InstitutionClassification c) {
  switch (c) {
    case InstitutionClassification.kindergarten:
      return 'Kindergarten';
    case InstitutionClassification.primary:
      return 'Primary Institution';
    case InstitutionClassification.secondary:
      return 'Secondary Institution';
    case InstitutionClassification.combined:
      return 'Combined School';
    case InstitutionClassification.vocational:
      return 'Vocational Institution';
    case InstitutionClassification.technicalInstitute:
      return 'Technical Institute';
    case InstitutionClassification.college:
      return 'College';
    case InstitutionClassification.university:
      return 'University';
    case InstitutionClassification.specialNeeds:
      return 'Special-needs Institution';
    case InstitutionClassification.trainingCentre:
      return 'Training Centre';
    case InstitutionClassification.multiCampus:
      return 'Multi-purpose Education Institution';
    case InstitutionClassification.other:
      return 'Other';
  }
}

class InstitutionConfirmScreen extends StatelessWidget {
  final InstitutionContext context;
  final VoidCallback onConfirmed;

  const InstitutionConfirmScreen({super.key, required this.context, required this.onConfirmed});

  @override
  Widget build(BuildContext buildContext) {
    final divisionNames = context.divisions.isEmpty
        ? 'None configured yet'
        : context.divisions.map((d) => d.name).join(', ');

    return OnboardingStepScaffold(
      title: 'Confirm Your Institution',
      subtitle: 'This is the institution you are being onboarded as an administrator for.',
      primaryLabel: 'This is my institution',
      onPrimaryPressed: onConfirmed,
      child: Column(
        children: [
          OnboardingSummaryRow(label: 'Institution', value: context.displayLabel),
          OnboardingSummaryRow(label: 'Type', value: _classificationLabel(context.classification)),
          OnboardingSummaryRow(label: 'Divisions', value: divisionNames),
        ],
      ),
    );
  }
}
