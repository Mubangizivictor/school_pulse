import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class MessageRequestsScreen extends StatelessWidget {
  const MessageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Message Requests', style: AppTypography.titleLarge),
          bottom: TabBar(
            labelColor: AppColors.electricBlue,
            unselectedLabelColor: AppColors.textMuted(context),
            indicatorColor: AppColors.electricBlue,
            labelStyle: AppTypography.titleSmall,
            tabs: const [
              Tab(text: 'You May Know'),
              Tab(text: 'Spam'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsList(context),
            _buildRequestsList(context, isEmpty: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, {bool isEmpty = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.textMuted(context).withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No Spam Requests', style: AppTypography.titleMedium.copyWith(color: AppColors.textMuted(context))),
            const SizedBox(height: 8),
            Text('Messages from unknown senders will appear here.', 
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.electricBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(index == 0 ? 'Parent - New' : index == 1 ? 'Prospective Student' : 'School Vendor', 
                            style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text('Hello, I have a question about the upcoming admissions process...', 
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text(index == 0 ? '10:10 AM' : index == 1 ? 'Yesterday' : 'Sun', 
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red, 
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emeraldGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
