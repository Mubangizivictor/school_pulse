import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class _Document {
  final String name;
  final String type;
  final String size;
  final IconData icon;

  const _Document(this.name, this.type, this.size, this.icon);
}

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const documents = [
      _Document(
        'NCDC Lower Secondary Curriculum.pdf',
        'Curriculum',
        '4.2 MB',
        Icons.picture_as_pdf_outlined,
      ),
      _Document(
        'Mathematics Marking Guide - Term 2.pdf',
        'Marking Guide',
        '1.1 MB',
        Icons.picture_as_pdf_outlined,
      ),
      _Document(
        'S3 Project Assessment Rubric.docx',
        'Academic Policy',
        '340 KB',
        Icons.description_outlined,
      ),
      _Document(
        'Moderation Report - Term 1.pdf',
        'Moderation Report',
        '820 KB',
        Icons.picture_as_pdf_outlined,
      ),
      _Document(
        'Academic Meeting Minutes - May.pdf',
        'Meeting Minutes',
        '210 KB',
        Icons.picture_as_pdf_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Documents')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document upload coming soon')),
        ),
        child: const Icon(Icons.upload_file_outlined),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: documents.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
        itemBuilder: (context, index) {
          final doc = documents[index];
          return AppCard(
            onTap: () => _showDocumentDetails(context, doc),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: AppRadius.medium,
                  ),
                  child: Icon(doc.icon, color: AppColors.primary(context)),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.name,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${doc.type} • ${doc.size}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.download_outlined,
                  color: AppColors.textMuted(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDocumentDetails(BuildContext context, _Document doc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(doc.name),
        content: Text('${doc.type} • ${doc.size}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading ${doc.name}...')),
              );
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
