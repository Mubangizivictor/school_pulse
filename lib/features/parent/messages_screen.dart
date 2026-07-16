import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

/// In-app messaging is not built yet. This screen says so honestly instead of
/// showing mock conversations, and points users at the channels that do work
/// (notifications and the school office).
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isStaff = authState is AuthAuthenticated &&
        authState.user.role != UserRole.parent;

    return Scaffold(
      appBar: isStaff
          ? AppBar(title: const Text('Messages'))
          : const StudentAppBar(title: 'Messages'),
      body: EmptyState(
        icon: Icons.forum_outlined,
        title: 'Messaging Coming Soon',
        message:
            'Direct in-app messaging is under development. For now, please '
            'contact the school office for urgent matters, and check '
            'notifications for school announcements.',
        ctaLabel: 'View Notifications',
        onCtaPressed: () => context.push(
          isStaff ? '/staff/notifications' : '/parent/notifications',
        ),
      ),
    );
  }
}
