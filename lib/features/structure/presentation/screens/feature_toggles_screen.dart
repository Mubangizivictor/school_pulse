import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/feature_toggles.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// Master switches for which optional modules this school has enabled.
class FeatureTogglesScreen extends StatelessWidget {
  const FeatureTogglesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Feature choices')) : null,
      backgroundColor: showAppBar ? null : Colors.transparent,
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => _FeatureTogglesBody(state: state),
      ),
    );
  }
}

class _FeatureToggleSpec {
  final String label;
  final IconData icon;
  final bool value;
  final FeatureToggles Function(bool) apply;

  const _FeatureToggleSpec({
    required this.label,
    required this.icon,
    required this.value,
    required this.apply,
  });
}

class _FeatureTogglesBody extends StatelessWidget {
  final StructureState state;
  const _FeatureTogglesBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final scheme = Theme.of(context).colorScheme;
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final toggles = state.featureToggles;

    void onChanged(FeatureToggles Function(bool) apply, bool value) =>
        bloc.add(UpdateFeatureTogglesRequested(apply(value), schoolId));

    final schoolServices = [
      _FeatureToggleSpec(
        label: 'Transport',
        icon: Icons.directions_bus_outlined,
        value: toggles.transport,
        apply: (v) => toggles.copyWith(transport: v),
      ),
      _FeatureToggleSpec(
        label: 'Boarding',
        icon: Icons.night_shelter_outlined,
        value: toggles.boarding,
        // hostel is a legacy duplicate of this same feature (some gates
        // check `boarding || hostel`); kept in sync here so this one
        // switch is the single source of truth instead of leaving hostel
        // stuck at its default with no way to turn it off.
        apply: (v) => toggles.copyWith(boarding: v, hostel: v),
      ),
      _FeatureToggleSpec(
        label: 'Library',
        icon: Icons.local_library_outlined,
        value: toggles.library,
        apply: (v) => toggles.copyWith(library: v),
      ),
      _FeatureToggleSpec(
        label: 'Medical',
        icon: Icons.medical_services_outlined,
        value: toggles.medical,
        apply: (v) => toggles.copyWith(medical: v),
      ),
      _FeatureToggleSpec(
        label: 'Visitors',
        icon: Icons.meeting_room_outlined,
        value: toggles.visitors,
        apply: (v) => toggles.copyWith(visitors: v),
      ),
    ];

    final operations = [
      _FeatureToggleSpec(
        label: 'Inventory',
        icon: Icons.inventory_2_outlined,
        value: toggles.inventory,
        apply: (v) => toggles.copyWith(inventory: v),
      ),
      _FeatureToggleSpec(
        label: 'Payroll',
        icon: Icons.payments_outlined,
        value: toggles.payroll,
        apply: (v) => toggles.copyWith(payroll: v),
      ),
      _FeatureToggleSpec(
        label: 'Procurement',
        icon: Icons.shopping_cart_checkout_outlined,
        value: toggles.procurement,
        apply: (v) => toggles.copyWith(procurement: v),
      ),
      _FeatureToggleSpec(
        label: 'Communication',
        icon: Icons.campaign_outlined,
        value: toggles.communication,
        apply: (v) => toggles.copyWith(communication: v),
      ),
    ];

    final digitalAccess = [
      _FeatureToggleSpec(
        label: 'QR Attendance',
        icon: Icons.qr_code_scanner_outlined,
        value: toggles.qrAttendance,
        apply: (v) => toggles.copyWith(qrAttendance: v),
      ),
      _FeatureToggleSpec(
        label: 'Digital IDs',
        icon: Icons.badge_outlined,
        value: toggles.digitalIds,
        apply: (v) => toggles.copyWith(digitalIds: v),
      ),
      _FeatureToggleSpec(
        label: 'Parent Portal',
        icon: Icons.family_restroom_outlined,
        value: toggles.parentPortal,
        apply: (v) => toggles.copyWith(parentPortal: v),
      ),
      _FeatureToggleSpec(
        label: 'Student Portal',
        icon: Icons.school_outlined,
        value: toggles.studentPortal,
        apply: (v) => toggles.copyWith(studentPortal: v),
      ),
      _FeatureToggleSpec(
        label: 'Alumni',
        icon: Icons.groups_outlined,
        value: toggles.alumni,
        apply: (v) => toggles.copyWith(alumni: v),
      ),
    ];

    final all = [...schoolServices, ...operations, ...digitalAccess];
    final enabledCount = all.where((t) => t.value).length;
    final disabledCount = all.length - enabledCount;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        children: [
          Text(
            'Enable only the optional modules your school uses.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '$enabledCount enabled · $disabledCount disabled',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _FeatureCategoryCard(
            title: 'School services',
            toggles: schoolServices,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          _FeatureCategoryCard(
            title: 'Operations',
            toggles: operations,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          _FeatureCategoryCard(
            title: 'Digital access',
            toggles: digitalAccess,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FeatureCategoryCard extends StatelessWidget {
  final String title;
  final List<_FeatureToggleSpec> toggles;
  final void Function(FeatureToggles Function(bool) apply, bool value)
  onChanged;

  const _FeatureCategoryCard({
    required this.title,
    required this.toggles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < toggles.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(toggles[i].icon, size: 20),
                title: Text(toggles[i].label),
                value: toggles[i].value,
                onChanged: (v) => onChanged(toggles[i].apply, v),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
