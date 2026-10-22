import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_event_type.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../bloc/school_calendar_bloc.dart';
import '../bloc/school_calendar_event.dart';
import '../bloc/school_calendar_state.dart';
import '../widgets/calendar_format.dart';
import '../widgets/event_card.dart';
import '../widgets/event_type_colors.dart';
import '../widgets/month_calendar_grid.dart';
import 'add_event_flow/add_event_screen.dart';
import 'day_events_screen.dart';
import 'event_details_screen.dart';
import 'filters_sheet.dart';

enum _ViewMode { calendar, list }

/// Canonical School Calendar screen: Calendar View / List View toggle, month
/// grid with colored event dots, legend covering all 9 event types,
/// search + filters (persisted across the two views), and the Add Event CTA.
class CalendarOverviewScreen extends StatefulWidget {
  /// Parent-facing calendar is intentionally view-only. Calendar management
  /// remains available through the staff/admin calendar workflow.
  final bool readOnly;

  const CalendarOverviewScreen({super.key, this.readOnly = true});
  @override
  State<CalendarOverviewScreen> createState() => _CalendarOverviewScreenState();
}

class _CalendarOverviewScreenState extends State<CalendarOverviewScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  _ViewMode _mode = _ViewMode.calendar;
  CalendarFilters _filters = const CalendarFilters();

  List<CalendarEvent> _visible(List<CalendarEvent> events) => events.where((
    event,
  ) {
    final text =
        '${event.title} ${event.description} ${event.location} ${event.organizer}'
            .toLowerCase();
    final matchesText =
        _filters.search.isEmpty || text.contains(_filters.search.toLowerCase());
    final matchesType =
        _filters.types.isEmpty || _filters.types.contains(event.type);
    final matchesAudience =
        _filters.audience == null || event.audience.kind == _filters.audience;
    final matchesFrom =
        _filters.from == null || !event.endDate.isBefore(_filters.from!);
    final matchesTo =
        _filters.to == null || !event.startDate.isAfter(_filters.to!);
    return matchesText &&
        matchesType &&
        matchesAudience &&
        matchesFrom &&
        matchesTo;
  }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

  void _openAdd({DateTime? date, CalendarEvent? edit}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SchoolCalendarBloc>(),
          child: AddEventScreen(initialDate: date, editing: edit),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('School Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_filters.isEmpty ? Icons.tune_outlined : Icons.tune),
            onPressed: _showFilters,
          ),
          const NotificationBellButton(),
        ],
      ),
      body: BlocBuilder<SchoolCalendarBloc, SchoolCalendarState>(
        builder: (context, state) {
          if (state is SchoolCalendarLoading ||
              state is SchoolCalendarInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SchoolCalendarError) {
            return Center(child: Text(state.message));
          }
          if (state is! SchoolCalendarLoaded) return const SizedBox();
          final events = _visible(state.events);
          final canManage = state.canManage && !widget.readOnly;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: _Toggle(
                        mode: _mode,
                        onChanged: (mode) => setState(() => _mode = mode),
                      ),
                    ),
                    Expanded(
                      child: _mode == _ViewMode.calendar
                          ? _calendar(events, canManage)
                          : _list(events, canManage),
                    ),
                    if (canManage)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _openAdd,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Event'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _calendar(
    List<CalendarEvent> events,
    bool canManage,
  ) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    monthLabel(_month),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              MonthCalendarGrid(
                month: _month,
                events: events,
                onDayTap: (day) {
                  final dayEvents = events
                      .where(
                        (event) =>
                            isSameDay(event.startDate, day) ||
                            (event.startDate.isBefore(day) &&
                                event.endDate.isAfter(day)),
                      )
                      .toList();
                  if (dayEvents.isNotEmpty) {
                    _showDay(day, dayEvents, canManage);
                  } else if (canManage) {
                    _openAdd(date: day);
                  }
                },
              ),
            ],
          ),
        ),
        if (events
            .where(
              (event) =>
                  event.startDate.year == _month.year &&
                  event.startDate.month == _month.month,
            )
            .isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 28,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'No events this month',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        if (events.isNotEmpty) ...[const SizedBox(height: 20), const _Legend()],
      ],
    ),
  );

  Widget _list(List<CalendarEvent> events, bool canManage) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: TextField(
          controller: TextEditingController(text: _filters.search)
            ..selection = TextSelection.collapsed(
              offset: _filters.search.length,
            ),
          onChanged: (value) =>
              setState(() => _filters = _filters.copyWith(search: value)),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search events...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showFilters,
            ),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      Expanded(
        child: events.isEmpty
            ? Center(
                child: Text(
                  _filters.isEmpty
                      ? 'No events scheduled'
                      : 'No matching events found',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: events.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) => EventCard(
                  event: events[index],
                  onTap: () => _showDetails(events[index], canManage),
                ),
              ),
      ),
    ],
  );

  void _showDay(DateTime day, List<CalendarEvent> events, bool canManage) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DayEventsScreen(
            day: day,
            events: events,
            canManage: canManage,
            onAdd: () => _openAdd(date: day),
            onOpen: (event) => _showDetails(event, canManage),
          ),
        ),
      );

  void _showDetails(CalendarEvent event, bool canManage) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventDetailsScreen(
            event: event,
            canManage: canManage,
            onEdit: () => _openAdd(edit: event),
            onDelete: (scope) => _delete(event, scope),
          ),
        ),
      );

  Future<void> _delete(CalendarEvent event, RecurrenceEditScope scope) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || !mounted) return;
    context.read<SchoolCalendarBloc>().add(
      DeleteCalendarEventRequested(
        schoolId: event.schoolId,
        eventId: event.id,
        operatorUser: auth.user,
        scope: scope,
      ),
    );
    await sl<AuditRepository>().logAction(
      schoolId: event.schoolId,
      title: 'Calendar event deleted',
      description: event.title,
      iconName: 'calendar_month',
      colorHex: event.colorHex,
      userId: auth.user.id,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _showFilters() async {
    final result = await showModalBottomSheet<CalendarFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterSheet(initial: _filters),
    );
    if (result != null) setState(() => _filters = result);
  }
}

class _Toggle extends StatelessWidget {
  final _ViewMode mode;
  final ValueChanged<_ViewMode> onChanged;
  const _Toggle({required this.mode, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tab(context, 'Calendar View', _ViewMode.calendar),
          _tab(context, 'List View', _ViewMode.list),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String label, _ViewMode target) => Expanded(
    child: InkWell(
      onTap: () => onChanged(target),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: mode == target
              ? AppColors.primary(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: mode == target ? Colors.white : AppColors.textMuted(context),
          ),
        ),
      ),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    children: calendarEventTypeLegendOrder
        .map((type) => _LegendItem(type.label, calendarEventTypeColor(type)))
        .toList(),
  );
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
      ),
    ],
  );
}
