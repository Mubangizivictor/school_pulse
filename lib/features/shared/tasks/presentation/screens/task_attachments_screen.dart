import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TaskAttachmentsScreen extends StatefulWidget {
  final String taskId;
  const TaskAttachmentsScreen({super.key, required this.taskId});

  @override
  State<TaskAttachmentsScreen> createState() => _TaskAttachmentsScreenState();
}

class _TaskAttachmentsScreenState extends State<TaskAttachmentsScreen> {
  final List<Map<String, String>> _attachments = [
    {
      'name': 'inspection_report.pdf',
      'size': '1.2 MB',
      'type': 'PDF',
      'date': 'May 18, 2024',
    },
    {
      'name': 'sunset_house_entrance.jpg',
      'size': '2.5 MB',
      'type': 'IMG',
      'date': 'May 18, 2024',
    },
    {
      'name': 'maintenance_notes.docx',
      'size': '450 KB',
      'type': 'DOC',
      'date': 'May 17, 2024',
    },
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
          'Task Attachments',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primary(context),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.attach_file, color: AppColors.primary(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: _attachments.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _attachments.length,
              itemBuilder: (context, index) {
                final attachment = _attachments[index];
                return _buildAttachmentCard(context, attachment);
              },
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
            label: 'Upload New File',
            icon: Icons.upload_file,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: AppColors.textMuted(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No attachments yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload photos or documents related to this task.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(
    BuildContext context,
    Map<String, String> attachment,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isImage = attachment['type'] == 'IMG';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderColor: isDark ? AppColors.borderDark : AppColors.borderLight,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isImage ? AppColors.royalBlue : AppColors.brightOrange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isImage ? Icons.image : Icons.insert_drive_file,
                color: isImage ? AppColors.royalBlue : AppColors.brightOrange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment['name']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${attachment['size']} • ${attachment['date']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textMuted(context)),
              onSelected: (value) {},
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'download', child: Text('Download')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
