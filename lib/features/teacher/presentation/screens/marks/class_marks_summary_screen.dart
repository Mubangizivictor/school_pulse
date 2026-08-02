import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class ClassMarksSummaryScreen extends StatelessWidget {
  const ClassMarksSummaryScreen({super.key});

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
        title: Text('Class Marks Summary',
            style: TextStyle(
                color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mid Term Test',
                      style: TextStyle(
                          color: AppColors.textPrimary(context), fontWeight: FontWeight.bold)),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary(context)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildSummaryBox(context, 'Class Average', '64%', AppColors.success(context)),
                const SizedBox(width: 12),
                _buildSummaryBox(context, 'Highest Score', '36/40', AppColors.textPrimary(context)),
                const SizedBox(width: 12),
                _buildSummaryBox(context, 'Lowest Score', '18/40', AppColors.textPrimary(context)),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildMiniTab(context, 'Overview', true),
                  _buildMiniTab(context, 'Distribution', false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildStudentPerformanceList(context),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Class Average',
                      style: TextStyle(
                          color: AppColors.textPrimary(context), fontWeight: FontWeight.bold)),
                  Text('64%',
                      style: TextStyle(
                          color: AppColors.success(context), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(BuildContext context, String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: AppColors.textMuted(context), fontSize: 10)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTab(BuildContext context, String label, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted(context),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildStudentPerformanceList(BuildContext context) {
    return Column(
      children: [
        _buildPerformanceItem(context, 'Akena Brian', '36/40', '90%', AppColors.success(context)),
        _buildPerformanceItem(context, 'Tusiime Kevin', '32/40', '80%', AppColors.success(context)),
        _buildPerformanceItem(context, 'Nanyonga Faith', '28/40', '70%', AppColors.success(context)),
        _buildPerformanceItem(context, 'Kamya Sharon', '24/40', '60%', AppColors.warning(context)),
        _buildPerformanceItem(context, 'Odhiambo James', '18/40', '45%', AppColors.danger(context)),
      ],
    );
  }

  Widget _buildPerformanceItem(
      BuildContext context, String name, String marks, String percentage, Color pctColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: AppColors.disabled(context)),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(name, style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14))),
          Text(marks, style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14)),
          const SizedBox(width: 24),
          Text(percentage,
              style: TextStyle(color: pctColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(Icons.trending_up, color: AppColors.success(context), size: 14),
        ],
      ),
    );
  }
}

