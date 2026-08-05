import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherDownloadsScreen extends StatefulWidget {
  const TeacherDownloadsScreen({super.key});

  @override
  State<TeacherDownloadsScreen> createState() => _TeacherDownloadsScreenState();
}

class _TeacherDownloadsScreenState extends State<TeacherDownloadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Downloads'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Documents'),
            Tab(text: 'Reports'),
            Tab(text: 'Others'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchField(
              hintText: 'Search downloads...',
              onChanged: (value) {},
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDownloadsList(),
                const Center(child: Text('Documents')),
                const Center(child: Text('Reports')),
                const Center(child: Text('Others')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSectionHeader('Today'),
        _DownloadItem(
          title: 'P3 East - Student List.pdf',
          subtitle: '12 May 2024 • 156 KB',
          icon: Icons.picture_as_pdf_rounded,
          iconColor: Colors.red,
        ),
        _DownloadItem(
          title: 'Term 2 Syllabus - Mathematics.pdf',
          subtitle: '12 May 2024 • 2.4 MB',
          icon: Icons.picture_as_pdf_rounded,
          iconColor: Colors.red,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Yesterday'),
        _DownloadItem(
          title: 'P3 East - Class Timetable.pdf',
          subtitle: '11 May 2024 • 120 KB',
          icon: Icons.picture_as_pdf_rounded,
          iconColor: Colors.red,
        ),
        _DownloadItem(
          title: 'P6 West Exam Paper 1.pdf',
          subtitle: '11 May 2024 • 1.2 MB',
          icon: Icons.picture_as_pdf_rounded,
          iconColor: Colors.red,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('This Week'),
        _DownloadItem(
          title: 'Mathematics Scheme of Work.docx',
          subtitle: '10 May 2024 • 85 KB',
          icon: Icons.description_rounded,
          iconColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textMuted(context),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DownloadItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _DownloadItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
