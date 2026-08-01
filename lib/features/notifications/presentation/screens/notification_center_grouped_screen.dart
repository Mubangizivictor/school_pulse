import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/entities/mock_notifications.dart';

class NotificationCenterGroupedScreen extends StatefulWidget {
  const NotificationCenterGroupedScreen({super.key});

  @override
  State<NotificationCenterGroupedScreen> createState() => _NotificationCenterGroupedScreenState();
}

class _NotificationCenterGroupedScreenState extends State<NotificationCenterGroupedScreen> {
  final Map<NotificationCategory, bool> _expandedSections = {
    NotificationCategory.announcements: true,
    NotificationCategory.attendance: true,
    NotificationCategory.finance: true,
  };

  NotificationCategory? _selectedCategory;

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
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => context.push('/staff/notifications/search'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryGrid(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Mark all as read', style: TextStyle(color: Color(0xFF6366F1), fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedCategory == null || _selectedCategory == NotificationCategory.announcements)
              _buildGroupedSection(
                context,
                NotificationCategory.announcements,
                'Announcements',
                const Color(0xFF6366F1),
                Icons.campaign,
                2,
                mockNotifications.where((n) => n.category == NotificationCategory.announcements).toList(),
              ),
            if (_selectedCategory == null) const SizedBox(height: 12),
            if (_selectedCategory == null || _selectedCategory == NotificationCategory.attendance)
              _buildGroupedSection(
                context,
                NotificationCategory.attendance,
                'Attendance',
                const Color(0xFF10B981),
                Icons.person_pin_circle,
                2,
                mockNotifications.where((n) => n.category == NotificationCategory.attendance).toList(),
              ),
            if (_selectedCategory == null) const SizedBox(height: 12),
            if (_selectedCategory == null || _selectedCategory == NotificationCategory.finance)
              _buildGroupedSection(
                context,
                NotificationCategory.finance,
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
    final categories = [
      {'label': 'All', 'icon': Icons.apps, 'color': const Color(0xFF6366F1), 'category': null},
      {'label': 'Announcements', 'icon': Icons.campaign, 'color': const Color(0xFF6366F1), 'category': NotificationCategory.announcements, 'count': 5},
      {'label': 'Attendance', 'icon': Icons.person_pin_circle, 'color': const Color(0xFF10B981), 'category': NotificationCategory.attendance, 'count': 2},
      {'label': 'Finance', 'icon': Icons.payments, 'color': const Color(0xFFF59E0B), 'category': NotificationCategory.finance, 'count': 4},
      {'label': 'Transport', 'icon': Icons.directions_bus, 'color': const Color(0xFF3B82F6), 'category': NotificationCategory.transport},
      {'label': 'Messages', 'icon': Icons.message, 'color': const Color(0xFFEC4899), 'category': NotificationCategory.messages, 'count': 2},
      {'label': 'Homework', 'icon': Icons.assignment, 'color': const Color(0xFF8B5CF6), 'category': NotificationCategory.homework, 'count': 1},
      {'label': 'Others', 'icon': Icons.more_horiz, 'color': const Color(0xFF94A3B8), 'category': NotificationCategory.others},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final category = cat['category'] as NotificationCategory?;
        final isSelected = _selectedCategory == category;

        return _buildCategoryItem(
          cat['label'] as String,
          cat['icon'] as IconData,
          cat['color'] as Color,
          isSelected: isSelected,
          count: cat['count'] as int?,
          onTap: () => setState(() => _selectedCategory = category),
        );
      },
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color, {bool isSelected = false, int? count, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: color, width: 2) : null,
                ),
                child: Icon(icon, color: isSelected ? color : Colors.white70, size: 24),
              ),
              if (count != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? color : const Color(0xFFE11D48),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedSection(
    BuildContext context,
    NotificationCategory category,
    String title,
    Color color,
    IconData icon,
    int count,
    List<NotificationItem> items,
  ) {
    final isExpanded = _expandedSections[category] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedSections[category] = !isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
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
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white60,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Colors.white12),
            ...items.map((item) => _buildSimpleTile(context, item, color)),
          ],
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
