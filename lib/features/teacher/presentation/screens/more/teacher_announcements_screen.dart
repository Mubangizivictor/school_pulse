import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherAnnouncementsScreen extends StatefulWidget {
  const TeacherAnnouncementsScreen({super.key});

  @override
  State<TeacherAnnouncementsScreen> createState() =>
      _TeacherAnnouncementsScreenState();
}

class _TeacherAnnouncementsScreenState extends State<TeacherAnnouncementsScreen>
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
        title: const Text('Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'School'),
            Tab(text: 'Class'),
            Tab(text: 'Department'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementsList(),
          const Center(child: Text('School Announcements')),
          const Center(child: Text('Class Announcements')),
          const Center(child: Text('Department Announcements')),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Today'),
        _AnnouncementCard(
          icon: Icons.groups_rounded,
          iconColor: Colors.blue,
          title: 'School Assembly',
          description:
              'There will be a school assembly on 26th May 2024 at 10:00 AM.',
          time: '9:30 AM',
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Yesterday'),
        _AnnouncementCard(
          icon: Icons.people_outline_rounded,
          iconColor: Colors.orange,
          title: "Parents' Meeting",
          description:
              "Parents' meeting for P3 East on 22nd May 2024 at 2:00 PM.",
          time: 'Yesterday',
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('This Week'),
        _AnnouncementCard(
          icon: Icons.edit_document,
          iconColor: Colors.purple,
          title: 'Mid-Term Exams',
          description: 'Mid-term examinations start on 20th May 2024.',
          time: '18 May, 2024',
        ),
        _AnnouncementCard(
          icon: Icons.emoji_events_outlined,
          iconColor: Colors.green,
          title: "Sports Day",
          description: 'Sports Day will be held on 18th May 2024.',
          time: '17 May, 2024',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

class _AnnouncementCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String time;

  const _AnnouncementCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
