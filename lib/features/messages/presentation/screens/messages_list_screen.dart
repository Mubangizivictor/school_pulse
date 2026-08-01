import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/widgets/chat_list_tile.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final List<ChatConversation> mockConversations = [
    ChatConversation(
      id: '1',
      title: 'P7 - Parents Group',
      subtitle: 'Mrs. Amina: PTA meeting this Friday at 4PM',
      type: ChatType.group,
      unreadCount: 2,
      participants: [],
      lastMessage: ChatMessage(
        id: 'm1',
        senderId: 'admin',
        senderName: 'Mrs. Amina',
        content: 'PTA meeting this Friday at 4PM',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ),
    ChatConversation(
      id: '2',
      title: 'Mr. Kofi Mensah',
      subtitle: 'Please find the homework attached.',
      type: ChatType.direct,
      participants: [],
      lastMessage: ChatMessage(
        id: 'm2',
        senderId: 'kofi',
        senderName: 'Mr. Kofi Mensah',
        content: 'Please find the homework attached.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () => context.push('/messages/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search messages',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onTap: () => context.push('/messages/search'),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Row(
              children: [
                _FilterChip(label: 'All', isSelected: true),
                _FilterChip(label: 'Unread', isSelected: false),
                _FilterChip(label: 'Groups', isSelected: false),
                _FilterChip(label: 'Official', isSelected: false),
              ],
            ),
          ),
          Expanded(
            child: mockConversations.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                    itemCount: mockConversations.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                    itemBuilder: (context, index) {
                      final chat = mockConversations[index];
                      return ChatListTile(
                        chat: chat,
                        onTap: () => context.push('/messages/chat/${chat.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, size: 48, color: AppColors.electricBlue),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('No messages yet', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Direct messages from the school will appear here.',
              textAlign: Center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted(context)),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.push('/messages/new'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l, vertical: AppSpacing.m),
              ),
              child: const Text('New Message'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        selectedColor: AppColors.electricBlue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textMuted(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
