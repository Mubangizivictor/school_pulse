import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class ImportMarksScreen extends StatelessWidget {
  const ImportMarksScreen({super.key});

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
        title: Text('Import Marks',
            style: TextStyle(
                color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.success(context).withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                    child: Icon(Icons.description, color: AppColors.success(context), size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text('Upload Excel / CSV File',
                      style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Drag and drop or tap to browse',
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Format Guide',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildGuideItem(context, 'First column: Student ID or Admission No.'),
            _buildGuideItem(context, 'First row: Student Name (optional)'),
            _buildGuideItem(context, 'Other columns: Marks'),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.download, color: AppColors.primary(context), size: 18),
              label: Text('Download Sample File',
                  style: TextStyle(color: AppColors.primary(context), fontSize: 14)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Import',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, color: AppColors.primary(context), size: 6),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
        ],
      ),
    );
  }
}

