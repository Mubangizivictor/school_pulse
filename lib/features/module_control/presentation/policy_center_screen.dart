import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import '../data/module_control_repository.dart';
import '../domain/institution_policy.dart';
import 'policy_editor_screen.dart';

String policyTypeLabel(InstitutionPolicyType type) {
  switch (type) {
    case InstitutionPolicyType.attendance:
      return 'Attendance';
    case InstitutionPolicyType.parentPortal:
      return 'Parent Portal';
    case InstitutionPolicyType.studentPortal:
      return 'Student Portal';
    case InstitutionPolicyType.reportRelease:
      return 'Report Release';
    case InstitutionPolicyType.financeAccess:
      return 'Finance Access';
    case InstitutionPolicyType.messaging:
      return 'Messaging';
    case InstitutionPolicyType.notifications:
      return 'Notifications';
    case InstitutionPolicyType.visitorSecurity:
      return 'Visitor & Security';
    case InstitutionPolicyType.boarding:
      return 'Boarding';
    case InstitutionPolicyType.transport:
      return 'Transport';
    case InstitutionPolicyType.healthPrivacy:
      return 'Health Privacy';
    case InstitutionPolicyType.dataRetention:
      return 'Data Retention';
    case InstitutionPolicyType.security:
      return 'Security';
    case InstitutionPolicyType.biometrics:
      return 'Biometrics';
    case InstitutionPolicyType.googleSheets:
      return 'Google Sheets Export';
  }
}

class PolicyCenterScreen extends StatefulWidget {
  const PolicyCenterScreen({super.key});

  @override
  State<PolicyCenterScreen> createState() => _PolicyCenterScreenState();
}

class _PolicyCenterScreenState extends State<PolicyCenterScreen> {
  final _repository = ModuleControlRepository();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to manage institution policies.')),
      );
    }
    return Scaffold(
      appBar: const AdminAppBar(title: 'Policy Center'),
      body: StreamBuilder<List<InstitutionPolicy>>(
        stream: _repository.watchPolicies(auth.user.schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load policies: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final policies = snapshot.data!;
          final byType = <InstitutionPolicyType, List<InstitutionPolicy>>{};
          for (final policy in policies) {
            (byType[policy.type] ??= []).add(policy);
          }
          final types = InstitutionPolicyType.values.where(
            (type) => policyTypeLabel(
              type,
            ).toLowerCase().contains(_query.toLowerCase()),
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText:
                        'Search policies (attendance, parents, security…)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: types.map((type) {
                    final all = byType[type] ?? const <InstitutionPolicy>[];
                    final activeCount = all
                        .where((p) => p.status == PolicyStatus.active)
                        .length;
                    final scheduledCount = all
                        .where((p) => p.status == PolicyStatus.scheduled)
                        .length;
                    final subtitle = StringBuffer(
                      activeCount == 0
                          ? 'No active policy — platform defaults apply'
                          : '$activeCount active scope(s) configured',
                    );
                    if (scheduledCount > 0) {
                      subtitle.write(
                        '\n$scheduledCount scheduled change pending',
                      );
                    }
                    return Card(
                      child: ListTile(
                        title: Text(policyTypeLabel(type)),
                        subtitle: Text(subtitle.toString()),
                        isThreeLine: scheduledCount > 0,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PolicyEditorScreen(
                              policyType: type,
                              schoolId: auth.user.schoolId,
                              actorId: auth.user.id,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
