import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import '../widgets/academics_ui_kit.dart';

/// Structure -> Academics landing page: seven navigation cards to each
/// academic-structure subsection, matching the reference UI's flat card
/// list (Levels, Years & Terms, Classes & Streams, Subjects, Departments,
/// Grading Systems, Assessment Types).
class AcademicsLandingScreen extends StatelessWidget {
  const AcademicsLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Academics'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Configure your academic structure',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          AcademicsNavCard(
            icon: Icons.layers_outlined,
            color: Colors.teal,
            title: 'Levels',
            subtitle: 'Manage educational levels',
            onTap: () =>
                context.push('/staff/admin/structure/academics/levels'),
          ),
          AcademicsNavCard(
            icon: Icons.calendar_today_outlined,
            color: Colors.blue,
            title: 'Years & Terms',
            subtitle: 'Academic years, terms & semesters',
            onTap: () =>
                context.push('/staff/admin/structure/academics/years-terms'),
          ),
          AcademicsNavCard(
            icon: Icons.groups_2_outlined,
            color: Colors.indigo,
            title: 'Classes & Streams',
            subtitle: 'Create classes and streams',
            onTap: () => context.push(
              '/staff/admin/structure/academics/classes-streams',
            ),
          ),
          AcademicsNavCard(
            icon: Icons.menu_book_outlined,
            color: Colors.purple,
            title: 'Subjects',
            subtitle: 'Manage subjects and groups',
            onTap: () =>
                context.push('/staff/admin/structure/academics/subjects'),
          ),
          AcademicsNavCard(
            icon: Icons.account_balance_outlined,
            color: Colors.redAccent,
            title: 'Departments',
            subtitle: 'Academic departments',
            onTap: () =>
                context.push('/staff/admin/structure/academics/departments'),
          ),
          AcademicsNavCard(
            icon: Icons.star_outline,
            color: Colors.amber,
            title: 'Grading Systems',
            subtitle: 'Grading scales and systems',
            onTap: () => context.push(
              '/staff/admin/structure/academics/grading-systems',
            ),
          ),
          AcademicsNavCard(
            icon: Icons.fact_check_outlined,
            color: Colors.green,
            title: 'Assessment Types',
            subtitle: 'Manage assessment types',
            onTap: () => context.push(
              '/staff/admin/structure/academics/assessment-types',
            ),
          ),
        ],
      ),
    );
  }
}
