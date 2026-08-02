import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TakeAttendanceScreen extends StatelessWidget {
  final String lessonId;
  const TakeAttendanceScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Take Attendance', style: TextStyle(color: AppColors.textPrimary(context))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.textPrimary(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLessonHeader(context),
          _buildSummaryBar(context),
          _buildSearchBar(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildStudentItem(context, '1', 'Akena Brian', 'Present', AppColors.success(context)),
                _buildStudentItem(
                    context, '2', 'Nanyonjo Faith', 'Present', AppColors.success(context)),
                _buildStudentItem(
                    context, '3', 'Odhiambo James', 'Absent', AppColors.danger(context)),
                _buildStudentItem(
                    context, '4', 'Tusiime Kevin', 'Present', AppColors.success(context)),
                _buildStudentItem(
                    context, '5', 'Nabirye Amanda', 'Late', AppColors.warning(context)),
                _buildStudentItem(
                    context, '6', 'Kamya Sharon', 'Present', AppColors.success(context)),
              ],
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildLessonHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.book, color: AppColors.primary(context), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Linear Equations',
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('Grade 10A (Science) • Section A',
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                Text('Mon, 20 May 2025 • 10:00 AM - 10:45 AM',
                    style: TextStyle(color: AppColors.textMuted(context), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(context, 'All', '28', AppColors.textPrimary(context)),
          _buildSummaryItem(context, 'Present', '24', AppColors.success(context)),
          _buildSummaryItem(context, 'Absent', '3', AppColors.danger(context)),
          _buildSummaryItem(context, 'Late', '1', AppColors.warning(context)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        style: TextStyle(color: AppColors.textPrimary(context)),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted(context)),
          hintText: 'Search students...',
          hintStyle: TextStyle(color: AppColors.textMuted(context)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentItem(
      BuildContext context, String id, String name, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text(id, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 14)),
          const SizedBox(width: 12),
          CircleAvatar(radius: 16, backgroundColor: AppColors.disabled(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style:
                    TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(status,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: statusColor, size: 14),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.more_vert, color: AppColors.textSecondary(context), size: 20),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border(context)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary(context))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Save Attendance',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

