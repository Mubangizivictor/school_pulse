import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class BroadcastHistoryScreen extends StatelessWidget {
  const BroadcastHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schoolId = context.select<AuthBloc, String?>((bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user.schoolId : null;
    });
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: const AdminAppBar(title: 'Broadcast History'),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .where('schoolId', isEqualTo: schoolId)
            .where('type', whereIn: ['Push', 'SMS'])
            .orderBy('timestamp', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SchoolPulseLoader());
          }
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Couldn\'t load broadcast history',
              message:
                  'Something went wrong on our end. Pull to refresh or check back shortly.',
            );
          }
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No broadcasts sent yet',
              message:
                  'Announcements you send from Broadcast Center will show up here.',
            );
          }
          final semantic = Theme.of(context).extension<SemanticColors>()!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final title = data['title'] as String? ?? 'Broadcast';
              final body = data['body'] as String? ?? '';
              final type = data['type'] as String? ?? 'Push';
              final status = data['status'] as String? ?? 'sent';
              final targets = List<String>.from(
                data['targets'] as List? ?? const [],
              );
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final statusColor = switch (status) {
                'failed' => semantic.error,
                'not_configured' => semantic.error,
                'scheduled' => semantic.info,
                'pending' => semantic.warning,
                _ => semantic.success,
              };
              final statusLabel = status == 'not_configured'
                  ? 'Not sent — no SMS provider'
                  : status;

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          type == 'SMS' ? Icons.sms : Icons.campaign,
                          size: 16,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(label: statusLabel, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            targets.join(', '),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timestamp != null)
                          Text(
                            DateFormat('MMM dd, hh:mm a').format(timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
