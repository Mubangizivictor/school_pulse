import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherLeaveRequestsScreen extends StatefulWidget {
  const TeacherLeaveRequestsScreen({super.key});

  @override
  State<TeacherLeaveRequestsScreen> createState() =>
      _TeacherLeaveRequestsScreenState();
}

class _TeacherLeaveRequestsScreenState extends State<TeacherLeaveRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(title: const Text('Leave Requests')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: 'New Request',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Requests'),
              Tab(text: 'All Requests'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyRequests(),
                const Center(child: Text('All Requests')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRequests() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LeaveRequestCard(
          type: 'Annual Leave',
          dates: '20 May 2024 - 23 May 2024',
          status: 'Pending',
          statusColor: Colors.orange,
        ),
        _LeaveRequestCard(
          type: 'Sick Leave',
          dates: '5 May 2024 - 8 May 2024',
          status: 'Approved',
          statusColor: Colors.green,
        ),
        _LeaveRequestCard(
          type: 'Personal Leave',
          dates: '28 Apr 2024 - 28 Apr 2024',
          status: 'Denied',
          statusColor: Colors.red,
        ),
      ],
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final String type;
  final String dates;
  final String status;
  final Color statusColor;

  const _LeaveRequestCard({
    required this.type,
    required this.dates,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dates,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
