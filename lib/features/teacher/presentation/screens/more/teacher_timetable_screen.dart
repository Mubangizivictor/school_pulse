import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Timetable'),
            Tab(text: 'Full School'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyTimetable(),
          const Center(child: Text('Full School Timetable')),
        ],
      ),
    );
  }

  Widget _buildMyTimetable() {
    return Column(
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI'].map((day) {
              final isSelected = day == 'MON';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (_) {},
                  selectedColor: AppColors.primary(context),
                  backgroundColor: AppColors.surfaceElevated(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary(context)
                        : AppColors.border(context),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white)
                        : AppColors.textSecondary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              _TimetableSlot(
                period: 1,
                time: '08:00 - 09:00',
                subject: 'Mathematics',
                className: 'P3 East',
                room: 'Room 12',
              ),
              _TimetableSlot(
                period: 2,
                time: '09:00 - 10:00',
                subject: 'Mathematics',
                className: 'P6 West',
                room: 'Room 18',
              ),
              _TimetableSlot(
                period: 3,
                time: '10:00 - 10:30',
                subject: 'Break',
                className: '',
                room: '',
                isBreak: true,
              ),
              _TimetableSlot(
                period: 4,
                time: '10:30 - 11:30',
                subject: 'Additional Mathematics',
                className: 'S1 East',
                room: 'Room 15',
              ),
              _TimetableSlot(
                period: 0,
                time: '11:30 - 12:30',
                subject: 'Lunch Break',
                className: '',
                room: '',
                isBreak: true,
              ),
              _TimetableSlot(
                period: 5,
                time: '12:30 - 13:40',
                subject: 'Mathematics',
                className: 'P3 East',
                room: 'Room 12',
              ),
              _TimetableSlot(
                period: 6,
                time: '13:40 - 14:40',
                subject: 'Mathematics',
                className: 'P6 West',
                room: 'Room 18',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimetableSlot extends StatelessWidget {
  final int period;
  final String time;
  final String subject;
  final String className;
  final String room;
  final bool isBreak;

  const _TimetableSlot({
    required this.period,
    required this.time,
    required this.subject,
    required this.className,
    required this.room,
    this.isBreak = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isBreak) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary(context).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary(context).withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 16,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(width: 8),
            Text(
              '$subject ($time)',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$period',
              style: TextStyle(
                color: AppColors.primary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted(context),
                  ),
                ),
                Text(
                  '$className - $subject',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            room,
            style: TextStyle(
              color: AppColors.primary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
