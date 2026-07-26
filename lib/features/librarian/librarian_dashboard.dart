import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/library/domain/entities/library_book.dart';
import 'package:school_pulse/features/library/domain/usecases/get_all_borrowed_books.dart';
import 'package:school_pulse/features/library/domain/usecases/issue_book.dart';
import 'package:school_pulse/features/library/domain/usecases/return_book.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class _LibrarySnapshot {
  final List<Student> students;
  final List<LibraryBook> books;

  const _LibrarySnapshot({required this.students, required this.books});
}

class LibrarianDashboardScreen extends StatefulWidget {
  const LibrarianDashboardScreen({super.key});

  @override
  State<LibrarianDashboardScreen> createState() => _LibrarianDashboardScreenState();
}

class _LibrarianDashboardScreenState extends State<LibrarianDashboardScreen> {
  late Future<_LibrarySnapshot> _snapshotFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
  }

  void _reload() {
    setState(() => _snapshotFuture = _loadSnapshot());
  }

  Future<_LibrarySnapshot> _loadSnapshot() async {
    final results = await Future.wait([
      di.sl<GetAllStudents>()().then((r) => r.getOrElse(() => const <Student>[])),
      di.sl<GetAllBorrowedBooks>()().then((r) => r.getOrElse(() => const <LibraryBook>[])),
    ]);
    return _LibrarySnapshot(
      students: results[0] as List<Student>,
      books: results[1] as List<LibraryBook>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Portal'),
        actions: [
          const NotificationBellButton(),
        ],
      ),
      body: FutureBuilder<_LibrarySnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final studentsById = {for (final s in data?.students ?? const <Student>[]) s.id: s};
          final books = data?.books ?? const <LibraryBook>[];
          final overdue = books.where((b) => !b.isReturned && b.dueDate.isBefore(DateTime.now())).where((b) {
            if (_searchQuery.isEmpty) return true;
            final student = studentsById[b.studentId];
            final haystack = '${b.title} ${b.author} ${student?.name ?? ''}'.toLowerCase();
            return haystack.contains(_searchQuery.toLowerCase());
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isLoading)
                const Row(
                  children: [
                    Expanded(child: Skeleton(height: 100)),
                    SizedBox(width: 12),
                    Expanded(child: Skeleton(height: 100)),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Currently Issued',
                        value: books.where((b) => !b.isReturned).length.toDouble(),
                        icon: Icons.upload_file,
                        color: semanticColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Overdue Total',
                        value: books.where((b) => !b.isReturned && b.dueDate.isBefore(DateTime.now())).length.toDouble(),
                        icon: Icons.running_with_errors,
                        color: semanticColors.error,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Quick Actions'),
              QuickActionGrid(
                items: [
                  QuickActionItem(
                    label: 'Issue',
                    icon: Icons.outbox,
                    color: semanticColors.info,
                    onTap: () => _showIssueBookDialog(context, data),
                  ),
                  QuickActionItem(
                    label: 'Return',
                    icon: Icons.move_to_inbox,
                    color: semanticColors.success,
                    onTap: () => _showReturnBookSheet(context, data),
                  ),
                  QuickActionItem(
                    label: 'Inventory',
                    icon: Icons.inventory_2_outlined,
                    color: semanticColors.warning,
                    onTap: () => _showInventorySheet(context, data),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search overdue books by title, author, or student...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Overdue Books'),
              if (isLoading)
                ...List.generate(3, (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Skeleton(height: 100),
                ))
              else if (overdue.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No overdue books.')),
                )
              else
                ...overdue.map((book) {
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
      ),
    );
  }

  void _showIssueBookDialog(BuildContext context, _LibrarySnapshot? data) {
    final students = data?.students ?? const <Student>[];
    if (students.isEmpty) return;

    final titleController = TextEditingController();
    final authorController = TextEditingController();
    String selectedStudentId = students.first.id;
    DateTime dueDate = DateTime.now().add(const Duration(days: 14));

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Issue Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedStudentId,
                decoration: const InputDecoration(labelText: 'Student'),
                items: students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (value) => setDialogState(() => selectedStudentId = value ?? selectedStudentId),
              ),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Book Title')),
              const SizedBox(height: 16),
              TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Author')),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date'),
                subtitle: Text(DateFormatter.format(dueDate)),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 180)),
                  );
                  if (picked != null) setDialogState(() => dueDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await di.sl<IssueBook>()(LibraryBook(
                  id: '',
                  studentId: selectedStudentId,
                  title: titleController.text.trim(),
                  author: authorController.text.trim().isEmpty ? 'Unknown' : authorController.text.trim(),
                  dueDate: dueDate,
                ));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _reload();
              },
              child: const Text('Issue'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnBookSheet(BuildContext context, _LibrarySnapshot? data) {
    final books = data?.books.where((b) => !b.isReturned).toList() ?? [];
    final studentsById = {for (final s in data?.students ?? const <Student>[]) s.id: s};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (sheetContext, scrollController) {
          if (books.isEmpty) {
            return const Center(child: Text('No books currently issued.'));
          }
          return ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final book = books[index];
              final studentName = studentsById[book.studentId]?.name ?? 'Unknown Student';
              return ListTile(
                title: Text(book.title),
                subtitle: Text('Held by $studentName'),
                trailing: FilledButton(
                  onPressed: () async {
                    await di.sl<ReturnBook>()(book.id);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                    _reload();
                  },
                  child: const Text('Return'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showInventorySheet(BuildContext context, _LibrarySnapshot? data) {
    final books = data?.books ?? const <LibraryBook>[];
    final studentsById = {for (final s in data?.students ?? const <Student>[]) s.id: s};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (sheetContext, scrollController) {
          if (books.isEmpty) {
            return const Center(child: Text('No library records yet.'));
          }
          return ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final book = books[index];
              final studentName = studentsById[book.studentId]?.name ?? 'Unknown Student';
              return ListTile(
                title: Text(book.title),
                subtitle: Text('By ${book.author} • $studentName'),
                trailing: StatusBadge(
                  label: book.isReturned ? 'Returned' : 'Issued',
                  color: book.isReturned ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.primary,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
