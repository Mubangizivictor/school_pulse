import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';

Future<void> handleSuperAdminLogout(BuildContext context) async {
  final confirmed = await confirmActionDialog(
    context,
    title: 'Logout',
    message: 'Are you sure you want to log out?',
    confirmLabel: 'Logout',
    isDestructive: true,
  );
  if (confirmed == true && context.mounted) {
    context.read<AuthBloc>().add(LogoutPressed());
    context.go('/welcome');
  }
}

class SuperAdminLogoutButton extends StatelessWidget {
  const SuperAdminLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: 'Logout',
      onPressed: () => handleSuperAdminLogout(context),
    );
  }
}
