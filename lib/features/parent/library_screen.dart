import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_bloc.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_event.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_state.dart';
import 'package:school_pulse/features/library/domain/entities/library_book.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    if (studentState is SelectedStudentLoaded) {
      context.read<LibraryBloc>().add(FetchBorrowedBooks(studentState.student.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'Library'),
      body: BlocListener<SelectedStudentBloc, SelectedStudentState>(
        listener: (context, state) {
          if (state is SelectedStudentLoaded) {
            context.read<LibraryBloc>().add(FetchBorrowedBooks(state.student.id));
          }
        },
        child: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading || state is LibraryInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LibraryError) {
              return EmptyState(
                icon: Icons.cloud_off,
                title: 'Could not load library records',
                message: state.message,
                ctaLabel: 'Retry',
                onCtaPressed: _fetchData,
              );
            } else if (state is LibraryLoaded) {
              final books = state.books;
              final currentBooks = books.where((b) => !b.isReturned).toList();
              final historyBooks = books.where((b) => b.isReturned).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const FadeInSlide(
                    child: SectionHeader(title: 'Currently Borrowed'),
                  ),
                  if (currentBooks.isEmpty)
                    const FadeInSlide(
                      delay: Duration(milliseconds: 100),
                      child: AppCard(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No books currently borrowed'),
                          ),
                        ),
                      ),
                    )
                  else
                    ...currentBooks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final book = entry.value;
                      return FadeInSlide(
                        delay: Duration(milliseconds: 100 + (index * 100)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildBookCard(context, book),
                        ),
                      );
                    }),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Borrowing History'),
                  ),
                  if (historyBooks.isEmpty)
                    const FadeInSlide(
                      delay: Duration(milliseconds: 400),
                      child: EmptyState(
                        icon: Icons.book_outlined,
                        title: 'No History',
                        message: 'No past borrowing records found.',
                      ),
                    )
                  else
                    ...historyBooks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final book = entry.value;
                      return FadeInSlide(
                        delay: Duration(milliseconds: 400 + (index * 100)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildBookCard(context, book),
                        ),
                      );
                    }),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, LibraryBook book) {
    final isOverdue = !book.isReturned && book.dueDate.isBefore(DateTime.now());
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.menu_book, color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(book.author, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  book.isReturned ? 'Returned' : 'Due: ${DateFormatter.format(book.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOverdue ? semanticColors.error : null,
                        fontWeight: isOverdue ? FontWeight.bold : null,
                      ),
                ),
              ],
            ),
          ),
          if (!book.isReturned)
            StatusBadge(
              label: isOverdue ? 'Overdue' : 'Active',
              color: isOverdue ? semanticColors.error : semanticColors.success,
            ),
        ],
      ),
    );
  }
}
