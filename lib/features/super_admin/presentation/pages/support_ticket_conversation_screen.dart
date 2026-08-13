import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../data/services/support_ticket_service.dart';
import '../../domain/entities/support_ticket.dart';

/// Real-time ticket conversation screen. Ticket metadata (status,
/// priority) is loaded via `watchTicket` and messages via `watchMessages`,
/// both `snapshots()` streams so the UI reflects live updates (e.g. a
/// future admin panel/Cloud Function writing an agent reply) without a
/// manual refresh.
///
/// Attachments are intentionally not implemented: while `firebase_storage`
/// is a dependency used elsewhere in the codebase, wiring an upload path
/// into this brand-new collection without an established, reviewed storage
/// rules pattern for it would introduce an unreviewed file-upload surface.
/// Omitted per the spec's guidance to skip rather than build an insecure
/// path - see build report.
class SupportTicketConversationScreen extends StatefulWidget {
  const SupportTicketConversationScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<SupportTicketConversationScreen> createState() =>
      _SupportTicketConversationScreenState();
}

class _SupportTicketConversationScreenState
    extends State<SupportTicketConversationScreen> {
  final _service = SupportTicketService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _service.sendMessage(ticketId: widget.ticketId, text: text);
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not send message: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: StreamBuilder<SupportTicket?>(
          stream: _service.watchTicket(widget.ticketId),
          builder: (context, snapshot) {
            final ticket = snapshot.data;
            return Text(ticket?.ticketNumber ?? 'Ticket');
          },
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<SupportTicket?>(
            stream: _service.watchTicket(widget.ticketId),
            builder: (context, snapshot) {
              final ticket = snapshot.data;
              if (ticket == null) return const SizedBox.shrink();
              return _TicketHeader(ticket: ticket);
            },
          ),
          Expanded(
            child: StreamBuilder<List<SupportTicketMessage>>(
              stream: _service.watchMessages(widget.ticketId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Could not load messages.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  );
                }
                final messages = snapshot.data ?? const [];
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        'No replies yet. Support will respond here as soon as '
                        'they review your ticket.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.l),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _MessageBubble(message: messages[index]),
                );
              },
            ),
          ),
          _Composer(
            controller: _messageController,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.ticket});
  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticket.subject,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _Chip(
                label: _statusLabel(ticket.status),
                color: _statusColor(context, ticket.status),
              ),
              _Chip(
                label: _priorityLabel(ticket.priority),
                color: _priorityColor(context, ticket.priority),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(SupportTicketStatus status) {
    switch (status) {
      case SupportTicketStatus.open:
        return 'Open';
      case SupportTicketStatus.inProgress:
        return 'In Progress';
      case SupportTicketStatus.resolved:
        return 'Resolved';
    }
  }

  Color _statusColor(BuildContext context, SupportTicketStatus status) {
    switch (status) {
      case SupportTicketStatus.open:
        return AppColors.warning(context);
      case SupportTicketStatus.inProgress:
        return AppColors.information(context);
      case SupportTicketStatus.resolved:
        return AppColors.success(context);
    }
  }

  String _priorityLabel(SupportTicketPriority priority) {
    switch (priority) {
      case SupportTicketPriority.low:
        return 'Low priority';
      case SupportTicketPriority.medium:
        return 'Medium priority';
      case SupportTicketPriority.high:
        return 'High priority';
    }
  }

  Color _priorityColor(BuildContext context, SupportTicketPriority priority) {
    switch (priority) {
      case SupportTicketPriority.low:
        return AppColors.textSecondary(context);
      case SupportTicketPriority.medium:
        return AppColors.warning(context);
      case SupportTicketPriority.high:
        return AppColors.danger(context);
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final SupportTicketMessage message;

  @override
  Widget build(BuildContext context) {
    final isOwner = message.sender == SupportMessageSender.owner;
    final bubbleColor = isOwner
        ? AppColors.primary(context)
        : AppColors.surfaceElevated(context);
    final textColor = isOwner ? Colors.white : AppColors.textPrimary(context);

    return Align(
      alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isOwner ? 14 : 2),
            bottomRight: Radius.circular(isOwner ? 2 : 14),
          ),
          border: isOwner ? null : Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOwner
                  ? 'You'
                  : (message.senderName.isNotEmpty
                        ? message.senderName
                        : 'Support'),
              style: AppTypography.labelSmall.copyWith(
                color: textColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.text,
              style: AppTypography.bodyMedium.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(message.createdAt.toLocal()),
              style: AppTypography.labelSmall.copyWith(
                color: textColor.withValues(alpha: 0.65),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          border: Border(top: BorderSide(color: AppColors.border(context))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Type a reply...',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            IconButton.filled(
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
