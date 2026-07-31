import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_bloc.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_event.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class LibrarianDashboardScreen extends StatefulWidget {
  const LibrarianDashboardScreen({super.key});

  @override
  State<LibrarianDashboardScreen> createState() => _LibrarianDashboardScreenState();
}

class _LibrarianDashboardScreenState extends State<LibrarianDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<LibraryBloc>().add(WatchLibraryResources(authState.user.schoolId));
      context.read<LibraryBloc>().add(FetchLibraryStats(authState.user.schoolId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Student Eligibility Lookup',
            onPressed: () => context.push('/staff/librarian/lookup'),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Implement QR/Barcode scanner for borrowing/returns
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<LibraryBloc>().add(FetchLibraryStats(authState.user.schoolId));
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatsOverview(context, state),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Procurement & Repairs'),
                const SizedBox(height: 12),
                _buildIntegratedActions(context),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Show Add Resource Dialog/Screen
        },
        label: const Text('Add Resource'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, LibraryState state) {
    Map<String, dynamic> stats = {
      'totalBooks': 0,
      'borrowedBooks': 0,
      'overdueBooks': 0,
    };

    if (state is LibraryStatsLoaded) {
      stats = state.stats;
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        DashboardStatCard(
          title: 'Total Items',
          value: stats['totalBooks'].toDouble(),
          icon: Icons.inventory_2_outlined,
          color: Theme.of(context).primaryColor,
        ),
        DashboardStatCard(
          title: 'Borrowed',
          value: stats['borrowedBooks'].toDouble(),
          icon: Icons.book_outlined,
          color: Colors.blue,
        ),
        DashboardStatCard(
          title: 'Overdue',
          value: stats['overdueBooks'].toDouble(),
          icon: Icons.warning_amber_rounded,
          color: Theme.of(context).extension<SemanticColors>()!.error,
        ),
        DashboardStatCard(
          title: 'Fines Due',
          value: 0.0, // TODO: Fetch from state
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickActionChip(
          label: 'Issue Item',
          icon: Icons.outbond_outlined,
          onTap: () {},
        ),
        _QuickActionChip(
          label: 'Receive Return',
          icon: Icons.move_to_inbox_outlined,
          onTap: () {},
        ),
        _QuickActionChip(
          label: 'Reservations',
          icon: Icons.bookmark_added_outlined,
          onTap: () {},
        ),
        _QuickActionChip(
          label: 'Digital Library',
          icon: Icons.cloud_upload_outlined,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildIntegratedActions(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.purple),
            ),
            title: const Text('Procurement Request'),
            subtitle: const Text('Request new books or materials'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Stores & Assets Procurement Request
            },
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: const Icon(Icons.build_outlined, color: Colors.orange),
            ),
            title: const Text('Repair Request'),
            subtitle: const Text('Report damaged furniture or equipment'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Stores & Assets Repair Request
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
