import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationFilterScreen extends StatefulWidget {
  const NotificationFilterScreen({super.key});

  @override
  State<NotificationFilterScreen> createState() => _NotificationFilterScreenState();
}

class _NotificationFilterScreenState extends State<NotificationFilterScreen> {
  bool _hasAttachments = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Filter Notifications', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Reset', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Select all', style: TextStyle(color: Color(0xFF6366F1), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            _buildCategoryGrid(),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date Range', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text('Custom', style: TextStyle(color: Color(0xFF6366F1), fontSize: 12)),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1), size: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDateField('From', '20 May 2025')),
                const SizedBox(width: 16),
                Expanded(child: _buildDateField('To', '20 Jun 2025')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Priority', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildChipGroup(['All', 'High', 'Medium', 'Low'], [null, Colors.red, Colors.orange, Colors.green]),
            const SizedBox(height: 24),
            const Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildChipGroup(['All', 'Unread', 'Read', 'Pinned'], [null, null, null, null]),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Has Attachments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Switch(
                  value: _hasAttachments,
                  onChanged: (val) => setState(() => _hasAttachments = val),
                  activeColor: const Color(0xFF6366F1),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Announcements', 'icon': Icons.campaign, 'color': const Color(0xFF6366F1), 'count': 2},
      {'name': 'Attendance', 'icon': Icons.person_pin_circle, 'color': const Color(0xFF10B981), 'count': 2},
      {'name': 'Finance', 'icon': Icons.payments, 'color': const Color(0xFFF59E0B), 'count': 3},
      {'name': 'Transport', 'icon': Icons.directions_bus, 'color': const Color(0xFF3B82F6)},
      {'name': 'Messages', 'icon': Icons.message, 'color': const Color(0xFFEC4899)},
      {'name': 'Homework', 'icon': Icons.assignment, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Library', 'icon': Icons.local_library, 'color': const Color(0xFF06B6D4)},
      {'name': 'Others', 'icon': Icons.more_horiz, 'color': const Color(0xFF94A3B8)},
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
        final isSelected = index < 3;
        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? (cat['color'] as Color) : Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : Colors.white70, size: 24),
                ),
                if (cat['count'] != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Text(cat['count'].toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              cat['name'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: Colors.white)),
              const Icon(Icons.calendar_today, color: Colors.white60, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipGroup(List<String> labels, List<Color?> colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(labels.length, (index) {
        final isSelected = index == 0;
        final color = colors[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white12,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? const Color(0xFF6366F1) : Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (color != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
              ],
              Text(labels[index], style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13)),
            ],
          ),
        );
      }),
    );
  }
}
