import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/entities/mock_notifications.dart';

class NotificationCenterGroupedScreen extends StatelessWidget {
  const NotificationCenterGroupedScreen({super.key});

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
        title: const Text('Notification Center', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryGrid(),
            const SizedBox(height: 24),
            const Text(
              'Today',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildGroupedSection(
              context,
              'Announcements',
              const Color(0xFF6366F1),
              Icons.campaign,
              2,
              mockNotifications.where((n) => n.category == NotificationCategory.announcements).toList(),
            ),
            const SizedBox(height: 12),
            _buildGroupedSection(
              context,
              'Attendance',
              const Color(0xFF10B981),
              Icons.person_pin_circle,
              2,
              mockNotifications.where((n) => n.category == NotificationCategory.attendance).toList(),
            ),
            const SizedBox(height: 12),
            _buildGroupedSection(
              context,
              'Finance',
              const Color(0xFFF59E0B),
              Icons.payments,
              1,
              mockNotifications.where((n) => n.category == NotificationCategory.finance).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildCategoryItem('All', Icons.apps, const Color(0xFF6366F1), isSelected: true),
        _buildCategoryItem('Announcements', Icons.campaign, Colors.white24, count: 5),
        _buildCategoryItem('Attendance', Icons.person_pin_circle, Colors.white24, count: 2),
        _buildCategoryItem('Finance', Icons.payments, Colors.white24, count: 4),
        _buildCategoryItem('Transport', Icons.directions_bus, Colors.white24),
        _buildCategoryItem('Messages', Icons.message, Colors.white24, count: 2),
        _buildCategoryItem('Homework', Icons.assignment, Colors.white24, count: 1),
        _buildCategoryItem('Others', Icons.more_horiz, Colors.white24),
      ],
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color, {bool isSelected = false, int? count}) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 24),
            ),
            if (count != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildGroupedSection(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    int count,
    List<NotificationItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(count.toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          ...items.map((item) => _buildSimpleTile(context, item, color)),
        ],
      ),
    );
  }

  Widget _buildSimpleTile(BuildContext context, NotificationItem item, Color iconColor) {
    return InkWell(
      onTap: () => context.push('/staff/notifications/${item.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(item.timestamp),
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.priority == NotificationPriority.high) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'High',
                        style: TextStyle(color: Color(0xFFE11D48), fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
