import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/notification_model.dart';

/// Downloads [attachment] to a temporary file and hands it to the platform
/// viewer. Returns a message to show, or null on success.
///
/// Shared by both screens in this file so the download rules (empty URL,
/// non-200, already-cached) are stated once.
Future<String?> _downloadAndOpen({
  required String url,
  required String fileName,
}) async {
  if (url.isEmpty) return 'This attachment is unavailable.';

  try {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');

    // Re-opening an already-downloaded file avoids paying for the transfer
    // twice, which matters on a metered connection.
    if (!await file.exists()) {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        return 'This attachment is unavailable.';
      }
      await file.writeAsBytes(response.bodyBytes, flush: true);
    }

    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      return 'No app on this device can open ${fileName.split('.').last} files.';
    }
    return null;
  } catch (e) {
    return 'Could not open this attachment.';
  }
}

class AttachmentViewerScreen extends StatelessWidget {
  final List<NotificationAttachment>? attachments;
  const AttachmentViewerScreen({super.key, this.attachments});

  @override
  Widget build(BuildContext context) {
    final displayAttachments =
        attachments ??
        [
          NotificationAttachment(
            name: 'Exam_Timetable_Term2_2025.pdf',
            size: '2.4 MB',
            type: 'PDF',
            url: '',
          ),
          NotificationAttachment(
            name: 'Bus_Route_Updates_May.xlsx',
            size: '512 KB',
            type: 'XLSX',
            url: '',
          ),
          NotificationAttachment(
            name: 'Sports_Day_Poster.jpg',
            size: '1.8 MB',
            type: 'JPG',
            url: '',
          ),
          NotificationAttachment(
            name: 'Fee_Structure_2025.docx',
            size: '320 KB',
            type: 'DOCX',
            url: '',
          ),
        ];

    return Scaffold(
      backgroundColor: Colors.black,
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
                    color = Colors.black;
                    icon = Icons.picture_as_pdf;
                    break;
                  case 'XLSX':
                  case 'XLS':
                    color = Colors.black;
                    icon = Icons.table_chart;
                    break;
                  case 'JPG':
                  case 'PNG':
                  case 'JPEG':
                    color = Colors.black;
                    icon = Icons.image;
                    break;
                  default:
                    color = Colors.black;
                    icon = Icons.description;
                }

                return _buildAttachmentItem(
                  attachment.name,
                  '${attachment.size} • ${attachment.type}',
                  color,
                  icon,
                  attachment.url,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 16),
                  SizedBox(width: 12),
                  Text(
                    'Attachments are available for 30 days',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(
    String name,
    String details,
    Color color,
    IconData icon,
    String url,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  details,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () async {
                final error = await _downloadAndOpen(url: url, fileName: name);
                if (error != null && buttonContext.mounted) {
                  ScaffoldMessenger.of(
                    buttonContext,
                  ).showSnackBar(SnackBar(content: Text(error)));
                }
              },
            ),
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
        title: const Text(
          'Image Viewer',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (buttonContext) => IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () async {
                final error = await _downloadAndOpen(
                  url: imageUrl ?? '',
                  fileName: 'notification_image.jpg',
                );
                if (error != null && buttonContext.mounted) {
                  ScaffoldMessenger.of(
                    buttonContext,
                  ).showSnackBar(SnackBar(content: Text(error)));
                }
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.network(
              imageUrl ??
                  'https://images.unsplash.com/photo-1577891729319-86adcd962860?q=80&w=2069&auto=format&fit=crop',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 64),
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
