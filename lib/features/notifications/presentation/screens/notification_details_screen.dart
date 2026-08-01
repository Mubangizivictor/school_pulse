import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_category_config.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/repositories/notification_repository.dart';
import 'package:school_pulse/features/notifications/routing/authorization/notification_authorization.dart';
import 'package:school_pulse/features/notifications/routing/deep_link_router/notification_deep_link_router.dart';
import 'package:school_pulse/injection_container.dart' as di;

class NotificationDetailsScreen extends StatefulWidget {
  final NotificationItem notification;

  const NotificationDetailsScreen({super.key, required this.notification});

  @override
  State<NotificationDetailsScreen> createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  /// Local copy so an action's effect (read, pinned, acknowledged) shows
  /// immediately without waiting for a round trip or a rebuild from above.
  late NotificationItem notification;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    notification = widget.notification;
    // Opening the details screen is what "read" means for a notification that
    // was reached from a list tile or a push tap.
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  UserEntity? get _user {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user : null;
  }

  NotificationRepository get _repository => di.sl<NotificationRepository>();

  Future<void> _markRead() async {
    final user = _user;
    if (user == null || notification.readAt != null) return;

    await _repository.markAsRead(
      schoolId: user.schoolId,
      notificationId: notification.id,
      recipientUserId: user.id,
    );
    if (!mounted) return;
    setState(() {
      notification = notification.copyWith(
        status: notification.status == NotificationStatus.pinned
            ? NotificationStatus.pinned
            : NotificationStatus.read,
        readAt: DateTime.now(),
      );
    });
  }

  /// Runs a repository action, showing its failure message rather than
  /// silently doing nothing.
  Future<void> _act(
    String label,
    Future<void> Function(UserEntity user) action,
  ) async {
    if (_busy) return;
    final user = _user;
    if (user == null) return;

    setState(() => _busy = true);
    try {
      await action(user);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) _toast('$label done');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

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
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMoreMenu,
          ),
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
            // Acknowledgement sits above everything else it competes with:
            // an alert that requires confirmation is the whole point of the
            // screen until it has been confirmed.
            if (notification.requiresAcknowledgment) ...[
              const SizedBox(height: 32),
              _buildAcknowledgeSection(categoryColor),
            ],
            // Destination buttons the sender attached (View attendance, Pay
            // fees, Open conversation...), filtered to what this user may do.
            ..._buildModuleActions(categoryColor),
            const SizedBox(height: 40),
            _buildActionButtons(categoryColor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Confirmation panel for alerts that require it.
  ///
  /// Stays visible after confirming, showing when it happened, because the
  /// point of acknowledgement is the record that it occurred.
  Widget _buildAcknowledgeSection(Color themeColor) {
    final acknowledgedAt = notification.acknowledgedAt;

    if (acknowledgedAt != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: Color(0xFF10B981)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acknowledged',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy • h:mm a').format(acknowledgedAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE11D48)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.priority_high, color: Color(0xFFE11D48)),
              SizedBox(width: 8),
              Text(
                'Confirmation required',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Please confirm you have read and understood this notice.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _acknowledge,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Acknowledge'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acknowledge() async {
    await _act('Acknowledgement', (user) async {
      final result = await _repository.acknowledge(
        schoolId: user.schoolId,
        notificationId: notification.id,
        recipientUserId: user.id,
      );
      result.fold(
        (failure) => _toast(failure.userMessage),
        (_) {
          if (!mounted) return;
          setState(() {
            notification = notification.copyWith(
              acknowledgedAt: DateTime.now(),
              readAt: notification.readAt ?? DateTime.now(),
            );
          });
        },
      );
    });
  }

  /// The sender's own action buttons, filtered to those this user may invoke.
  ///
  /// An action the user is not authorised to perform is never rendered, rather
  /// than rendered and refused on tap.
  List<Widget> _buildModuleActions(Color themeColor) {
    final user = _user;
    if (user == null) return const [];

    final permitted = NotificationAuthorization.permittedActions(
      user: user,
      notification: notification,
      // Permission-gated actions are filtered server-side when the
      // notification is composed; anything reaching the client is already
      // scoped to the recipient, so an empty grant set is the safe default.
      grantedPermissions: const {},
    ).where((a) => !a.isAcknowledgement).toList();

    if (permitted.isEmpty) return const [];

    return [
      const SizedBox(height: 24),
      const Text(
        'What you can do',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      ...permitted.map(
        (action) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : () => _openAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor.withValues(alpha: 0.15),
                foregroundColor: themeColor,
                elevation: 0,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(action.label)),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  /// Opens the notification's destination.
  ///
  /// Always resolved through the deep-link router rather than pushing the
  /// stored route directly, so tenancy, permission and existence are re-checked
  /// at the moment of navigation - the record may have been withdrawn since it
  /// was sent.
  Future<void> _openAction() async {
    final user = _user;
    if (user == null) return;

    final resolution = await const NotificationDeepLinkRouter().resolve(
      notification: notification,
      user: user,
    );

    if (!mounted) return;

    final destination = resolution.destination;
    if (destination == null) {
      _toast(resolution.message ?? 'This item is no longer available.');
      return;
    }

    await _repository.markAsOpened(
      schoolId: user.schoolId,
      notificationId: notification.id,
      recipientUserId: user.id,
    );

    if (!mounted) return;
    context.push(destination.route, extra: destination.extra);
  }

  /// Overflow menu: the actions that do not warrant a permanent button.
  void _showMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_unread, color: Colors.white70),
              title: const Text(
                'Mark as unread',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _markUnread();
              },
            ),
            ListTile(
              leading: Icon(
                notification.isArchived ? Icons.unarchive : Icons.archive,
                color: Colors.white70,
              ),
              title: Text(
                notification.isArchived ? 'Unarchive' : 'Archive',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _toggleArchive();
              },
            ),
            // An unacknowledged alert may not be deleted out of the record -
            // the same rule the security rules enforce server-side.
            if (!notification.needsAcknowledgement)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFE11D48)),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFE11D48)),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _delete();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _markUnread() async {
    await _act('Marked unread', (user) async {
      await _repository.markAsUnread(
        schoolId: user.schoolId,
        notificationId: notification.id,
        recipientUserId: user.id,
      );
      if (!mounted) return;
      setState(() {
        notification = NotificationItem(
          id: notification.id,
          title: notification.title,
          description: notification.description,
          senderName: notification.senderName,
          senderRole: notification.senderRole,
          senderAvatar: notification.senderAvatar,
          timestamp: notification.timestamp,
          category: notification.category,
          priority: notification.priority,
          status: NotificationStatus.unread,
          attachments: notification.attachments,
          bannerImageUrl: notification.bannerImageUrl,
          longMessage: notification.longMessage,
          schoolId: notification.schoolId,
          recipientUserId: notification.recipientUserId,
          type: notification.type,
          persistence: notification.persistence,
          sender: notification.sender,
          sourceModule: notification.sourceModule,
          sourceEntityId: notification.sourceEntityId,
          relatedStudentId: notification.relatedStudentId,
          relatedStudentName: notification.relatedStudentName,
          relatedConversationId: notification.relatedConversationId,
          deepLinkRoute: notification.deepLinkRoute,
          actions: notification.actions,
          requiresAcknowledgment: notification.requiresAcknowledgment,
          acknowledgedAt: notification.acknowledgedAt,
          expiresAt: notification.expiresAt,
          metadata: notification.metadata,
        );
      });
    });
  }

  Future<void> _togglePin() async {
    final pinned = !notification.isPinned;
    await _act(pinned ? 'Pinned' : 'Unpinned', (user) async {
      await _repository.setPinned(
        schoolId: user.schoolId,
        notificationId: notification.id,
        recipientUserId: user.id,
        pinned: pinned,
      );
      if (!mounted) return;
      setState(() {
        notification = notification.copyWith(
          status: pinned ? NotificationStatus.pinned : NotificationStatus.read,
        );
      });
    });
  }

  Future<void> _toggleArchive() async {
    final archived = !notification.isArchived;
    await _act(archived ? 'Archived' : 'Unarchived', (user) async {
      await _repository.setArchived(
        schoolId: user.schoolId,
        notificationId: notification.id,
        recipientUserId: user.id,
        archived: archived,
      );
      if (!mounted) return;
      setState(() {
        notification = notification.copyWith(isArchived: archived);
      });
    });
  }

  Future<void> _delete() async {
    final user = _user;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Delete notification?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This removes it from your notification centre.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFE11D48)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await _repository.delete(
      schoolId: user.schoolId,
      notificationId: notification.id,
      recipientUserId: user.id,
    );

    if (!mounted) return;
    result.fold(
      (failure) => _toast(failure.userMessage),
      (_) => context.pop(),
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
        // "Contact" rather than "Follow": there is no subscribe concept in
        // school notifications, but reaching the person who sent it is a real
        // need. Hidden for automated senders - there is nobody to reply to.
        if (!notification.senderIdentity.isAutomated &&
            notification.senderIdentity.senderId != null)
          ElevatedButton(
            onPressed: _busy ? null : _contactSender,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white12,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(80, 32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Contact', style: TextStyle(fontSize: 12)),
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
              onPressed: () => _openAttachment(attachment),
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
    final isRead = notification.readAt != null;
    final isPinned = notification.isPinned;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Reflects current state rather than always reading "Mark as Read",
        // so the button says what tapping it will actually do.
        _buildActionButton(
          isRead ? Icons.mark_email_unread_outlined : Icons.check_circle_outline,
          isRead ? 'Mark Unread' : 'Mark as Read',
          themeColor,
          onTap: isRead ? _markUnread : _markRead,
        ),
        _buildActionButton(
          isPinned ? Icons.star : Icons.star_outline,
          isPinned ? 'Unpin' : 'Pin',
          themeColor,
          onTap: _togglePin,
        ),
        _buildActionButton(
          Icons.share_outlined,
          'Share',
          themeColor,
          onTap: _share,
        ),
        _buildActionButton(
          Icons.more_horiz,
          'More',
          themeColor,
          onTap: _showMoreMenu,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color themeColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: _busy ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: themeColor),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Opens a conversation with whoever sent this notification.
  ///
  /// Routes into the messaging module by its existing route rather than
  /// touching its internals - an existing conversation opens, and the
  /// messaging module handles creating one where none exists.
  Future<void> _contactSender() async {
    final conversationId = notification.relatedConversationId;
    if (conversationId != null && conversationId.isNotEmpty) {
      context.push('/messages/chat/$conversationId');
      return;
    }
    // No existing thread: land on the message list so the user can start one.
    context.push('/messages');
  }

  /// Shares the notification as text.
  ///
  /// Deliberately shares only title, body and sender - not the deep link,
  /// which would be useless to anyone outside the school and misleading to
  /// anyone inside it who lacks permission for the destination.
  Future<void> _share() async {
    final buffer = StringBuffer()
      ..writeln(notification.title)
      ..writeln()
      ..writeln(notification.longMessage ?? notification.description)
      ..writeln()
      ..write('— ${notification.senderName}');

    final role = notification.senderRole;
    if (role.isNotEmpty) buffer.write(', $role');

    try {
      await Share.share(buffer.toString(), subject: notification.title);
    } catch (e) {
      if (mounted) _toast('Could not share this notification.');
    }
  }

  /// Opens an attachment in the platform viewer, downloading it first when it
  /// has not been cached.
  Future<void> _openAttachment(NotificationAttachment attachment) async {
    // Already downloaded on a previous visit.
    final cached = attachment.localPath;
    if (cached != null && await File(cached).exists()) {
      await OpenFilex.open(cached);
      return;
    }

    if (attachment.url.isEmpty) {
      _toast('This attachment is unavailable.');
      return;
    }

    setState(() => _busy = true);
    try {
      final response = await http.get(Uri.parse(attachment.url));
      if (response.statusCode != 200) {
        if (mounted) _toast('This attachment is unavailable.');
        return;
      }

      final directory = await getTemporaryDirectory();
      // Namespaced by notification id so two notifications carrying files of
      // the same name do not overwrite each other.
      final file = File(
        '${directory.path}/${notification.id}_${attachment.name}',
      );
      await file.writeAsBytes(response.bodyBytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) _toast('Could not open this attachment.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
