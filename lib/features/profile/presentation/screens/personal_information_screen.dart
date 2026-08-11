import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _InfoTile(label: 'Full Name', value: user.name),
                _InfoTile(label: 'Email', value: user.email),
                _InfoTile(
                  label: 'Phone Number',
                  value: user.phoneNumber?.isNotEmpty == true
                      ? user.phoneNumber!
                      : 'Not set',
                ),
                _InfoTile(
                  label: 'Role',
                  value: UserRoleDisplay.name(user.role),
                ),
                if (user.staffCode != null)
                  _InfoTile(label: 'Staff Code', value: user.staffCode!),
                if (user.schoolName != null)
                  _InfoTile(label: 'School', value: user.schoolName!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            label,
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Divider(
          height: 1,
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
