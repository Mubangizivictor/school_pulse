import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';

class NurseRecordsHubScreen extends StatefulWidget {
  const NurseRecordsHubScreen({super.key});

  @override
  State<NurseRecordsHubScreen> createState() => _NurseRecordsHubScreenState();
}

class _NurseRecordsHubScreenState extends State<NurseRecordsHubScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<HealthBloc>().add(
        FetchHealthDashboardData(authState.user.schoolId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070914),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Health Records',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildRecordCard(
                    context,
                    title: 'Clinic Visits',
                    subtitle: 'Daily patient logs',
                    icon: Icons.medical_services_outlined,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.push('/staff/nurse/visits'),
                  ),
                  _buildRecordCard(
                    context,
                    title: 'Medical Profiles',
                    subtitle: 'Student health info',
                    icon: Icons.person_search_outlined,
                    color: const Color(0xFF10B981),
                    onTap: () => context.push('/staff/nurse/lookup'),
                  ),
                  _buildRecordCard(
                    context,
                    title: 'Medications',
                    subtitle: 'Drug administration',
                    icon: Icons.medication_outlined,
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.push('/staff/nurse/medications'),
                  ),
                  _buildRecordCard(
                    context,
                    title: 'Inventory',
                    subtitle: 'Stock management',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.push('/staff/nurse/inventory'),
                  ),
                ],
              ),
            ),
            _buildRecentActivitySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151929),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/staff/nurse/history'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<HealthBloc, HealthState>(
            builder: (context, state) {
              if (state is HealthDashboardLoaded &&
                  state.todayVisits.isNotEmpty) {
                return Column(
                  children: state.todayVisits.take(3).map((visit) {
                    return _buildActivityItem(
                      context,
                      title: 'Clinic Visit',
                      subtitle: visit.reason,
                      time: 'Today',
                      icon: Icons.history,
                    );
                  }).toList(),
                );
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No recent activity',
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151929),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
