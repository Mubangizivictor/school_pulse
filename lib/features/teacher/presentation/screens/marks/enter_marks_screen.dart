import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class EnterMarksScreen extends StatelessWidget {
  const EnterMarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('Enter Marks',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Mid Term Test • Section A',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('8 / 28 Entered',
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceElevated(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5))),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textMuted(context), size: 14),
                      const SizedBox(width: 4),
                      Text('Search students...',
                          style: TextStyle(color: AppColors.textMuted(context), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text('#', style: TextStyle(color: AppColors.textMuted(context), fontSize: 12)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Student Name',
                        style: TextStyle(color: AppColors.textMuted(context), fontSize: 12))),
                Text('/ 20', style: TextStyle(color: AppColors.textMuted(context), fontSize: 12)),
                const SizedBox(width: 24),
                Text('Mark', style: TextStyle(color: AppColors.textMuted(context), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 8,
              itemBuilder: (context, index) {
                final studentNames = [
                  'Akena Brian',
                  'Nanyonga Faith',
                  'Odhiambo James',
                  'Tusiime Kevin',
                  'Nabirye Amanda',
                  'Kamya Sharon',
                  'Mugisha Ethan',
                  'Ssekidde Daniel'
                ];
                final marks = ['16', '14', '9', '18', '', '', '', ''];
                return _buildStudentMarkRow(context, index + 1, studentNames[index], marks[index]);
              },
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildStudentMarkRow(BuildContext context, int rank, String name, String mark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(context).withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Text(rank.toString(),
              style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
          const SizedBox(width: 12),
          CircleAvatar(radius: 14, backgroundColor: AppColors.disabled(context)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14))),
          Container(
            width: 60,
            height: 36,
            decoration: BoxDecoration(
              color: mark.isEmpty ? Colors.transparent : AppColors.primary(context).withValues(alpha: 0.1),
              border: Border.all(
                  color: mark.isEmpty ? AppColors.border(context) : AppColors.primary(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(mark,
                  style: TextStyle(
                      color: AppColors.textPrimary(context), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border(context)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save Draft', style: TextStyle(color: AppColors.textPrimary(context))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.push('/staff/marks/review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Review & Submit',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

