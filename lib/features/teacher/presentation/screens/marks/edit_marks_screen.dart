import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class EditMarksScreen extends StatelessWidget {
  final String studentId;
  const EditMarksScreen({super.key, required this.studentId});

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
        title: Text('Edit Mark',
            style: TextStyle(
                color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mid Term Test • Section A',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: AppColors.disabled(context)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Akena Brian',
                        style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text('ADM/2022/001',
                        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Mark (out of 20)',
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: TextField(
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '16',
                  hintStyle: TextStyle(color: AppColors.textMuted(context)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 24),
            Text('Remarks (Optional)',
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: TextField(
                style: TextStyle(color: AppColors.textPrimary(context)),
                maxLines: 5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add remarks...',
                  hintStyle: TextStyle(color: AppColors.textMuted(context), fontSize: 14),
                ),
              ),
            ),
            const Spacer(),
            Row(
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
                    child: const Text('Save Changes',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

