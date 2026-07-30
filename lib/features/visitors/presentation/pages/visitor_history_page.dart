import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/visitor.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_state.dart';
import 'visitor_details_screen.dart';

enum _StatusFilter { all, checkedIn, checkedOut }

class VisitorHistoryPage extends StatefulWidget {
  const VisitorHistoryPage({super.key});

  @override
  State<VisitorHistoryPage> createState() => _VisitorHistoryPageState();
}

class _VisitorHistoryPageState extends State<VisitorHistoryPage> {
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  VisitorCategory? _category;
  _StatusFilter _status = _StatusFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  List<Visitor> _applyFilters(List<Visitor> visitors) {
    var result = visitors;

    if (_dateRange != null) {
      final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
      final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day, 23, 59, 59);
      result = result.where((v) => v.arrivalTime.isAfter(start) && v.arrivalTime.isBefore(end)).toList();
    }

    if (_category != null) {
      result = result.where((v) => v.category == _category).toList();
    }

    if (_status == _StatusFilter.checkedIn) {
      result = result.where((v) => v.status == VisitorStatus.checkedIn).toList();
    } else if (_status == _StatusFilter.checkedOut) {
      result = result.where((v) => v.status == VisitorStatus.checkedOut).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((v) =>
          v.fullName.toLowerCase().contains(query) ||
          v.phone.contains(query) ||
          v.host.toLowerCase().contains(query) ||
          (v.company?.toLowerCase().contains(query) ?? false)).toList();
    }

    result = List<Visitor>.from(result)..sort((a, b) => b.arrivalTime.compareTo(a.arrivalTime));
    return result;
  }

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _category = null;
      _status = _StatusFilter.all;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Visitor History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off_outlined),
            tooltip: 'Clear filters',
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: BlocBuilder<VisitorsBloc, VisitorsState>(
        builder: (context, state) {
          if (state is VisitorsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! VisitorsLoaded) {
            return const Center(child: Text('Unable to load visitor history'));
          }

          final filtered = _applyFilters(state.visitors);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search name, phone, host, company...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(_dateRange == null
                            ? 'Date Range'
                            : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'),
                        selected: _dateRange != null,
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        onSelected: (_) => _pickDateRange(),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<VisitorCategory?>(
                        value: _category,
                        hint: const Text('Category'),
                        underline: const SizedBox.shrink(),
                        items: [
                          const DropdownMenuItem<VisitorCategory?>(value: null, child: Text('All Categories')),
                          ...VisitorCategory.values.map(
                            (c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase())),
                          ),
                        ],
                        onChanged: (v) => setState(() => _category = v),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<_StatusFilter>(
                        value: _status,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: _StatusFilter.all, child: Text('All Statuses')),
                          DropdownMenuItem(value: _StatusFilter.checkedIn, child: Text('Currently Inside')),
                          DropdownMenuItem(value: _StatusFilter.checkedOut, child: Text('Checked Out')),
                        ],
                        onChanged: (v) => setState(() => _status = v ?? _StatusFilter.all),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filtered.length} record(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No visitor records match these filters'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final visitor = filtered[index];
                          return AppCard(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VisitorDetailsScreen(visitor: visitor)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    visitor.status == VisitorStatus.checkedIn ? Colors.green : Colors.grey,
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(visitor.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${visitor.purpose} • ${visitor.host}\n'
                                '${DateFormat('MMM dd, yyyy hh:mm a').format(visitor.arrivalTime)}'
                                '${visitor.departureTime != null ? ' → ${DateFormat('hh:mm a').format(visitor.departureTime!)}' : ''}',
                              ),
                              isThreeLine: true,
                              trailing: StatusBadge(
                                label: visitor.status == VisitorStatus.checkedIn ? 'INSIDE' : 'OUT',
                                color: visitor.status == VisitorStatus.checkedIn ? Colors.green : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
