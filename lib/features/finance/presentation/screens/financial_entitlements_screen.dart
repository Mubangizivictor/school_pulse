import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Finance-only console for configuring service gates. Service teams receive
/// decisions from the terminal callable, never this financial read model.
class FinancialEntitlementsScreen extends StatelessWidget {
  const FinancialEntitlementsScreen({super.key});

  static const _services = <String, String>{
    'dining': 'Dining & meals',
    'boarding': 'Boarding',
    'transport': 'School transport',
    'internalExams': 'Internal examinations',
    'reportCards': 'Report cards',
    'library': 'Library borrowing',
    'ict': 'ICT & printing',
    'practicals': 'Practical materials',
    'activities': 'Sports & clubs',
    'trips': 'Trips & excursions',
    'remedial': 'Remedial classes',
    'certificates': 'Certificates',
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view entitlements.')),
      );
    }
    final roles = auth.user.roles.map((r) => r.name).toSet();
    if (roles.intersection({
      'bursar',
      'schoolAdmin',
      'headTeacher',
      'director',
    }).isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'You do not have permission to view financial entitlements.',
          ),
        ),
      );
    }
    final schoolId = auth.user.schoolId;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Financial entitlements')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .doc('schools/$schoolId/financial_entitlement_policy/current')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load entitlement policies.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final services =
              (snapshot.data!.data()?['services'] as Map<String, dynamic>?) ??
              const {};
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text(
                'Service access is disabled until a policy is explicitly enabled.',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: AppSpacing.l),
              for (final entry in _services.entries)
                _ServicePolicyCard(
                  schoolId: schoolId,
                  keyName: entry.key,
                  title: entry.value,
                  rule: Map<String, dynamic>.from(
                    services[entry.key] as Map? ?? const {},
                  ),
                ),
              const SizedBox(height: AppSpacing.l),
              const _SafetyNotice(),
            ],
          );
        },
      ),
    );
  }
}

class _ServicePolicyCard extends StatelessWidget {
  const _ServicePolicyCard({
    required this.schoolId,
    required this.keyName,
    required this.title,
    required this.rule,
  });
  final String schoolId;
  final String keyName;
  final String title;
  final Map<String, dynamic> rule;
  @override
  Widget build(BuildContext context) {
    final enabled = rule['enabled'] == true;
    final minimum = (rule['minimumPaymentPercentage'] as num?)?.toInt() ?? 100;
    return Card(
      child: ListTile(
        leading: Icon(
          enabled ? Icons.verified_user_outlined : Icons.policy_outlined,
          color: enabled ? Colors.green : null,
        ),
        title: Text(title),
        subtitle: Text(
          enabled ? 'Enabled · minimum payment $minimum%' : 'Not configured',
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (value) => _save(context, value, minimum),
        ),
        onTap: () => _edit(context, enabled, minimum),
      ),
    );
  }

  Future<void> _save(BuildContext context, bool enabled, int minimum) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('saveFinancialEntitlementPolicy')
          .call({
            'schoolId': schoolId,
            'services': {
              keyName: {
                'enabled': enabled,
                'minimumPaymentPercentage': minimum,
                'maximumBalance': 0,
              },
            },
          });
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Policy could not be saved.')),
        );
      }
    }
  }

  Future<void> _edit(BuildContext context, bool enabled, int minimum) async {
    var selected = minimum;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title policy'),
        content: DropdownButtonFormField<int>(
          initialValue: selected,
          items: const [0, 25, 50, 75, 100]
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text('$v% minimum payment'),
                ),
              )
              .toList(),
          onChanged: (v) => selected = v ?? selected,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, selected),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      await _save(context, true, result);
    }
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();
  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.background(context),
    child: const Padding(
      padding: EdgeInsets.all(AppSpacing.m),
      child: Text(
        'Safety protection: national exams, emergency healthcare, water, sanitation, safeguarding, ordinary learning, attendance and safe guardian release cannot be fee-gated. Transport and boarding exceptions require staff welfare action.',
      ),
    ),
  );
}
