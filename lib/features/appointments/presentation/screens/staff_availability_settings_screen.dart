import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/staff_availability.dart';
import '../bloc/appointment_settings_bloc.dart';
import '../bloc/appointment_settings_event.dart';
import '../bloc/appointment_settings_state.dart';

const _weekdayLabels = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};

class StaffAvailabilitySettingsScreen extends StatelessWidget {
  const StaffAvailabilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final staffId = authState is AuthAuthenticated ? authState.user.id : '';
    final schoolId = authState is AuthAuthenticated ? authState.user.schoolId : '';

    return BlocProvider(
      create: (_) => di.sl<AppointmentSettingsBloc>()..add(LoadStaffAvailabilityEvent(staffId, schoolId)),
      child: const _AvailabilityView(),
    );
  }
}

class _AvailabilityView extends StatefulWidget {
  const _AvailabilityView();

  @override
  State<_AvailabilityView> createState() => _AvailabilityViewState();
}

class _AvailabilityViewState extends State<_AvailabilityView> {
  Set<int> _workingDays = {1, 2, 3, 4, 5};
  int _startMinute = 8 * 60;
  int _endMinute = 16 * 60;
  int _slotDuration = 20;
  int _maxPerDay = 12;
  bool _initialized = false;

  String _formatMinutes(int minute) {
    final time = TimeOfDay(hour: minute ~/ 60, minute: minute % 60);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = TimeOfDay(hour: (isStart ? _startMinute : _endMinute) ~/ 60, minute: (isStart ? _startMinute : _endMinute) % 60);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      final minutes = picked.hour * 60 + picked.minute;
      if (isStart) {
        _startMinute = minutes;
      } else {
        _endMinute = minutes;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final staffId = authState is AuthAuthenticated ? authState.user.id : '';
    final schoolId = authState is AuthAuthenticated ? authState.user.schoolId : '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(title: const Text('Availability Settings')),
      body: BlocConsumer<AppointmentSettingsBloc, AppointmentSettingsState>(
        listener: (context, state) {
          if (state is AppointmentSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is AppointmentSettingsLoaded && state.availability != null && !_initialized) {
            final a = state.availability!;
            setState(() {
              _workingDays = a.workingDays;
              _startMinute = a.startMinuteOfDay;
              _endMinute = a.endMinuteOfDay;
              _slotDuration = a.slotDurationMinutes;
              _maxPerDay = a.maxAppointmentsPerDay;
              _initialized = true;
            });
          }
        },
        builder: (context, state) {
          if (state is! AppointmentSettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader(title: 'Working Days'),
              AppCard(
                child: Wrap(
                  spacing: 8,
                  children: _weekdayLabels.entries.map((entry) {
                    final selected = _workingDays.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _workingDays.add(entry.key);
                        } else {
                          _workingDays.remove(entry.key);
                        }
                      }),
                    );
                  }).toList(),
                ),
              ),
              const SectionHeader(title: 'Working Hours'),
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(true),
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Start'),
                          child: Text(_formatMinutes(_startMinute)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(false),
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'End'),
                          child: Text(_formatMinutes(_endMinute)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Meeting Duration'),
              AppCard(
                child: DropdownButtonFormField<int>(
                  initialValue: _slotDuration,
                  decoration: const InputDecoration(labelText: 'Default appointment length'),
                  items: const [15, 20, 30, 45, 60]
                      .map((m) => DropdownMenuItem(value: m, child: Text('$m minutes')))
                      .toList(),
                  onChanged: (v) => setState(() => _slotDuration = v ?? _slotDuration),
                ),
              ),
              const SectionHeader(title: 'Daily Limit'),
              AppCard(
                child: Row(
                  children: [
                    const Expanded(child: Text('Maximum appointments per day')),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setState(() => _maxPerDay = (_maxPerDay - 1).clamp(1, 50)),
                    ),
                    Text('$_maxPerDay', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _maxPerDay = (_maxPerDay + 1).clamp(1, 50)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save Availability',
                onPressed: () {
                  context.read<AppointmentSettingsBloc>().add(SaveStaffAvailabilityEvent(StaffAvailability(
                    staffId: staffId,
                    schoolId: schoolId,
                    workingDays: _workingDays,
                    startMinuteOfDay: _startMinute,
                    endMinuteOfDay: _endMinute,
                    slotDurationMinutes: _slotDuration,
                    maxAppointmentsPerDay: _maxPerDay,
                  )));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Availability saved')),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
