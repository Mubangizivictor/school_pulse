import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/teacher_library_screen.dart';

class StaffMoreScreen extends StatelessWidget {
  const StaffMoreScreen({super.key});

  static const _teacherRoles = [UserRole.classTeacher, UserRole.subjectTeacher];
  static const _boardingRoles = [UserRole.boardingPatron, UserRole.boardingMatron];

  /// Matron and Patron share the same boarding screens against different
  /// wings, so only the route prefix differs.
  static String _boardingRoot(AuthState state) {
    if (state is AuthAuthenticated &&
        state.user.roles.contains(UserRole.boardingPatron)) {
      return '/staff/patron';
    }
    return '/staff/matron';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isTeacher = authState is AuthAuthenticated && _teacherRoles.contains(authState.user.role);
    final isBoardingStaff = authState is AuthAuthenticated && _boardingRoles.contains(authState.user.role);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeInSlide(
            child: _buildMenuSection(
              context,
              isTeacher ? 'Teacher Tools' : 'Tools',
              [
                if (isTeacher)
                  _MenuTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Lesson Plans',
                    onTap: () => context.push('/staff/lesson-plans'),
                  ),
                if (isTeacher)
                  _MenuTile(
                    icon: Icons.assignment_outlined,
                    title: 'Homework & Assignments',
                    onTap: () => context.push('/staff/homework'),
                  ),
                if (isTeacher)
                  _MenuTile(
                    icon: Icons.comment_bank_outlined,
                    title: 'Report Comments',
                    onTap: () => context.push('/staff/report-comments'),
                  ),
                if (isTeacher)
                  _MenuTile(
                    icon: Icons.analytics_outlined,
                    title: 'Class Analytics',
                    onTap: () => context.push('/staff/class-analytics'),
                  ),
                if (!isBoardingStaff)
                  _MenuTile(
                    icon: Icons.library_books_outlined,
                    title: 'Library & Resources',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TeacherLibraryScreen()),
                    ),
                  ),
                // Boarding modules that the bottom nav has no room for.
                if (isBoardingStaff) ...[
                  _MenuTile(
                    icon: Icons.favorite_outline,
                    title: 'Student Welfare',
                    onTap: () => context.push('${_boardingRoot(authState)}/welfare'),
                  ),
                  _MenuTile(
                    icon: Icons.exit_to_app,
                    title: 'Leave Requests',
                    onTap: () => context.push('${_boardingRoot(authState)}/leave'),
                  ),
                  _MenuTile(
                    icon: Icons.gavel_outlined,
                    title: 'Discipline',
                    onTap: () => context.push('${_boardingRoot(authState)}/discipline'),
                  ),
                  _MenuTile(
                    icon: Icons.campaign_outlined,
                    title: 'Announcements',
                    onTap: () => context.push('${_boardingRoot(authState)}/communication'),
                  ),
                ],
                _MenuTile(
                  icon: Icons.event_note_outlined,
                  title: 'School Calendar',
                  onTap: () => context.push('/staff/calendar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FadeInSlide(
            delay: const Duration(milliseconds: 200),
            child: _buildMenuSection(
              context,
              'Administrative',
              [
                _MenuTile(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  onTap: () => context.push('/staff/profile'),
                ),
                _MenuTile(
                  icon: Icons.lock_outline,
                  title: 'Security Settings',
                  onTap: () => context.push('/staff/security-settings'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeInSlide(
            delay: const Duration(milliseconds: 400),
            child: SecondaryButton(
              label: 'Logout',
              onPressed: () {
                context.read<AuthBloc>().add(LogoutPressed());
                context.go('/login');
              },
              icon: Icons.logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: children.asMap().entries.map((entry) {
              final idx = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (idx < children.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
