import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class MarksHistoryScreen extends StatelessWidget {
  const MarksHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Marks History', style: TextStyle(color: AppColors.textPrimary(context))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                  child: Icon(Icons.history, color: AppColors.primary(context), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index % 2 == 0 ? 'Mid Term Assessment' : 'Weekly Quiz ${10 - index}',
                        style: TextStyle(
                            color: AppColors.textPrimary(context), fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Mathematics • 24 Oct 2024',
                        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('45/45',
                        style: TextStyle(
                            color: AppColors.success(context), fontWeight: FontWeight.bold)),
                    Text('Students',
                        style: TextStyle(color: AppColors.textMuted(context), fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: AppColors.textMuted(context), size: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

