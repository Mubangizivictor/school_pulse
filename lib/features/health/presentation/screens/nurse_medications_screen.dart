import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/medical_inventory.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/design_system/app_components.dart';

class NurseMedicationsScreen extends StatefulWidget {
  const NurseMedicationsScreen({super.key});

  @override
  State<NurseMedicationsScreen> createState() => _NurseMedicationsScreenState();
}

class _NurseMedicationsScreenState extends State<NurseMedicationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  void _loadInventory() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<HealthBloc>().add(FetchInventory(authState.user.schoolId));
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
          'Medication Administration',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          if (state is HealthLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is InventoryLoaded) {
            final medications = state.items
                .where((item) => item.type == MedicalItemType.medication)
                .toList();

            if (medications.isEmpty) {
              return const EmptyState(
                icon: Icons.medication_outlined,
                title: 'No medications found',
                message: 'Add medications to the inventory to see them here.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Available Medications',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: medications.length,
                    itemBuilder: (context, index) {
                      final medication = medications[index];
                      return _buildMedicationCard(context, medication);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/staff/nurse/lookup',
        ), // Again, look up student to administer
        label: const Text('Administer Med'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _buildMedicationCard(BuildContext context, MedicalInventoryItem item) {
    final isLowStock = item.quantity <= item.reorderLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowStock ? Colors.black : Colors.black,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isLowStock ? Colors.black : Colors.black),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication,
              color: isLowStock ? Colors.black : Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.category} • ${item.quantity} ${item.unit} left',
                  style: AppTypography.bodySmall.copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
          if (isLowStock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'LOW',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
