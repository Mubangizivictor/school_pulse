import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/mock_data/mock_data.dart';
import 'package:school_pulse/mock_data/mock_models.dart';

import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = MockData.chatThreads;
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final authState = context.watch<AuthBloc>().state;
    final isStaff = authState is AuthAuthenticated && authState.user.role != UserRole.parent;

    return Scaffold(
      appBar: isStaff 
        ? AppBar(title: const Text('Messages'))
        : const StudentAppBar(title: 'Messages'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewMessageSheet(context),
        label: const Text('New Message'),
        icon: const Icon(Icons.edit_outlined),
      ),
    );
  }

  void _showNewMessageSheet(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;

    if (user.role == UserRole.parent) {
      _showParentContactSheet(context);
    } else if (user.role == UserRole.nurse) {
      _showNurseContactSheet(context);
    } else {
      // Default staff contact sheet (generic)
      _showStaffContactSheet(context);
    }
  }

  void _showParentContactSheet(BuildContext context) {
    final studentState = context.read<SelectedStudentBloc>().state;
    if (studentState is! SelectedStudentLoaded) return;
    final student = studentState.student;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Contact Staff for ${student.name}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  _buildContactTile(context, name: 'Mr. Okot Joseph', role: 'Class Teacher (${student.className})', icon: Icons.school_outlined),
                  _buildContactTile(context, name: 'Dr. Ssempijja Ronald', role: 'Head Teacher', icon: Icons.person_pin_outlined),
                  _buildContactTile(context, name: 'Mr. Mwesigwa Isaac', role: 'Dean of Studies', icon: Icons.assignment_outlined),
                  _buildContactTile(context, name: 'Mrs. Nakintu Hellen', role: 'Bursar (Fees & Accounts)', icon: Icons.account_balance_wallet_outlined),
                  _buildContactTile(context, name: 'Sr. Mary Goretti', role: 'School Nurse', icon: Icons.health_and_safety_outlined),
                  _buildContactTile(context, name: 'Mrs. Mukasa Jane', role: 'Matron (Blue House)', icon: Icons.bed_outlined),
                  _buildContactTile(context, name: 'Mr. Ssebaana Fred', role: 'Transport Coordinator', icon: Icons.directions_bus_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNurseContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nurse Contact List',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  const ListHeader(title: 'Urgent Contacts'),
                  _buildContactTile(context, name: 'Dr. Ssempijja Ronald', role: 'Head Teacher', icon: Icons.person_pin_outlined),
                  const ListHeader(title: 'Class Teachers'),
                  _buildContactTile(context, name: 'Mr. Okot Joseph', role: 'P.4 Blue Teacher', icon: Icons.school_outlined),
                  _buildContactTile(context, name: 'Ms. Atim Sarah', role: 'P.5 Red Teacher', icon: Icons.school_outlined),
                  const ListHeader(title: 'Boarding Staff'),
                  _buildContactTile(context, name: 'Mrs. Mukasa Jane', role: 'Matron (Blue House)', icon: Icons.bed_outlined),
                  _buildContactTile(context, name: 'Mr. Musoke David', role: 'Patron (White House)', icon: Icons.bed_outlined),
                  const ListHeader(title: 'Parents'),
                  _buildContactTile(context, name: 'Mr. Kamau (John\'s Parent)', role: 'Parent - P.4 Blue', icon: Icons.person_outline),
                  _buildContactTile(context, name: 'Mrs. Zziwa (Mary\'s Parent)', role: 'Parent - P.5 Red', icon: Icons.person_outline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStaffContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Staff Directory',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  _buildContactTile(context, name: 'Dr. Ssempijja Ronald', role: 'Head Teacher', icon: Icons.person_pin_outlined),
                  _buildContactTile(context, name: 'Mr. Mwesigwa Isaac', role: 'Dean of Studies', icon: Icons.assignment_outlined),
                  _buildContactTile(context, name: 'Administration', role: 'School Office', icon: Icons.admin_panel_settings_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required String name,
    required String role,
    required IconData icon,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(role),
      trailing: const Icon(Icons.chat_bubble_outline, size: 20),
      onTap: () {
        Navigator.pop(context);
        _openThread(
          context,
          ChatThread(
            id: 'new_${name.hashCode}',
            participantName: name,
            lastMessage: '',
            lastMessageTime: DateTime.now(),
          ),
        );
      },
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

class ListHeader extends StatelessWidget {
  final String title;
  const ListHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}
