import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AttachmentViewerScreen extends StatelessWidget {
  const AttachmentViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAttachmentItem('Exam_Timetable_Term2_2025.pdf', '2.4 MB • PDF', Colors.red, Icons.picture_as_pdf),
                _buildAttachmentItem('Bus_Route_Updates_May.xlsx', '512 KB • XLSX', Colors.green, Icons.table_chart),
                _buildAttachmentItem('Sports_Day_Poster.jpg', '1.8 MB • JPG', Colors.blue, Icons.image),
                _buildAttachmentItem('Fee_Structure_2025.docx', '320 KB • DOCX', Colors.purple, Icons.description),
              ],
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
  const ImageViewerScreen({super.key});

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
        title: const Text('1 of 3', style: TextStyle(color: Colors.white, fontSize: 14)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.download, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.network(
              'https://images.unsplash.com/photo-1577891729319-86adcd962860?q=80&w=2069&auto=format&fit=crop',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBottomIcon(Icons.search),
                const SizedBox(width: 40),
                _buildBottomIcon(Icons.chevron_left),
                const SizedBox(width: 40),
                _buildBottomIcon(Icons.chevron_right),
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
