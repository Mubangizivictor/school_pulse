import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

/// "Departments" screen from the reference: a list of departments each with
/// a leading icon and a trailing performance percentage.
///
/// The reference shows a per-department performance score, but no director
/// or structure data source currently computes one - this screen lists the
/// school's real departments (from [StructureBloc], the existing source of
/// truth for the Structure module) without a fabricated score.
class DepartmentsOverviewScreen extends StatelessWidget {
  const DepartmentsOverviewScreen({super.key});

  static const _icons = <String, (IconData, Color)>{
    'academics': (Icons.school_outlined, Colors.black),
    'finance': (Icons.account_balance_wallet_outlined, Colors.black),
    'library': (Icons.local_library_outlined, Colors.black),
    'health': (Icons.favorite_outline, Colors.black),
    'security': (Icons.security_outlined, Colors.black),
    'transport': (Icons.directions_bus_outlined, Colors.black),
    'stores': (Icons.inventory_2_outlined, Colors.black),
    'catering': (Icons.restaurant_outlined, Colors.black),
    'boarding': (Icons.night_shelter_outlined, Colors.black),
    'discipline': (Icons.gavel_outlined, Colors.black),
  };

  (IconData, Color) _iconFor(String name) {
    final key = name.toLowerCase();
    for (final entry in _icons.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return (Icons.corporate_fare_outlined, Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Departments')),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final departments =
              state.departments.where((d) => d.isActive).toList()
                ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          if (departments.isEmpty) {
            return const EmptyState(
              icon: Icons.corporate_fare_outlined,
              title: 'No departments set up yet',
              message: 'Departments configured in Structure will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.x3l,
            ),
            itemCount: departments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final dept = departments[i];
              final (icon, color) = _iconFor(dept.name);
              return AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(
                    dept.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: dept.description.isNotEmpty
                      ? Text(dept.description)
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
