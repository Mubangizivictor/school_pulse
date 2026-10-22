import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';

class Step2AdminAccountPage extends StatefulWidget {
  const Step2AdminAccountPage({super.key});

  @override
  State<Step2AdminAccountPage> createState() => _Step2AdminAccountPageState();
}

class _Step2AdminAccountPageState extends State<Step2AdminAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _password;
  late TextEditingController _confirm;
  late String _role;
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final s = context.read<RegistrationBloc>().state;
    _name = TextEditingController(text: s.adminFullName);
    _email = TextEditingController(text: s.adminEmail);
    _phone = TextEditingController(text: s.adminPhone);
    _password = TextEditingController();
    _confirm = TextEditingController();
    _role = s.adminRole.isEmpty ? 'Head Teacher' : s.adminRole;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  double _strength(String p) {
    var score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
    return score / 4;
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RegistrationBloc>().add(AdminAccountCreateRequested(
          fullName: _name.text.trim(),
          role: _role,
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          password: _password.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (a, b) => a.adminPhase != b.adminPhase || a.adminError != b.adminError || a.resendCooldownSeconds != b.resendCooldownSeconds,
      builder: (context, state) {
        final phase = state.adminPhase;
        final isBusy = phase == AdminAccountPhase.creating || phase == AdminAccountPhase.checking;
        final showForm = phase == AdminAccountPhase.form || phase == AdminAccountPhase.failed;

        return RegStepScaffold(
          step: 2,
          title: 'Administrator account',
          onBack: () => context.read<RegistrationBloc>().add(const RegistrationStepBack()),
          loading: isBusy,
          continueEnabled: phase == AdminAccountPhase.verified,
          continueLabel: showForm ? 'Create account' : 'Continue',
          onContinue: () {
            if (phase == AdminAccountPhase.verified) {
              context.read<RegistrationBloc>().add(const AdminAccountContinuePressed());
            } else if (showForm) {
              _createAccount();
            }
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: RegColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: RegColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_outline, size: 17, color: RegColors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Secure your administrator account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: RegColors.textPrimary)),
                          SizedBox(height: 3),
                          Text('This account will manage your school on School Pulse.', style: TextStyle(fontSize: 12, color: RegColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showForm) _buildForm(state) else _buildVerificationFlow(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(RegistrationState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.adminError != null) ...[
            _ErrorBanner(state.adminError!),
            const SizedBox(height: 4),
          ],
          const RegFieldLabel('Full name'),
          TextFormField(
            controller: _name,
            style: const TextStyle(color: RegColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Jane Nalubega'),
            validator: (v) => (v == null || v.trim().split(RegExp(r'\s+')).length < 2) ? 'Enter your full name' : null,
          ),
          const RegFieldLabel('Role'),
          DropdownButtonFormField<String>(
            initialValue: _role,
            items: const [
              DropdownMenuItem(value: 'Head Teacher', child: Text('Head Teacher')),
              DropdownMenuItem(value: 'Director', child: Text('Director')),
              DropdownMenuItem(value: 'Deputy Head Teacher', child: Text('Deputy Head Teacher')),
              DropdownMenuItem(value: 'Bursar', child: Text('Bursar')),
              DropdownMenuItem(value: 'Administrator', child: Text('Administrator')),
            ],
            dropdownColor: RegColors.surfaceElevated,
            style: const TextStyle(color: RegColors.textPrimary, fontSize: 14),
            onChanged: (v) => setState(() => _role = v ?? _role),
          ),
          const RegFieldLabel('Email address'),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: RegColors.textPrimary),
            decoration: const InputDecoration(hintText: 'jane.nalubega@gmail.com'),
            validator: (v) =>
                (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Enter a valid email' : null,
          ),
          const RegFieldLabel('Phone number'),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: RegColors.textPrimary),
            decoration: const InputDecoration(hintText: '+256 700 000 000'),
            validator: (v) => (v == null || v.trim().length < 7) ? 'Enter a valid phone number' : null,
          ),
          const RegFieldLabel('Password'),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            style: const TextStyle(color: RegColors.textPrimary),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Create a password',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 19, color: RegColors.textMuted),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
          ),
          if (_password.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            _PasswordStrengthBar(strength: _strength(_password.text)),
          ],
          const RegFieldLabel('Confirm password'),
          TextFormField(
            controller: _confirm,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: RegColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Re-enter password',
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 19, color: RegColors.textMuted),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) => (v != _password.text) ? 'Passwords do not match' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationFlow(BuildContext context, RegistrationState state) {
    final phase = state.adminPhase;
    if (phase == AdminAccountPhase.verified) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RegColors.greenSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: RegColors.green.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: RegColors.green, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Email verified — ${state.adminEmail}',
                  style: const TextStyle(color: RegColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5)),
            ),
          ],
        ),
      );
    }

    final waiting = phase == AdminAccountPhase.verificationSent ||
        phase == AdminAccountPhase.waitingVerification ||
        phase == AdminAccountPhase.checking;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RegColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RegColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                phase == AdminAccountPhase.expired ? Icons.error_outline : Icons.mark_email_unread_outlined,
                color: phase == AdminAccountPhase.expired ? RegColors.red : RegColors.amber,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  phase == AdminAccountPhase.expired
                      ? 'Verification link expired'
                      : 'Verify your email',
                  style: const TextStyle(color: RegColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'We sent a verification link to ${state.adminEmail}. Open it, then tap "I\'ve verified my email" below.',
            style: const TextStyle(color: RegColors.textMuted, fontSize: 12.5, height: 1.4),
          ),
          if (state.adminError != null) ...[
            const SizedBox(height: 10),
            _ErrorBanner(state.adminError!),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: waiting
                  ? null
                  : () => context.read<RegistrationBloc>().add(const AdminVerificationCheckRequested()),
              child: phase == AdminAccountPhase.checking
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("I've verified my email"),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: state.resendCooldownSeconds > 0
                  ? null
                  : () => context.read<RegistrationBloc>().add(const AdminVerificationResendRequested()),
              child: Text(
                state.resendCooldownSeconds > 0
                    ? 'Resend email in ${state.resendCooldownSeconds}s'
                    : 'Resend verification email',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final double strength;
  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final color = strength >= 0.75
        ? RegColors.green
        : (strength >= 0.5 ? RegColors.amber : RegColors.red);
    final label = strength >= 0.75 ? 'Strong password' : (strength >= 0.5 ? 'Medium password' : 'Weak password');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: strength, minHeight: 4, backgroundColor: RegColors.border, valueColor: AlwaysStoppedAnimation(color)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: RegColors.redSoft,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: RegColors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: RegColors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: RegColors.textPrimary, height: 1.35))),
        ],
      ),
    );
  }
}
