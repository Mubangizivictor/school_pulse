import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import '../../domain/repositories/student_repository.dart';
import '../../../../injection_container.dart';

class StudentMoreScreen extends StatelessWidget {
  const StudentMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final studentId = user?.studentId;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          if (studentId != null)
            _buildSection(context, 'Personal', [
              _buildTile(
                context,
                Icons.person_outline,
                'My Profile',
                '/student/profile',
              ),
              _buildTile(
                context,
                Icons.badge_outlined,
                'Student ID Card',
                '/student/id-card',
                onTap: () async {
                  final result = await sl<StudentRepository>().getStudentById(
                    studentId,
                  );
                  result.fold(
                    (failure) => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(failure.message))),
                    (student) =>
                        context.push('/student/id-card', extra: student),
                  );
                },
              ),
            ]),
          _buildSection(context, 'School Services', [
            _buildTile(
              context,
              Icons.account_balance_wallet_outlined,
              'Fees & Finance',
              '/student/fees',
            ),
            _buildTile(
              context,
              Icons.library_books_outlined,
              'Library',
              '/student/library',
            ),
            _buildTile(
              context,
              Icons.directions_bus_outlined,
              'Transport',
              '/student/transport',
            ),
          ]),
          _buildSection(context, 'Records', [
            _buildTile(
              context,
              Icons.health_and_safety_outlined,
              'Health Records',
              '/student/health',
            ),
            _buildTile(
              context,
              Icons.gavel_outlined,
              'Discipline Records',
              '/student/discipline',
            ),
          ]),
          _buildSection(context, 'Account', [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () => _handleLogout(context),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap ?? () => context.push(route),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              Navigator.pop(context);
              context.go('/welcome');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
