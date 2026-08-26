import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/injection_container.dart';

import '../../domain/entities/credential_history_entry.dart';
import '../../domain/repositories/student_identity_repository.dart';

/// Read-only credential lifecycle history for one student, backed by
/// schools/{schoolId}/credential_history (append-only, written exclusively
/// by Cloud Functions - see functions/student_credentials.js). Shared by
/// the Identity tab (`_NfcCard`'s "View card history") and the Student ID
/// Card preview screen so the history view isn't duplicated a third time.
class CardHistorySheet extends StatelessWidget {
  final String studentId;
  final String schoolId;

  const CardHistorySheet({
    super.key,
    required this.studentId,
    required this.schoolId,
  });

  static Future<void> show(
    BuildContext context, {
    required String studentId,
    required String schoolId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) =>
          CardHistorySheet(studentId: studentId, schoolId: schoolId),
    );
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'nfc_assigned':
        return 'Card assigned';
      case 'nfc_replaced':
        return 'Card replaced';
      case 'nfc_revoked':
        return 'Card revoked';
      case 'nfc_reactivated':
        return 'Card reactivated';
      case 'qr_replaced':
        return 'QR credential replaced';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card history',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: FutureBuilder<List<CredentialHistoryEntry>>(
                future: sl<StudentIdentityRepository>()
                    .getCredentialHistory(
                      studentId: studentId,
                      schoolId: schoolId,
                    )
                    .then((result) => result.fold((_) => [], (v) => v)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: SchoolPulseLoader()),
                    );
                  }
                  final entries = snapshot.data ?? const [];
                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No card history yet.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_actionLabel(entry.action)),
                        subtitle: Text(
                          entry.reason?.isNotEmpty == true
                              ? '${DateFormat('d MMM yyyy, HH:mm').format(entry.createdAt)} · ${entry.reason}'
                              : DateFormat(
                                  'd MMM yyyy, HH:mm',
                                ).format(entry.createdAt),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
