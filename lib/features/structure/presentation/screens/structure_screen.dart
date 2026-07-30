import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/structure_ui_kit.dart';

/// The Structure module's control panel: the single place a School Admin
/// configures the institution's educational structure and master data, so
/// no part of the app hardcodes academic values that vary school to school.
///
/// A compact icon-tile grid - matching Admin dashboard's shortcut style -
/// linking to each category's own focused screen.
class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StructureHubTile(
        icon: Icons.apartment_outlined,
        color: Colors.indigo,
        label: 'Institution Profile',
        onTap: () => context.push('/staff/admin/structure/institution'),
      ),
      StructureHubTile(
        icon: Icons.school_outlined,
        color: Colors.blue,
        label: 'Academic Structure',
        onTap: () => context.push('/staff/admin/structure/academic'),
      ),
      StructureHubTile(
        icon: Icons.groups_2_outlined,
        color: Colors.teal,
        label: 'People',
        onTap: () => context.push('/staff/admin/structure/people'),
      ),
      StructureHubTile(
        icon: Icons.grading_outlined,
        color: Colors.deepOrange,
        label: 'Assessment & Grading',
        onTap: () => context.push('/staff/admin/structure/assessment'),
      ),
      StructureHubTile(
        icon: Icons.location_city_outlined,
        color: Colors.brown,
        label: 'Campus & Facilities',
        onTap: () => context.push('/staff/admin/structure/campus'),
      ),
      StructureHubTile(
        icon: Icons.tune_outlined,
        color: Colors.purple,
        label: 'Operations Config',
        onTap: () => context.push('/staff/admin/structure/operations'),
      ),
      StructureHubTile(
        icon: Icons.toggle_on_outlined,
        color: Colors.green,
        label: 'Feature Toggles',
        onTap: () => context.push('/staff/admin/structure/feature-toggles'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('School Structure')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 900
              ? 6
              : (MediaQuery.of(context).size.width > 600 ? 4 : 3),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95,
        ),
        itemCount: tiles.length,
        itemBuilder: (context, index) => tiles[index],
      ),
    );
  }
}
