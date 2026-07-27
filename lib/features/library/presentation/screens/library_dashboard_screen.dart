import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';

class LibraryDashboardScreen extends StatefulWidget {
  const LibraryDashboardScreen({super.key});

  @override
  State<LibraryDashboardScreen> createState() => _LibraryDashboardScreenState();
}

class _LibraryDashboardScreenState extends State<LibraryDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(LoadLibraryBooks());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBookDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LibraryError) {
            return Center(child: Text(state.message));
          }

          if (state is LibraryLoaded) {
            final overdueBooks = state.books.where((b) => !b.isReturned && b.dueDate.isBefore(DateTime.now())).toList();
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LibraryBloc>().add(LoadLibraryBooks());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _LibraryStats(
                    totalBooks: state.books.length,
                    overdueCount: overdueBooks.length,
                    issuedCount: state.books.where((b) => !b.isReturned).length,
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Recent Issues'),
                  const SizedBox(height: 12),
                  ...state.books.map((book) => AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Author: ${book.author}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(
                            label: book.isReturned ? 'Returned' : (book.dueDate.isBefore(DateTime.now()) ? 'Overdue' : 'Issued'),
                            color: book.isReturned 
                                ? semanticColors.success 
                                : (book.dueDate.isBefore(DateTime.now()) ? semanticColors.error : semanticColors.warning),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due: ${book.dueDate.toString().split(' ')[0]}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      onTap: () => _showBookDetails(context, book),
                    ),
                  )),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    // Implementation for adding a new book record
  }

  void _showBookDetails(BuildContext context, dynamic book) {
    // Implementation for showing details and returning book
  }
}

class _LibraryStats extends StatelessWidget {
  final int totalBooks;
  final int overdueCount;
  final int issuedCount;

  const _LibraryStats({
    required this.totalBooks,
    required this.overdueCount,
    required this.issuedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            title: 'Issued',
            value: issuedCount.toDouble(),
            icon: Icons.book_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            title: 'Overdue',
            value: overdueCount.toDouble(),
            icon: Icons.warning_amber_rounded,
            color: Theme.of(context).extension<SemanticColors>()!.error,
          ),
        ),
      ],
    );
  }
}
