import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../injection_container.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/presentation/bloc/library_event.dart';
import '../../../library/presentation/bloc/library_state.dart';
import '../../../library/domain/entities/library_borrowing.dart';
import '../../../library/domain/entities/library_resource.dart';
import 'package:school_pulse/design_system/app_components.dart';

class StudentLibraryScreen extends StatefulWidget {
  const StudentLibraryScreen({super.key});

  @override
  State<StudentLibraryScreen> createState() => _StudentLibraryScreenState();
}

class _StudentLibraryScreenState extends State<StudentLibraryScreen>
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
    final studentId = user?.studentId;

    if (studentId == null || user == null) {
      return const Scaffold(
        body: Center(child: Text('Student information not found.')),
      );
    }

    return BlocProvider(
      create: (context) => sl<LibraryBloc>()
        ..add(WatchBorrowingHistory(user.schoolId, borrowerId: studentId))
        ..add(WatchLibraryResources(user.schoolId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('School Library'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Borrowings', icon: Icon(Icons.history_edu)),
              Tab(text: 'Digital Library', icon: Icon(Icons.cloud_download)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _MyBorrowingsTab(studentId: studentId),
            _DigitalLibraryTab(schoolId: user.schoolId),
          ],
        ),
      ),
    );
  }
}

class _MyBorrowingsTab extends StatelessWidget {
  final String studentId;
  const _MyBorrowingsTab({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is LibraryLoading && state is! LibraryHistoryLoaded) {
          return const Center(child: SchoolPulseLoader());
        } else if (state is LibraryHistoryLoaded) {
          final activeBorrowings = state.history
              .where((b) => b.status != BorrowingStatus.returned)
              .toList();

          if (activeBorrowings.isEmpty) {
            return const EmptyState(
              icon: Icons.library_books_outlined,
              title: 'No Active Borrowings',
              message: 'Visit the library to issue resources.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeBorrowings.length,
            itemBuilder: (context, index) {
              final borrowing = activeBorrowings[index];
              final isOverdue =
                  borrowing.status == BorrowingStatus.overdue ||
                  borrowing.dueDate.isBefore(DateTime.now());

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.book)),
                  title: Text(
                    borrowing.resourceTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Issued: ${DateFormat('MMM dd, yyyy').format(borrowing.borrowDate)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Due: ${DateFormat('MMM dd').format(borrowing.dueDate)}',
                        style: TextStyle(
                          color: isOverdue ? Colors.red : Colors.grey[700],
                          fontWeight: isOverdue
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isOverdue)
                        const StatusBadge(label: 'OVERDUE', color: Colors.red),
                    ],
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

class _DigitalLibraryTab extends StatelessWidget {
  final String schoolId;
  const _DigitalLibraryTab({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is LibraryResourcesLoaded) {
          final digitalResources = state.resources
              .where(
                (r) =>
                    r.digitalAttachmentUrl != null &&
                    r.digitalAttachmentUrl!.isNotEmpty,
              )
              .toList();

          if (digitalResources.isEmpty) {
            return const EmptyState(
              icon: Icons.cloud_off,
              title: 'No Digital Resources',
              message: 'Check back later for e-books and study materials.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: digitalResources.length,
            itemBuilder: (context, index) {
              final resource = digitalResources[index];
              return _DigitalResourceCard(resource: resource);
            },
          );
        }
        return const Center(child: SchoolPulseLoader());
      },
    );
  }
}

class _DigitalResourceCard extends StatelessWidget {
  final LibraryResource resource;
  const _DigitalResourceCard({required this.resource});

  Future<void> _openResource() async {
    if (resource.digitalAttachmentUrl != null) {
      final url = Uri.parse(resource.digitalAttachmentUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: _openResource,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: resource.coverImageUrl != null
                  ? Image.network(resource.coverImageUrl!, fit: BoxFit.cover)
                  : Icon(
                      Icons.picture_as_pdf,
                      size: 48,
                      color: Colors.red[400],
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resource.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.download,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Access',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
