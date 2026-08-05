import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_bloc.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_event.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_state.dart';
import 'package:school_pulse/features/library/domain/entities/library_borrowing.dart';
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
    final authState = context.read<AuthBloc>().state;
    if (studentState is SelectedStudentLoaded &&
        authState is AuthAuthenticated) {
      context.read<LibraryBloc>().add(
        WatchBorrowingHistory(
          authState.user.schoolId,
          borrowerId: studentState.student.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'Library'),
      body: BlocListener<SelectedStudentBloc, SelectedStudentState>(
        listener: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (state is SelectedStudentLoaded &&
              authState is AuthAuthenticated) {
            context.read<LibraryBloc>().add(
              WatchBorrowingHistory(
                authState.user.schoolId,
                borrowerId: state.student.id,
              ),
            );
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
            } else if (state is LibraryHistoryLoaded) {
              final borrowings = state.history;
              final currentBorrowings = borrowings
                  .where(
                    (b) =>
                        b.status == BorrowingStatus.active ||
                        b.status == BorrowingStatus.overdue,
                  )
                  .toList();
              final historyBorrowings = borrowings
                  .where((b) => b.status == BorrowingStatus.returned)
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const FadeInSlide(
                    child: SectionHeader(title: 'Currently Borrowed'),
                  ),
                  if (currentBorrowings.isEmpty)
                    const FadeInSlide(
                      delay: Duration(milliseconds: 100),
                      child: AppCard(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No resources currently borrowed'),
                          ),
                        ),
                      ),
                    )
                  else
                    ...currentBorrowings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final borrowing = entry.value;
                      return FadeInSlide(
                        delay: Duration(milliseconds: 100 + (index * 100)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildBorrowingCard(context, borrowing),
                        ),
                      );
                    }),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Borrowing History'),
                  ),
                  if (historyBorrowings.isEmpty)
                    const FadeInSlide(
                      delay: Duration(milliseconds: 400),
                      child: EmptyState(
                        icon: Icons.book_outlined,
                        title: 'No History',
                        message: 'No past borrowing records found.',
                      ),
                    )
                  else
                    ...historyBorrowings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final borrowing = entry.value;
                      return FadeInSlide(
                        delay: Duration(milliseconds: 400 + (index * 100)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildBorrowingCard(context, borrowing),
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

  Widget _buildBorrowingCard(BuildContext context, LibraryBorrowing borrowing) {
    final isOverdue =
        borrowing.status == BorrowingStatus.overdue ||
        (borrowing.status == BorrowingStatus.active &&
            borrowing.dueDate.isBefore(DateTime.now()));
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
            child: Icon(
              Icons.menu_book,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  borrowing.resourceTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Borrowed: ${DateFormatter.format(borrowing.borrowDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  borrowing.status == BorrowingStatus.returned
                      ? 'Returned'
                      : 'Due: ${DateFormatter.format(borrowing.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOverdue ? semanticColors.error : null,
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
          ),
          if (borrowing.status != BorrowingStatus.returned)
            StatusBadge(
              label: isOverdue ? 'Overdue' : 'Active',
              color: isOverdue ? semanticColors.error : semanticColors.success,
            ),
        ],
      ),
    );
  }
}
