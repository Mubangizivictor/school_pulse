import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/alert.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';

import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: StudentAppBar(title: 'Notifications'),
      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, studentsState) {
          if (studentsState is! StudentsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, notificationsState) {
              if (notificationsState is NotificationsInitial) {
                final ids = studentsState.students.map((s) => s.id).toList();
                final groups = {
                  'Parents',
                  ...studentsState.students.map((s) => 'Class:${s.className}'),
                }.toList();
                context.read<NotificationsBloc>().add(
                  FetchAlerts(ids, groups: groups),
                );
              }

              if (notificationsState is NotificationsLoading ||
                  notificationsState is NotificationsInitial) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Skeleton(height: 80),
                  ),
                );
              }

              if (notificationsState is NotificationsError) {
                return EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Could not load notifications',
                  message: notificationsState.message,
                  ctaLabel: 'Retry',
                  onCtaPressed: () {
                    final ids = studentsState.students
                        .map((s) => s.id)
                        .toList();
                    final groups = {
                      'Parents',
                      ...studentsState.students.map(
                        (s) => 'Class:${s.className}',
                      ),
                    }.toList();
                    context.read<NotificationsBloc>().add(
                      FetchAlerts(ids, groups: groups),
                    );
                  },
                );
              }

              final alerts = (notificationsState as NotificationsLoaded).alerts;

              if (alerts.isEmpty) {
                return const FadeInSlide(
                  child: EmptyState(
                    icon: Icons.notifications_none,
                    title: 'No new notifications',
                    message:
                        'We\'ll notify you when there\'s something important.',
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Dismissible(
                    key: Key(alert.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<NotificationsBloc>().add(
                          DismissAlert(alert.id, authState.user.id),
                        );
                      }
                    },
                    child: FadeInSlide(
                      delay: Duration(milliseconds: index * 100),
                      child: AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getAlertColor(
                                  alert.severity,
                                  semanticColors,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getAlertIcon(alert.severity),
                                color: _getAlertColor(
                                  alert.severity,
                                  semanticColors,
                                ),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          alert.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormatter.relative(alert.timestamp),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.message,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getAlertColor(AlertSeverity severity, SemanticColors colors) {
    switch (severity) {
      case AlertSeverity.error:
        return colors.error;
      case AlertSeverity.warning:
        return colors.warning;
      case AlertSeverity.success:
        return colors.success;
      case AlertSeverity.info:
        return colors.info;
    }
  }

  IconData _getAlertIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.error:
        return Icons.error_outline;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.success:
        return Icons.check_circle_outline;
      case AlertSeverity.info:
        return Icons.info_outline;
    }
  }
}
