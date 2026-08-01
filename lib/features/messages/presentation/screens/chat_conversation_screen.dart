import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/widgets/message_bubble.dart';

class ChatConversationScreen extends StatefulWidget {
  final String chatId;
  const ChatConversationScreen({super.key, required this.chatId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      senderId: 'other',
      senderName: 'Mrs. Amina',
      content: 'Reminder: PTA meeting this Friday at 4PM in the assembly hall.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      isMe: false,
    ),
    ChatMessage(
      id: '2',
      senderId: 'me',
      senderName: 'Me',
      content: 'Thank you for the reminder!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isMe: true,
      isRead: true,
    ),
    ChatMessage(
      id: '3',
      senderId: 'other',
      senderName: 'Mr. Boateng',
      content: 'Will the meeting be online or in-person?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isMe: false,
    ),
    ChatMessage(
      id: '4',
      senderId: 'other',
      senderName: 'Mrs. Amina',
      content: 'In-person. See you all there.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () => context.push('/messages/chat/${widget.chatId}/info'),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.electricBlue,
                child: Text('P7', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: AppSpacing.s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('P7 - Parents Group', style: AppTypography.titleMedium),
                  Text('32 members', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Group Info')),
              const PopupMenuItem(child: Text('Starred Messages')),
              const PopupMenuItem(child: Text('Mute Notifications')),
              const PopupMenuItem(child: Text('Clear Chat')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05),
            child: Row(
              children: [
                const Icon(Icons.pin_drop, size: 14, color: AppColors.electricBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pinned: PTA meeting this Friday at 4PM',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.electricBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 14),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages.reversed.toList()[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAttachmentMenu(context),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : AppColors.surfaceContainer(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            CircleAvatar(
              backgroundColor: AppColors.electricBlue,
              child: IconButton(
                icon: const Icon(Icons.mic, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AttachmentsMenu(),
    );
  }
}

class AttachmentsMenu extends StatelessWidget {
  const AttachmentsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.m,
            children: [
              _AttachmentItem(icon: Icons.image, label: 'Photos', color: Colors.purple),
              _AttachmentItem(icon: Icons.camera_alt, label: 'Camera', color: Colors.pink),
              _AttachmentItem(icon: Icons.insert_drive_file, label: 'Document', color: Colors.blue),
              _AttachmentItem(icon: Icons.headset, label: 'Audio', color: Colors.orange),
              _AttachmentItem(icon: Icons.location_on, label: 'Location', color: Colors.green),
              _AttachmentItem(icon: Icons.person, label: 'Contact', color: Colors.teal),
              _AttachmentItem(icon: Icons.poll, label: 'Poll', color: Colors.amber),
              _AttachmentItem(icon: Icons.event, label: 'Event', color: Colors.cyan),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AttachmentItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
