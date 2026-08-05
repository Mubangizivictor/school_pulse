import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/school_calendar_bloc.dart';
import '../bloc/school_calendar_state.dart';
import '../widgets/event_type_colors.dart';
import '../widgets/month_calendar_grid.dart';
import 'add_event_flow/add_event_screen.dart';

enum _ViewMode { calendar, list }

class CalendarOverviewScreen extends StatefulWidget {
  const CalendarOverviewScreen({super.key});

  @override
  State<CalendarOverviewScreen> createState() =>
      _CalendarOverviewScreenState();
}

class _CalendarOverviewScreenState extends State<CalendarOverviewScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  _ViewMode _mode = _ViewMode.calendar;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('School Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<SchoolCalendarBloc, SchoolCalendarState>(
        builder: (context, state) {
          final events = state is SchoolCalendarLoaded ? state.events : [];
          final canManage = state is SchoolCalendarLoaded && state.canManage;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.m,
                ),
                child: _ViewToggle(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ),
              if (_mode == _ViewMode.calendar) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(
                          () => _month = DateTime(_month.year, _month.month - 1),
                        ),
                      ),
                      Text(
                        '${_monthNames[_month.month - 1]} ${_month.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(
                          () => _month = DateTime(_month.year, _month.month + 1),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        MonthCalendarGrid(
                          month: _month,
                          events: List.from(events),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const _CalendarLegend(),
                      ],
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final e = events[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.m),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: calendarEventTypeColor(e.type),
                              ),
                            ),
                            title: Text(e.title),
                            subtitle: Text(e.type.label),
                            trailing: Text(
                              '${e.startDate.day}/${e.startDate.month}/${e.startDate.year}',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (canManage)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: user == null
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<SchoolCalendarBloc>(),
                                  child: const AddEventScreen(),
                                ),
                              ),
                            ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Event'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final _ViewMode mode;
  final ValueChanged<_ViewMode> onChanged;

  const _ViewToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleTab(
              label: 'Calendar View',
              selected: mode == _ViewMode.calendar,
              onTap: () => onChanged(_ViewMode.calendar),
            ),
          ),
          Expanded(
            child: _ToggleTab(
              label: 'List View',
              selected: mode == _ViewMode.list,
              onTap: () => onChanged(_ViewMode.list),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textMuted(context),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: const [
        _LegendItem(label: 'School Day', color: Color(0xFF4CAF50)),
        _LegendItem(label: 'Event', color: Color(0xFF2196F3)),
        _LegendItem(label: 'Holiday', color: Color(0xFFE53935)),
        _LegendItem(label: 'Break', color: Color(0xFFFF9800)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
        ),
      ],
    );
  }
}
