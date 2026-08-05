import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _saving = false;

  Future<void> _toggle(bool value) async {
    setState(() => _saving = true);
    final result = await sl<AuthRepository>().updateMfaEnabled(value);
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final enabled = authState is AuthAuthenticated
        ? authState.user.mfaEnabled
        : false;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: SwitchListTile.adaptive(
              value: enabled,
              onChanged: _saving ? null : _toggle,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Enable Two-Factor Authentication',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
              subtitle: Text(
                'Add an extra layer of security to your account.',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const EmptyState(
            icon: Icons.qr_code_2_outlined,
            title: 'Additional methods coming soon',
            message:
                'Authenticator app and SMS-based verification methods are '
                'on the way.',
          ),
        ],
      ),
    );
  }
}
