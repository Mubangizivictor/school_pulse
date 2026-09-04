import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/registration_reference_data.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';

class Step6ReviewPage extends StatelessWidget {
  const Step6ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistrationBloc, RegistrationState>(
      listenWhen: (a, b) => a.submitPhase != b.submitPhase,
      listener: (context, state) {},
      builder: (context, state) {
        final tier = tierForCount(state.studentCount);
        final submitting = state.submitPhase == SubmitPhase.submitting;
        return RegStepScaffold(
          step: 6,
          title: 'Review & submit',
          onBack: submitting ? null : () => context.read<RegistrationBloc>().add(const RegistrationStepBack()),
          loading: submitting,
          continueLabel: 'Submit registration',
          continueEnabled: state.termsAccepted,
          onContinue: () => context.read<RegistrationBloc>().add(const RegistrationSubmitPressed()),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Please review your details before submission.', style: TextStyle(color: RegColors.textMuted, fontSize: 12.5)),
              const SizedBox(height: 14),
              _ReviewCard(icon: Icons.school_outlined, title: 'School information', lines: [
                state.schoolName,
                '${state.schoolType} · ${state.district}',
              ]),
              _ReviewCard(icon: Icons.person_outline, title: 'Administrator', lines: [
                state.adminFullName,
                '${state.adminPhone} · ${state.adminEmail}',
              ]),
              _ReviewCard(icon: Icons.badge_outlined, title: 'Academic details', lines: [
                '${state.schoolYear} · ${state.term}',
              ]),
              _ReviewCard(icon: Icons.groups_outlined, title: 'Students & plan', lines: [
                '${tier.label} plan',
                '${state.studentCount} students · ${formatUgx(tier.price)} per term',
              ]),
              if (state.submitError != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RegColors.redSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RegColors.red.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, size: 17, color: RegColors.red),
                      const SizedBox(width: 10),
                      Expanded(child: Text(state.submitError!, style: const TextStyle(color: RegColors.textPrimary, fontSize: 12.5))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: state.termsAccepted,
                    activeColor: RegColors.blue,
                    onChanged: submitting ? null : (v) => context.read<RegistrationBloc>().add(TermsToggled(v ?? false)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'By submitting, you confirm that all information is true and accurate.',
                        style: const TextStyle(color: RegColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;
  const _ReviewCard({required this.icon, required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RegColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: RegColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: RegColors.surfaceElevated, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 17, color: RegColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: RegColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                for (final l in lines)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(l, style: const TextStyle(color: RegColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
