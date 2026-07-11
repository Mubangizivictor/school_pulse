import 'package:flutter/material.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/mock_data/mock_data.dart';
import 'package:school_pulse/mock_data/mock_models.dart';

import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = MockData.chatThreads;
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: const StudentAppBar(
        title: 'Messages',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: threads.length,
        itemBuilder: (context, index) {
          final thread = threads[index];
          return FadeInSlide(
            delay: Duration(milliseconds: index * 100),
            child: AppCard(
              onTap: () => _openThread(context, thread),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AvatarInitials(
                    name: thread.participantName,
                    ringColor: thread.isAnnouncement ? semanticColors.warning : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              thread.participantName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormatter.relative(thread.lastMessageTime),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          thread.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (thread.isAnnouncement)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.campaign, color: semanticColors.warning, size: 20),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openThread(BuildContext context, ChatThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(thread: thread),
      ),
    );
  }
}

class ChatDetailScreen extends StatelessWidget {
  final ChatThread thread;

  const ChatDetailScreen({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    final messages = MockData.chatMessages.where((m) => m.threadId == thread.id).toList();
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(thread.participantName)),
      body: Column(
        children: [
          if (thread.isAnnouncement)
            Padding(
              padding: const EdgeInsets.all(16),
              child: AlertBanner(
                title: 'Announcement Channel',
                message: 'This is a read-only channel for school announcements.',
                color: semanticColors.info,
                icon: Icons.campaign_outlined,
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true, // Show latest at bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                // In a real app, we'd sort messages. Here we just take them.
                final msg = messages[messages.length - 1 - index];
                return _buildMessageBubble(context, msg);
              },
            ),
          ),
          if (!thread.isAnnouncement) _buildChatInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
    final isMe = msg.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isMe 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.relative(msg.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: (isMe 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSurfaceVariant).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
