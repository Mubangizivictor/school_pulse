import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/parent_access/domain/entities/parent_module_visibility.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_cubit.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_state.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentAccessCubit, ParentAccessState>(
      builder: (context, accessState) {
        final visibility = accessState is ParentAccessResolved
            ? accessState.visibility
            : ParentModuleVisibility.none;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'More',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionHeader('CARE & TRANSPORT'),
              const SizedBox(height: 12),
              _buildMenuCard([
                _buildMenuTile(
                  context,
                  icon: Icons.health_and_safety_outlined,
                  title: 'Health & Clinic Visits',
                  onTap: () => context.push('/parent/health'),
                  visible: visibility.health,
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.directions_bus_outlined,
                  title: 'Transport Routes',
                  onTap: () => context.push('/parent/transport'),
                  visible: visibility.transport,
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.door_front_door_outlined,
                  title: 'Gate Activity',
                  onTap: () => context.push('/parent/security'),
                  visible: visibility.security,
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader('SCHOOL INFO'),
              const SizedBox(height: 12),
              _buildMenuCard([
                _buildMenuTile(
                  context,
                  icon: Icons.calendar_month_outlined,
                  title: 'School Calendar',
                  onTap: () => context.push('/parent/calendar'),
                  visible: visibility.academics,
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.library_books_outlined,
                  title: 'Library',
                  onTap: () => context.push('/parent/library'),
                  visible: visibility.library,
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader('ACCOUNT'),
              const SizedBox(height: 12),
              _buildMenuCard([
                _buildMenuTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile Settings',
                  onTap: () => context.push('/parent/profile'),
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification Preferences',
                  onTap: () => context.push('/parent/profile'),
                ),
              ]),
              const SizedBox(height: 40),
              SecondaryButton(
                label: 'Log Out',
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutPressed());
                  context.go('/welcome');
                },
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'School Pulse v1.2.0',
                  style: TextStyle(color: AppColors.grey500, fontSize: 12),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.grey500,
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> tiles) {
    final visibleTiles = tiles.where((tile) {
      if (tile is _MenuTile) return tile.visible;
      return true;
    }).toList();

    if (visibleTiles.isEmpty) return const SizedBox.shrink();

    return AppCard(
      padding: EdgeInsets.zero,
      showShadow: false,
      child: Column(
        children: visibleTiles.asMap().entries.map((entry) {
          final isLast = entry.key == visibleTiles.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast) const Divider(height: 1, indent: 52),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool visible = true,
  }) {
    return _MenuTile(icon: icon, title: title, onTap: onTap, visible: visible);
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool visible;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon, color: AppColors.black, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
      onTap: onTap,
    );
  }
}
