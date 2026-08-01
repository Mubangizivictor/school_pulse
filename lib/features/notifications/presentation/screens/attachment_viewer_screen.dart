import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/notification_model.dart';

class AttachmentViewerScreen extends StatelessWidget {
  final List<NotificationAttachment>? attachments;
  const AttachmentViewerScreen({super.key, this.attachments});

  @override
  Widget build(BuildContext context) {
    final displayAttachments = attachments ?? [
      NotificationAttachment(name: 'Exam_Timetable_Term2_2025.pdf', size: '2.4 MB', type: 'PDF', url: ''),
      NotificationAttachment(name: 'Bus_Route_Updates_May.xlsx', size: '512 KB', type: 'XLSX', url: ''),
      NotificationAttachment(name: 'Sports_Day_Poster.jpg', size: '1.8 MB', type: 'JPG', url: ''),
      NotificationAttachment(name: 'Fee_Structure_2025.docx', size: '320 KB', type: 'DOCX', url: ''),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Attachments', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayAttachments.length,
              itemBuilder: (context, index) {
                final attachment = displayAttachments[index];
                Color color;
                IconData icon;
                
                switch (attachment.type.toUpperCase()) {
                  case 'PDF':
                    color = Colors.red;
                    icon = Icons.picture_as_pdf;
                    break;
                  case 'XLSX':
                  case 'XLS':
                    color = Colors.green;
                    icon = Icons.table_chart;
                    break;
                  case 'JPG':
                  case 'PNG':
                  case 'JPEG':
                    color = Colors.blue;
                    icon = Icons.image;
                    break;
                  default:
                    color = Colors.purple;
                    icon = Icons.description;
                }
                
                return _buildAttachmentItem(
                  attachment.name, 
                  '${attachment.size} • ${attachment.type}', 
                  color, 
                  icon,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white30, size: 16),
                  SizedBox(width: 12),
                  Text(
                    'Attachments are available for 30 days',
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(String name, String details, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                Text(details, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final String? imageUrl;
  const ImageViewerScreen({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Image Viewer', style: TextStyle(color: Colors.white, fontSize: 14)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.download, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.network(
              imageUrl ?? 'https://images.unsplash.com/photo-1577891729319-86adcd962860?q=80&w=2069&auto=format&fit=crop',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white54, size: 64),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBottomIcon(Icons.zoom_in),
                const SizedBox(width: 40),
                _buildBottomIcon(Icons.share),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 28);
  }
}
