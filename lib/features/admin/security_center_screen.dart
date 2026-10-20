import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Read-only registry views backed by server-written security records. All
/// destructive operations remain Cloud Function calls, so UI state cannot be
/// mistaken for a real session revoke, device trust change, or account lock.
class AdminSecurityCenterScreen extends StatelessWidget {
  const AdminSecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schoolId = context.select<AuthBloc, String?>((bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user.schoolId : null;
    });
    if (schoolId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final school = FirebaseFirestore.instance
        .collection('schools')
        .doc(schoolId);
    return Scaffold(
      appBar: const AdminAppBar(title: 'Security Center'),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: school
            .collection('security_sessions')
            .orderBy('lastActivityAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, sessionsSnapshot) {
          if (sessionsSnapshot.hasError) {
            return _loadError();
          }
          if (!sessionsSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: school
                .collection('trusted_devices')
                .orderBy('lastSeenAt', descending: true)
                .limit(100)
                .snapshots(),
            builder: (context, devicesSnapshot) {
              if (devicesSnapshot.hasError) {
                return _loadError();
              }
              if (!devicesSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('schoolId', isEqualTo: schoolId)
                    .snapshots(),
                builder: (context, usersSnapshot) {
                  if (usersSnapshot.hasError) return _loadError();
                  final sessions = sessionsSnapshot.data!.docs;
                  final devices = devicesSnapshot.data!.docs;
                  final users = {
                    for (final doc
                        in usersSnapshot.data?.docs ??
                            <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                      doc.id: doc.data(),
                  };
                  return _SecurityBody(
                    schoolId: schoolId,
                    sessions: sessions,
                    devices: devices,
                    users: users,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _loadError() => const Center(
    child: EmptyState(
      icon: Icons.lock_outline,
      title: 'Security data unavailable',
      message: 'Check your access and try again.',
    ),
  );
}

class _SecurityBody extends StatelessWidget {
  const _SecurityBody({
    required this.schoolId,
    required this.sessions,
    required this.devices,
    required this.users,
  });
  final String schoolId;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> sessions;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> devices;
  final Map<String, Map<String, dynamic>> users;

  @override
  Widget build(BuildContext context) {
    final active = sessions
        .where((s) => s.data()['sessionStatus'] == 'active')
        .length;
    final trusted = devices
        .where((d) => d.data()['trustStatus'] == 'trusted')
        .length;
    final untrusted = devices
        .where((d) => d.data()['trustStatus'] != 'trusted')
        .length;
    final missingMfa = users.values
        .where((u) => _sensitiveUser(u) && u['mfaEnabled'] != true)
        .length;
    final locked = users.values
        .where((u) => u['securityStatus'] == 'locked' || u['isActive'] == false)
        .length;
    return RefreshIndicator(
      onRefresh: () async =>
          await Future<void>.delayed(const Duration(milliseconds: 300)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Institution security',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Live registry records are retained by the secure backend. Revoking a device signs out all of that user’s Firebase sessions because Firebase Auth does not support device-only token revocation.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Metric(
                label: 'Active sessions',
                value: active,
                icon: Icons.devices,
              ),
              _Metric(
                label: 'Trusted devices',
                value: trusted,
                icon: Icons.verified_user,
              ),
              _Metric(
                label: 'Untrusted devices',
                value: untrusted,
                icon: Icons.warning_amber,
              ),
              _Metric(
                label: 'MFA missing',
                value: missingMfa,
                icon: Icons.phonelink_lock,
              ),
              _Metric(
                label: 'Locked accounts',
                value: locked,
                icon: Icons.lock,
              ),
            ],
          ),
          if (missingMfa > 0) ...[
            const SizedBox(height: 16),
            AlertBanner(
              title: 'MFA attention needed',
              message:
                  '$missingMfa sensitive account${missingMfa == 1 ? '' : 's'} has not enabled MFA.',
              color: Theme.of(context).colorScheme.error,
              icon: Icons.gpp_maybe,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Active sessions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            const EmptyState(
              icon: Icons.devices_other,
              title: 'No recorded sessions',
              message:
                  'Sessions appear after a user signs in on an updated app.',
            ),
          ...sessions.map(
            (doc) => _SessionCard(
              session: doc.data(),
              user: users[doc.data()['userId']],
              onAction: (action) => _sessionAction(context, doc.data(), action),
            ),
          ),
          const SizedBox(height: 24),
          Text('Device trust', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (devices.isEmpty)
            const EmptyState(
              icon: Icons.phone_android,
              title: 'No registered devices',
              message: 'New devices are recorded on secure sign-in.',
            ),
          ...devices.map(
            (doc) => _DeviceCard(
              device: doc.data(),
              user: users[doc.data()['userId']],
              onAction: (status) => _deviceAction(context, doc.data(), status),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent security events',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('schools')
                .doc(schoolId)
                .collection('security_events')
                .orderBy('timestamp', descending: true)
                .limit(30)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Recent event history is unavailable.');
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.data!.docs.isEmpty) {
                return const EmptyState(
                  icon: Icons.history,
                  title: 'No security events yet',
                  message:
                      'Login failures and security actions will appear here.',
                );
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final event = doc.data();
                  final high =
                      event['riskLevel'] == 'high' ||
                      event['riskLevel'] == 'critical';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      child: ListTile(
                        leading: Icon(
                          high
                              ? Icons.warning_amber_rounded
                              : Icons.shield_outlined,
                          color: high
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                        title: Text(
                          event['type']?.toString() ?? 'Security event',
                        ),
                        subtitle: Text(
                          '${event['reason'] ?? event['riskLevel'] ?? 'Informational'} · ${_time(event['timestamp'])}',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Audit log'),
              subtitle: const Text('Track changes made across the system'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/staff/admin/audit-log'),
            ),
          ),
        ],
      ),
    );
  }

  bool _sensitiveUser(Map<String, dynamic> user) {
    final roles = List<String>.from(
      user['roles'] ?? [user['role']],
    ).map((e) => e.toLowerCase());
    return roles.any(
      {'schooladmin', 'headteacher', 'director', 'bursar'}.contains,
    );
  }

  Future<void> _sessionAction(
    BuildContext context,
    Map<String, dynamic> session,
    String action,
  ) async {
    final target = session['userId'] as String?;
    if (target == null) return;
    final reason = await _reason(
      context,
      action == 'lock'
          ? 'Lock account'
          : action == 'reset'
          ? 'Require password reset'
          : 'Revoke sessions',
    );
    if (reason == null || !context.mounted) {
      return;
    }
    final functions = FirebaseFunctions.instance;
    try {
      if (action == 'lock') {
        await functions.httpsCallable('setInstitutionAccountLock').call({
          'targetUserId': target,
          'locked': true,
          'reason': reason,
        });
      } else if (action == 'reset') {
        await functions.httpsCallable('requireInstitutionPasswordReset').call({
          'targetUserId': target,
          'reason': reason,
        });
      } else {
        await functions.httpsCallable('revokeAllInstitutionUserSessions').call({
          'targetUserId': target,
          'sessionId': session['sessionId'],
          'reason': reason,
          'confirmSelf': true,
        });
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security action completed and audited.'),
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Security action failed.')),
        );
      }
    }
  }

  Future<void> _deviceAction(
    BuildContext context,
    Map<String, dynamic> device,
    String status,
  ) async {
    final reason = await _reason(
      context,
      '${status[0].toUpperCase()}${status.substring(1)} device',
    );
    if (reason == null || !context.mounted) {
      return;
    }
    try {
      await FirebaseFunctions.instance
          .httpsCallable('setTrustedDeviceStatus')
          .call({
            'deviceId': device['deviceId'],
            'status': status,
            'reason': reason,
          });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device status updated and audited.')),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Device action failed.')),
        );
      }
    }
  }

  Future<String?> _reason(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$title?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Reason (required)',
            hintText: 'At least 3 characters',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.length >= 3) Navigator.pop(dialogContext, value);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 155,
    child: AppCard(
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$value', style: Theme.of(context).textTheme.titleLarge),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.user,
    required this.onAction,
  });
  final Map<String, dynamic> session;
  final Map<String, dynamic>? user;
  final ValueChanged<String> onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AppCard(
      child: ListTile(
        leading: Icon(
          session['trustedDevice'] == true
              ? Icons.verified_user
              : Icons.devices_other,
        ),
        title: Text(user?['name']?.toString() ?? 'Unknown user'),
        subtitle: Text(
          '${session['deviceName'] ?? 'Unknown device'} · ${session['platform'] ?? 'Unknown'}\n${_time(session['lastActivityAt'])} · MFA ${session['mfaVerified'] == true ? 'verified' : 'not verified'}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: onAction,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'revoke', child: Text('Revoke all sessions')),
            PopupMenuItem(
              value: 'reset',
              child: Text('Require password reset'),
            ),
            PopupMenuItem(value: 'lock', child: Text('Lock account')),
          ],
        ),
      ),
    ),
  );
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.user,
    required this.onAction,
  });
  final Map<String, dynamic> device;
  final Map<String, dynamic>? user;
  final ValueChanged<String> onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AppCard(
      child: ListTile(
        leading: const Icon(Icons.phone_android),
        title: Text(device['deviceName']?.toString() ?? 'Unknown device'),
        subtitle: Text(
          '${user?['name'] ?? 'Unknown user'} · ${device['platform'] ?? 'Unknown'} · ${device['trustStatus'] ?? 'unknown'}\nLast seen ${_time(device['lastSeenAt'])}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: onAction,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'trusted', child: Text('Mark trusted')),
            PopupMenuItem(value: 'untrusted', child: Text('Mark untrusted')),
            PopupMenuItem(value: 'revoked', child: Text('Mark lost / revoke')),
          ],
        ),
      ),
    ),
  );
}

String _time(Object? value) {
  final date = value is Timestamp ? value.toDate() : null;
  return date == null
      ? 'Not yet recorded'
      : DateFormat.yMMMd().add_jm().format(date.toLocal());
}
