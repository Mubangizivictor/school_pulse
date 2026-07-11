import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';

class StaffMoreScreen extends StatelessWidget {
  const StaffMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeInSlide(
            child: _buildMenuSection(
              context,
              'Teacher Tools',
              [
                _MenuTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Lesson Plans',
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.analytics_outlined,
                  title: 'Class Analytics',
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.event_note_outlined,
                  title: 'School Calendar',
                  onTap: () {},
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
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.description_outlined,
                  title: 'Payslips',
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.lock_outline,
                  title: 'Security Settings',
                  onTap: () {},
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
