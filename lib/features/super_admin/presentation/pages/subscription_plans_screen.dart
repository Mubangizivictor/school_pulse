import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('New Plan'),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) {
          if (state.status == SuperAdminStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isWide = isSuperAdminWide(context);
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : 1,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isWide ? 0.8 : 1.3,
            ),
            itemCount: state.plans.length,
            itemBuilder: (context, index) {
              final plan = state.plans[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (plan.isDefault)
                            const Chip(label: Text('DEFAULT', style: TextStyle(fontSize: 10))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'UGX ${plan.price}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text('per ${plan.billingCycle.name}'),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _PlanFeature(label: '${plan.maxStudents} Students'),
                      _PlanFeature(label: '${plan.maxStaff} Staff'),
                      _PlanFeature(label: '${plan.storageLimitGb} GB Storage'),
                      ...plan.includedFeatures.map((f) => _PlanFeature(label: f)),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Edit Plan'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  final String label;
  const _PlanFeature({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
