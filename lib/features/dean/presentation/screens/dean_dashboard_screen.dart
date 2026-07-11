import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class DeanDashboardScreen extends StatelessWidget {
  const DeanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: 32),
                  _buildActionGrid(context),
                  const SizedBox(height: 32),
                  _buildAcademicsOverview(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 80,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('Dean of Studies Console', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none_outlined), onPressed: () {}),
        const SizedBox(width: 16),
        const CircleAvatar(radius: 18, child: Icon(Icons.person)),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = (state is AuthAuthenticated) ? state.user.name : 'Dean';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $name', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('Academic Year 2024 • Term 3', style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _DeanActionCard(
          icon: Icons.menu_book, 
          label: 'Curriculum & Syllabi', 
          color: Colors.blue,
          onTap: () => GoRouter.of(context).go('/staff/dean/curriculum'),
        ),
        _DeanActionCard(icon: Icons.event_note, label: 'Academic Calendar', color: Colors.orange),
        _DeanActionCard(icon: Icons.analytics, label: 'Performance Analytics', color: Colors.purple),
        _DeanActionCard(icon: Icons.assignment, label: 'Exams & Assessment', color: Colors.green),
      ],
    );
  }

  Widget _buildAcademicsOverview(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Academic Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          const Row(
            children: [
              _Metric(label: 'Avg. Attendance', value: '94%'),
              _Metric(label: 'Syllabus Coverage', value: '68%'),
              _Metric(label: 'Pending Results', value: '4 Classes'),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Recent Department Updates', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _DepartmentUpdate(dept: 'Science', update: 'Physics syllabus completed for S4', time: '2h ago'),
          _DepartmentUpdate(dept: 'Mathematics', update: 'Termly tests scores uploaded', time: 'Yesterday'),
        ],
      ),
    );
  }
}

class _DeanActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _DeanActionCard({
    required this.icon, 
    required this.label, 
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _DepartmentUpdate extends StatelessWidget {
  final String dept;
  final String update;
  final String time;

  const _DepartmentUpdate({required this.dept, required this.update, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('[$dept]', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(child: Text(update, style: const TextStyle(fontSize: 13))),
          Text(time, style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
