import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TaskDormitoryAssignmentScreen extends StatefulWidget {
  const TaskDormitoryAssignmentScreen({super.key});

  @override
  State<TaskDormitoryAssignmentScreen> createState() =>
      _TaskDormitoryAssignmentScreenState();
}

class _TaskDormitoryAssignmentScreenState
    extends State<TaskDormitoryAssignmentScreen> {
  String? _selectedDorm;
  final List<Map<String, dynamic>> _dormitories = [
    {'name': 'Sunset House', 'type': 'Boys', 'occupancy': '45/50'},
    {'name': 'Sunrise Villa', 'type': 'Girls', 'occupancy': '48/50'},
    {'name': 'Highland Hall', 'type': 'Boys', 'occupancy': '30/40'},
    {'name': 'Riverside Wing', 'type': 'Girls', 'occupancy': '50/50'},
    {'name': 'Greenwood Lodge', 'type': 'Boys', 'occupancy': '38/45'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Assign Dormitory',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search dormitories...',
                prefixIcon: const Icon(Icons.search),
                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _dormitories.length,
              itemBuilder: (context, index) {
                final dorm = _dormitories[index];
                final isSelected = _selectedDorm == dorm['name'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    color: isSelected
                        ? AppColors.royalBlue
                        : (isDark ? AppColors.surfaceDark : Colors.white),
                    borderColor: isSelected
                        ? AppColors.royalBlue
                        : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                    onTap: () => setState(() => _selectedDorm = dorm['name']),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (dorm['type'] == 'Boys'
                                ? AppColors.electricBlue
                                : Colors.black),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.home_work_outlined,
                            color: dorm['type'] == 'Boys'
                                ? AppColors.electricBlue
                                : Colors.black,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dorm['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dorm['type']} • Occupancy: ${dorm['occupancy']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.royalBlue,
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            color: AppColors.textMuted(context),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
        ),
        child: SafeArea(
          child: PrimaryButton(
            label: 'Confirm Assignment',
            onPressed: _selectedDorm == null
                ? null
                : () => Navigator.pop(context, _selectedDorm),
          ),
        ),
      ),
    );
  }
}
