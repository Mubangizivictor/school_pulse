import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';

class RegistrationWelcomePage extends StatelessWidget {
  const RegistrationWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegColors.background,
      appBar: const RegTopBar(),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              const RegStepDots(currentStep: 0, totalSteps: 6),
              const SizedBox(height: 6),
              const Text(
                'Register your public school',
                style: TextStyle(fontSize: 15, color: RegColors.textMuted),
              ),
              const Spacer(),
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: RegColors.blue, width: 2),
                ),
                child: const Icon(Icons.shield_outlined, color: RegColors.blue, size: 60),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to School Pulse',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: RegColors.textPrimary),
              ),
              const SizedBox(height: 10),
              const Text(
                "The trusted platform for Uganda's public schools to register, manage, and grow with confidence.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: RegColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 26),
              const _BulletRow(icon: Icons.shield_outlined, text: 'Secure & compliant'),
              const SizedBox(height: 12),
              const _BulletRow(icon: Icons.groups_outlined, text: 'Built for public schools'),
              const SizedBox(height: 12),
              const _BulletRow(icon: Icons.lock_outline, text: 'Your data is always protected'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.read<RegistrationBloc>().add(const RegistrationStarted()),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Start registration'),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 17),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: RegColors.textMuted, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Text('Sign in', style: TextStyle(color: RegColors.blue, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BulletRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RegColors.blue),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 13.5, color: RegColors.textPrimary)),
      ],
    );
  }
}
