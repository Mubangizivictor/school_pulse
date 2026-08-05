import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_state.dart';
import '../../injection_container.dart';
import '../library/presentation/bloc/library_bloc.dart';
import '../library/presentation/bloc/library_event.dart';
import '../library/presentation/bloc/library_state.dart';
import '../library/domain/entities/library_borrowing.dart';
import 'package:school_pulse/design_system/app_components.dart';

class TeacherLibraryScreen extends StatefulWidget {
  const TeacherLibraryScreen({super.key});

  @override
  State<TeacherLibraryScreen> createState() => _TeacherLibraryScreenState();
}

class _TeacherLibraryScreenState extends State<TeacherLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final staffId =
        user?.id; // For teachers we use their user ID or staffId if available

    if (staffId == null || user == null) {
      return const Scaffold(
        body: Center(child: Text('User information not found.')),
      );
    }

    return BlocProvider(
      create: (context) => sl<LibraryBloc>()
        ..add(WatchBorrowingHistory(user.schoolId, borrowerId: staffId))
        ..add(WatchLibraryResources(user.schoolId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Library Portal'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Borrowings', icon: Icon(Icons.history_edu)),
              Tab(text: 'Resource Catalog', icon: Icon(Icons.library_books)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _MyBorrowingsTab(staffId: staffId),
            _ResourceCatalogTab(schoolId: user.schoolId),
          ],
        ),
      ),
    );
  }
}

class _MyBorrowingsTab extends StatelessWidget {
  final String staffId;
  const _MyBorrowingsTab({required this.staffId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is LibraryLoading && state is! LibraryHistoryLoaded) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LibraryHistoryLoaded) {
          final activeBorrowings = state.history
              .where((b) => b.status != BorrowingStatus.returned)
              .toList();

          if (activeBorrowings.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'No Active Borrowings',
              message: 'Borrow materials or kits for your classes.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeBorrowings.length,
            itemBuilder: (context, index) {
              final borrowing = activeBorrowings[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.inventory_2_outlined),
                  ),
                  title: Text(
                    borrowing.resourceTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(borrowing.dueDate)}',
                  ),
                  trailing: const StatusBadge(
                    label: 'ACTIVE',
                    color: Colors.blue,
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ResourceCatalogTab extends StatelessWidget {
  final String schoolId;
  const _ResourceCatalogTab({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is LibraryResourcesLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.resources.length,
            itemBuilder: (context, index) {
              final resource = state.resources[index];
              final isDigital =
                  resource.digitalAttachmentUrl != null &&
                  resource.digitalAttachmentUrl!.isNotEmpty;

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDigital
                        ? Colors.purple[50]
                        : Colors.blue[50],
                    child: Icon(
                      isDigital ? Icons.cloud_done : Icons.book,
                      color: isDigital ? Colors.purple : Colors.blue,
                    ),
                  ),
                  title: Text(resource.title),
                  subtitle: Text('${resource.author} • ${resource.type.name}'),
                  trailing: isDigital
                      ? IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _openDigitalResource(
                            resource.digitalAttachmentUrl!,
                          ),
                        )
                      : Text('${resource.availableCopies} left'),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> _openDigitalResource(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
