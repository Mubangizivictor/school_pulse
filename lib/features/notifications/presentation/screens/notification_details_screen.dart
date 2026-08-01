import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_category_config.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailsScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(notification.category);
    final categoryIcon = _getCategoryIcon(notification.category);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notification Details', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryName(notification.category),
                        style: TextStyle(color: categoryColor, fontSize: 14),
                      ),
                      Text(
                        notification.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('General', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white60, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy • h:mm a').format(notification.timestamp),
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (notification.bannerImageUrl != null)
              GestureDetector(
                onTap: () => context.push('/staff/notifications/image-viewer', extra: notification.bannerImageUrl),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(notification.bannerImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white12,
                ),
                child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 64)),
              ),
            const SizedBox(height: 24),
            Text(
              notification.longMessage ?? notification.description,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildSenderInfo(context, categoryColor),
            const SizedBox(height: 32),
            _buildDetailGrid(categoryColor),
            const SizedBox(height: 32),
            if (notification.attachments.isNotEmpty) ...[
              const Text('Attachment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...notification.attachments.map((a) => _buildAttachmentTile(context, a)),
            ],
            const SizedBox(height: 40),
            _buildActionButtons(categoryColor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Category treatment comes from the shared catalog so newly-added categories
  // pick up an icon, colour and display name automatically. The values
  // returned for the original eight categories are unchanged.
  Color _getCategoryColor(NotificationCategory category) =>
      NotificationCategoryCatalog.of(category).color;

  IconData _getCategoryIcon(NotificationCategory category) =>
      NotificationCategoryCatalog.of(category).icon;

  String _getCategoryName(NotificationCategory category) =>
      NotificationCategoryCatalog.of(category).displayName;

  Widget _buildSenderInfo(BuildContext context, Color themeColor) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white24,
          child: Icon(Icons.business, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sent by', style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text(notification.senderName, style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
              Text(notification.senderRole, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white12,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(80, 32),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Follow', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildDetailGrid(Color themeColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildDetailItem(Icons.group, 'Audience', 'All Students & Staff', themeColor),
        _buildDetailItem(Icons.category, 'Category', _getCategoryName(notification.category), themeColor),
        _buildDetailItem(Icons.priority_high, 'Priority', notification.priority.name.toUpperCase(), themeColor),
        _buildDetailItem(Icons.check_circle, 'Status', notification.status.name.toUpperCase(), themeColor),
        _buildDetailItem(Icons.timer, 'Expires On', '27 May 2025 • 11:59 PM', themeColor),
        _buildDetailItem(Icons.visibility, 'Read', '20 May 2025 • 2:01 PM', themeColor),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color themeColor) {
    return Row(
      children: [
        Icon(icon, color: themeColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentTile(BuildContext context, NotificationAttachment attachment) {
    return InkWell(
      onTap: () => context.push('/staff/notifications/attachments', extra: notification.attachments),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getAttachmentColor(attachment.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getAttachmentIcon(attachment.type), color: _getAttachmentColor(attachment.type), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(attachment.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  Text('${attachment.size} • ${attachment.type}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white70),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Color _getAttachmentColor(String type) {
    switch (type.toUpperCase()) {
      case 'PDF': return Colors.red;
      case 'XLSX':
      case 'XLS': return Colors.green;
      case 'JPG':
      case 'PNG':
      case 'JPEG': return Colors.blue;
      default: return Colors.purple;
    }
  }

  IconData _getAttachmentIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PDF': return Icons.picture_as_pdf;
      case 'XLSX':
      case 'XLS': return Icons.table_chart;
      case 'JPG':
      case 'PNG':
      case 'JPEG': return Icons.image;
      default: return Icons.description;
    }
  }

  Widget _buildActionButtons(Color themeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(Icons.check_circle_outline, 'Mark as Read', themeColor),
        _buildActionButton(Icons.star_outline, 'Pin', themeColor),
        _buildActionButton(Icons.share_outlined, 'Share', themeColor),
        _buildActionButton(Icons.more_horiz, 'More', themeColor),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color themeColor) {
    return Column(
      children: [
        Icon(icon, color: themeColor),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
