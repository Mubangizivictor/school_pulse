import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/registration_reference_data.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';

class Step4StudentsPricingPage extends StatefulWidget {
  const Step4StudentsPricingPage({super.key});

  @override
  State<Step4StudentsPricingPage> createState() =>
      _Step4StudentsPricingPageState();
}

class _Step4StudentsPricingPageState extends State<Step4StudentsPricingPage> {
  late TextEditingController _count;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = context.read<RegistrationBloc>().state;
    _count = TextEditingController(
      text: s.studentCount > 0 ? '${s.studentCount}' : '',
    );
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  int get _n => int.tryParse(_count.text) ?? 0;

  void _continue() {
    if (_n < 1) {
      setState(() => _error = 'Enter the total number of students');
      return;
    }
    final tier = tierForCount(_n);
    if (tier.plan == null) {
      setState(
        () => _error =
            'For more than 1,500 students or multiple campuses, please contact '
            'us for an Enterprise quote',
      );
      return;
    }
    context.read<RegistrationBloc>().add(StudentCountSubmitted(_n));
  }

  @override
  Widget build(BuildContext context) {
    final tier = tierForCount(_n);
    final yearly = yearlyPrice(tier);
    return RegStepScaffold(
      step: 4,
      title: 'Student count & pricing',
      onBack: () =>
          context.read<RegistrationBloc>().add(const RegistrationStepBack()),
      onContinue: _continue,
      infoBanner: const RegInfoBanner(
        'Start with a free $kTrialDays-day trial of every Pro feature, no '
        'payment needed. After the trial, pick a plan or the account becomes '
        'read-only. Your data is never deleted.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RegFieldLabel('Total student count'),
          TextField(
            controller: _count,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: RegColors.textPrimary),
            onChanged: (_) => setState(() => _error = null),
            decoration: const InputDecoration(
              hintText: '565',
              suffixIcon: Icon(
                Icons.groups_outlined,
                color: RegColors.textMuted,
                size: 19,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Enter the total number of students enrolled for the selected term.',
              style: TextStyle(fontSize: 11.5, color: RegColors.textMuted),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: RegColors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 18),
          if (_n > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RegColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RegColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pricing summary',
                    style: TextStyle(
                      color: RegColors.textMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${tier.label} plan · $_n students',
                    style: const TextStyle(
                      color: RegColors.textPrimary,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tier.price == null ? 'Custom quote' : formatUgx(tier.price),
                    style: const TextStyle(
                      color: RegColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    yearly == null
                        ? "We'll tailor a plan with you"
                        : 'Per term · or ${formatUgx(yearly)} per year (about 10% off)',
                    style: const TextStyle(
                      color: RegColors.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in tier.includes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check,
                            size: 15,
                            color: RegColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: RegColors.textPrimary,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
