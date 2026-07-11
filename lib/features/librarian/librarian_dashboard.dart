import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_bloc.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_state.dart';

class LibrarianDashboardScreen extends StatelessWidget {
  const LibrarianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Portal'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: di.sl<GetAllStudents>()().then((r) => r.getOrElse(() => const [])),
        builder: (context, studentsSnapshot) {
          final studentsById = {for (final s in studentsSnapshot.data ?? const <Student>[]) s.id: s};
          return BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildLibraryStats(context, semanticColors, state),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Quick Actions'),
              QuickActionGrid(
                items: [
                  QuickActionItem(
                    label: 'Issue',
                    icon: Icons.outbox,
                    color: semanticColors.info,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Return',
                    icon: Icons.move_to_inbox,
                    color: semanticColors.success,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Inventory',
                    icon: Icons.inventory_2_outlined,
                    color: semanticColors.warning,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Search',
                    icon: Icons.search,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Overdue Books'),
              if (state is LibraryLoading)
                ...List.generate(3, (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Skeleton(height: 100),
                ))
              else if (state is LibraryLoaded)
                ...state.books.where((b) => !b.isReturned && b.dueDate.isBefore(DateTime.now())).map((book) {
                  final student = studentsById[book.studentId];
                  final studentName = student?.name ?? 'Unknown Student';
                  final studentClass = student?.className ?? '';
                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: semanticColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.auto_stories, color: semanticColors.error, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('By ${book.author}', style: Theme.of(context).textTheme.labelSmall),
                              const SizedBox(height: 4),
                              Text(
                                'Held by: $studentName ($studentClass)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Overdue',
                              style: TextStyle(color: semanticColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormatter.relative(book.dueDate),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
            },
          );
        },
      ),
    );
  }

  Widget _buildLibraryStats(BuildContext context, SemanticColors colors, LibraryState state) {
    if (state is LibraryLoading) {
      return const Row(
        children: [
          Expanded(child: Skeleton(height: 100)),
          SizedBox(width: 12),
          Expanded(child: Skeleton(height: 100)),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            title: 'Issued Today',
            value: 24,
            icon: Icons.upload_file,
            color: colors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            title: 'Overdue Total',
            value: 15,
            icon: Icons.running_with_errors,
            color: colors.error,
          ),
        ),
      ],
    );
  }
}
