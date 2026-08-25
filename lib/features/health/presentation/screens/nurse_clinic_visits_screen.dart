import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/design_system/app_components.dart';

class NurseClinicVisitsScreen extends StatefulWidget {
  const NurseClinicVisitsScreen({super.key});

  @override
  State<NurseClinicVisitsScreen> createState() =>
      _NurseClinicVisitsScreenState();
}

class _NurseClinicVisitsScreenState extends State<NurseClinicVisitsScreen> {
  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  void _loadVisits() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<HealthBloc>().add(
        FetchClinicVisits(schoolId: authState.user.schoolId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Clinic Visits',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          if (state is HealthLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is ClinicVisitsLoaded) {
            if (state.visits.isEmpty) {
              return const EmptyState(
                icon: Icons.medical_services_outlined,
                title: 'No visits recorded',
                message: 'Records of clinic visits will appear here.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.visits.length,
              itemBuilder: (context, index) {
                final visit = state.visits[index];
                return _buildVisitCard(context, visit);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/staff/nurse/lookup',
        ), // Redirect to student lookup for new visit
        label: const Text('New Visit'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, ClinicVisit visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Student ID: ${visit.studentId.substring(0, 8)}',
                style: AppTypography.labelSmall.copyWith(color: Colors.black),
              ),
              Text(
                'Today, 10:30 AM', // In a real app, format visit.dateTime
                style: AppTypography.labelSmall.copyWith(color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            visit.reason,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBadge(visit.outcome.name.splitCamelCase(), Colors.black),
              if (visit.temperature != null) ...[
                const SizedBox(width: 8),
                _buildBadge('${visit.temperature}°C', Colors.black),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String splitCamelCase() {
    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match m) => '${m[1]} ${m[2]}',
    ).capitalize();
  }

  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
