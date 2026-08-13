import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/feature_toggles.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// Master switches for which optional modules this school has enabled.
class FeatureTogglesScreen extends StatelessWidget {
  const FeatureTogglesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Feature Toggles'),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => _FeatureTogglesBody(state: state),
      ),
    );
  }
}

class _FeatureTogglesBody extends StatelessWidget {
  final StructureState state;
  const _FeatureTogglesBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final toggles = state.featureToggles;

    Widget buildSwitch(
      String label,
      IconData icon,
      bool value,
      FeatureToggles Function(bool) apply,
    ) {
      return SwitchListTile(
        secondary: Icon(icon),
        title: Text(label),
        value: value,
        onChanged: (v) =>
            bloc.add(UpdateFeatureTogglesRequested(apply(v), schoolId)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Turn optional modules on or off for this school.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ),
        AppCard(
          child: Column(
            children: [
              buildSwitch(
                'Transport',
                Icons.directions_bus_outlined,
                toggles.transport,
                (v) => toggles.copyWith(transport: v),
              ),
              buildSwitch(
                'Hostel',
                Icons.bed_outlined,
                toggles.hostel,
                (v) => toggles.copyWith(hostel: v),
              ),
              buildSwitch(
                'Library',
                Icons.local_library_outlined,
                toggles.library,
                (v) => toggles.copyWith(library: v),
              ),
              buildSwitch(
                'Medical',
                Icons.medical_services_outlined,
                toggles.medical,
                (v) => toggles.copyWith(medical: v),
              ),
              buildSwitch(
                'Visitors',
                Icons.meeting_room_outlined,
                toggles.visitors,
                (v) => toggles.copyWith(visitors: v),
              ),
              buildSwitch(
                'Inventory',
                Icons.inventory_2_outlined,
                toggles.inventory,
                (v) => toggles.copyWith(inventory: v),
              ),
              buildSwitch(
                'Payroll',
                Icons.payments_outlined,
                toggles.payroll,
                (v) => toggles.copyWith(payroll: v),
              ),
              buildSwitch(
                'Procurement',
                Icons.shopping_cart_checkout_outlined,
                toggles.procurement,
                (v) => toggles.copyWith(procurement: v),
              ),
              buildSwitch(
                'Alumni',
                Icons.groups_outlined,
                toggles.alumni,
                (v) => toggles.copyWith(alumni: v),
              ),
              buildSwitch(
                'Communication',
                Icons.campaign_outlined,
                toggles.communication,
                (v) => toggles.copyWith(communication: v),
              ),
              buildSwitch(
                'Boarding',
                Icons.night_shelter_outlined,
                toggles.boarding,
                (v) => toggles.copyWith(boarding: v),
              ),
              buildSwitch(
                'QR Attendance',
                Icons.qr_code_scanner_outlined,
                toggles.qrAttendance,
                (v) => toggles.copyWith(qrAttendance: v),
              ),
              buildSwitch(
                'Digital IDs',
                Icons.badge_outlined,
                toggles.digitalIds,
                (v) => toggles.copyWith(digitalIds: v),
              ),
              buildSwitch(
                'Parent Portal',
                Icons.family_restroom_outlined,
                toggles.parentPortal,
                (v) => toggles.copyWith(parentPortal: v),
              ),
              buildSwitch(
                'Student Portal',
                Icons.school_outlined,
                toggles.studentPortal,
                (v) => toggles.copyWith(studentPortal: v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
