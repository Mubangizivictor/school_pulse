import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/screens/library_settings_screen.dart';
import 'package:school_pulse/features/library/presentation/screens/issue_resource_screen.dart';
import 'package:school_pulse/features/library/presentation/widgets/reading_trends_chart.dart';
import 'package:school_pulse/core/services/printer/printer_service.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../../domain/entities/library_borrowing.dart';
import '../../domain/entities/library_resource.dart';

class LibraryDashboardScreen extends StatefulWidget {
  final String schoolId;
  const LibraryDashboardScreen({super.key, required this.schoolId});

  @override
  State<LibraryDashboardScreen> createState() => _LibraryDashboardScreenState();
}

class _LibraryDashboardScreenState extends State<LibraryDashboardScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(WatchLibraryResources(widget.schoolId));
    context.read<LibraryBloc>().add(WatchBorrowingHistory(widget.schoolId));
    context.read<LibraryBloc>().add(FetchLibraryStats(widget.schoolId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: staffDashboardAppBar(context, roleLabel: 'Librarian'),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading && state is! LibraryHistoryLoaded) {
            return const Center(child: SchoolPulseLoader());
          }

          List<LibraryBorrowing> borrowings = [];
          if (state is LibraryHistoryLoaded) {
            borrowings = state.history
                .cast<LibraryBorrowing>()
                .where((b) => b.status != BorrowingStatus.returned)
                .where(
                  (b) =>
                      b.resourceTitle.toLowerCase().contains(_searchQuery) ||
                      b.borrowerName.toLowerCase().contains(_searchQuery),
                )
                .toList();
          }

          Map<String, dynamic>? stats;
          if (state is LibraryStatsLoaded) {
            stats = state.stats;
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<LibraryBloc>().add(
                WatchLibraryResources(widget.schoolId),
              );
              context.read<LibraryBloc>().add(
                WatchBorrowingHistory(widget.schoolId),
              );
              context.read<LibraryBloc>().add(
                FetchLibraryStats(widget.schoolId),
              );
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                StaffHeroSummaryCard(
                  greetingNameFallback: 'Librarian',
                  kpis: stats == null
                      ? null
                      : [
                          StaffKpiData(
                            title: 'Total Resources',
                            valueText: '${stats['totalBooks'] ?? 0}',
                            subtitle: 'In collection',
                            icon: Icons.library_books_outlined,
                            color: AppColors.information(context),
                          ),
                          StaffKpiData(
                            title: 'Issued',
                            valueText: '${stats['borrowedBooks'] ?? 0}',
                            subtitle: 'Currently out',
                            icon: Icons.book_outlined,
                            color: AppColors.success(context),
                          ),
                          StaffKpiData(
                            title: 'Overdue',
                            valueText: '${stats['overdueBooks'] ?? 0}',
                            subtitle: 'Needs follow-up',
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.danger(context),
                          ),
                          StaffKpiData(
                            title: 'Active Loans',
                            valueText: '${borrowings.length}',
                            subtitle: 'Not yet returned',
                            icon: Icons.assignment_return_outlined,
                            color: AppColors.warning(context),
                          ),
                        ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search resources or borrowers...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value.toLowerCase()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                      ),
                      onPressed: () => _showPolicySettings(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (stats != null) ...[
                  const SectionHeader(title: 'Borrowing Trends'),
                  const SizedBox(height: 12),
                  ReadingTrendsChart(
                    monthlyData: Map<String, int>.from(
                      stats['monthlyTrends'] ?? {},
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionHeader(title: 'Active Borrowings'),
                    TextButton.icon(
                      onPressed: () => _showResourceInventory(context),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Inventory & Labels'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (borrowings.isNotEmpty)
                  ...borrowings.map(
                    (borrowing) => _BorrowingCard(
                      borrowing: borrowing,
                      onReturn: () => _showReturnDialog(context, borrowing),
                    ),
                  )
                else if (state is LibraryHistoryLoaded)
                  const EmptyState(
                    icon: Icons.library_books_outlined,
                    title: 'No Borrowings Found',
                    message: 'Try a different search or issue a new resource.',
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIssueResourceDialog(context),
        label: const Text('Issue Resource'),
        icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  void _showReturnDialog(BuildContext context, LibraryBorrowing borrowing) {
    showDialog(
      context: context,
      builder: (context) => _ReturnResourceDialog(
        borrowing: borrowing,
        onConfirm: (condition, fine) {
          context.read<LibraryBloc>().add(
            ReturnResourceRequested(
              borrowingId: borrowing.id,
              schoolId: widget.schoolId,
              condition: condition,
              fineAmount: fine,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showIssueResourceDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IssueResourceScreen(schoolId: widget.schoolId),
      ),
    );
  }

  void _showPolicySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LibrarySettingsScreen()),
    );
  }

  void _showResourceInventory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ResourceInventorySheet(schoolId: widget.schoolId),
    );
  }
}

class _ResourceInventorySheet extends StatefulWidget {
  final String schoolId;
  const _ResourceInventorySheet({required this.schoolId});

  @override
  State<_ResourceInventorySheet> createState() =>
      _ResourceInventorySheetState();
}

class _ResourceInventorySheetState extends State<_ResourceInventorySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Filter resources...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => setState(() => _query = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state is LibraryResourcesLoaded) {
                  final filtered = state.resources
                      .where(
                        (r) =>
                            r.title.toLowerCase().contains(_query) ||
                            r.barcode.contains(_query),
                      )
                      .toList();

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final resource = filtered[index];
                      return ListTile(
                        leading: const Icon(Icons.qr_code_2),
                        title: Text(resource.title),
                        subtitle: Text(
                          'Barcode: ${resource.barcode} | Shelf: ${resource.shelf}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.print_outlined),
                          tooltip: 'Print QR Label',
                          onPressed: () => _printLabel(context, resource),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: SchoolPulseLoader());
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printLabel(
    BuildContext context,
    LibraryResource resource,
  ) async {
    final printerService = di.sl<PrinterService>();
    final isConnected = await printerService.isConnected();

    if (!isConnected) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Printer not connected'),
            action: SnackBarAction(
              label: 'Connect',
              onPressed: () {
                // Navigate to printer settings if available or show discovery
              },
            ),
          ),
        );
      }
      return;
    }

    final success = await printerService.printLibraryLabel(resource);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Label printed' : 'Print failed')),
      );
    }
  }
}

class _BorrowingCard extends StatelessWidget {
  final LibraryBorrowing borrowing;
  final VoidCallback onReturn;

  const _BorrowingCard({required this.borrowing, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final isOverdue =
        borrowing.dueDate.isBefore(DateTime.now()) &&
        borrowing.status != BorrowingStatus.returned;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          borrowing.resourceTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Borrower: ${borrowing.borrowerName} (${borrowing.borrowerType})',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatusBadge(
              label: isOverdue ? 'OVERDUE' : 'ACTIVE',
              color: isOverdue ? semanticColors.error : semanticColors.info,
            ),
            const SizedBox(height: 4),
            Text(
              'Due: ${borrowing.dueDate.toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: onReturn,
      ),
    );
  }
}

class _ReturnResourceDialog extends StatefulWidget {
  final LibraryBorrowing borrowing;
  final Function(ResourceCondition, double) onConfirm;

  const _ReturnResourceDialog({
    required this.borrowing,
    required this.onConfirm,
  });

  @override
  State<_ReturnResourceDialog> createState() => _ReturnResourceDialogState();
}

class _ReturnResourceDialogState extends State<_ReturnResourceDialog> {
  ResourceCondition _condition = ResourceCondition.good;
  final _fineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-calculate fine if overdue
    if (widget.borrowing.dueDate.isBefore(DateTime.now())) {
      final daysOverdue = DateTime.now()
          .difference(widget.borrowing.dueDate)
          .inDays;
      if (daysOverdue > 0) {
        _fineController.text = (daysOverdue * 500)
            .toString(); // Example: 500 per day
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Return: ${widget.borrowing.resourceTitle}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ResourceCondition>(
            initialValue: _condition,
            decoration: const InputDecoration(labelText: 'Condition on Return'),
            items: ResourceCondition.values
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _condition = val!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fineController,
            decoration: const InputDecoration(
              labelText: 'Fine Amount',
              prefixText: 'UGX ',
            ),
            keyboardType: TextInputType.number,
          ),
          if (_condition == ResourceCondition.damaged ||
              _condition == ResourceCondition.poor)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Note: Damaged condition will automatically trigger a repair request in Stores & Assets.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => widget.onConfirm(
            _condition,
            double.tryParse(_fineController.text) ?? 0,
          ),
          child: const Text('Confirm Return'),
        ),
      ],
    );
  }
}
