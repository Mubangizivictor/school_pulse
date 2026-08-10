import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/notifications/data/repositories/staff_alerts_repository.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';
import 'package:school_pulse/injection_container.dart' as di;

class _Recipient {
  final String id;
  final String name;
  final String subtitle;

  const _Recipient({
    required this.id,
    required this.name,
    required this.subtitle,
  });
}

class MessagesScreen extends StatefulWidget {
  final String? initialRecipientId;
  final String? initialRecipientName;
  final String? initialRecipientRole;

  const MessagesScreen({
    super.key,
    this.initialRecipientId,
    this.initialRecipientName,
    this.initialRecipientRole,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialRecipientId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showComposeDialog(
          context,
          initialRecipient: _Recipient(
            id: widget.initialRecipientId!,
            name: widget.initialRecipientName ?? 'Recipient',
            subtitle: widget.initialRecipientRole ?? '',
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final user = authState.user;
    final isStaff = user.role != UserRole.parent;
    final userId = user.id;

    return Scaffold(
      appBar: isStaff
          ? AppBar(
              title: const Text('Messages'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_square),
                  onPressed: () => _showComposeDialog(context),
                ),
              ],
            )
          : StudentAppBar(
              title: 'Messages',
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_square),
                  onPressed: () => _showComposeDialog(context),
                ),
              ],
            ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SchoolPulseLoader());
          }

          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return EmptyState(
              icon: Icons.forum_outlined,
              title: 'No messages yet',
              message: 'Direct messages from the school will appear here.',
              ctaLabel: 'New Message',
              onCtaPressed: () => _showComposeDialog(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return AppCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.message_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    data['title'] ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['body'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTimestamp(
                      (data['timestamp'] as Timestamp?)?.toDate(),
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  onTap: () => _showViewDialog(
                    context,
                    docs[index].id,
                    userId,
                    data['title'],
                    data['body'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showViewDialog(
    BuildContext context,
    String alertId,
    String userId,
    String? title,
    String? body,
  ) {
    StaffAlertsRepository().markRead(alertId, userId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Message'),
        content: Text(body ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<List<_Recipient>> _loadRecipients() async {
    // Read before the await below - using context after an async gap is
    // what the lint is (rightly) suspicious of, even though this State's
    // context can't meaningfully become invalid mid-fetch here.
    final currentUserId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.id;

    final results = await Future.wait([
      di.sl<GetStaffMembers>()(NoParams()),
      di.sl<GetAllAccessCodes>()(),
    ]);

    final staff =
        (results[0] as dynamic).fold(
              (_) => const <UserEntity>[],
              (List<UserEntity> s) => s.where((m) => m.isActive).toList(),
            )
            as List<UserEntity>;

    final codes =
        (results[1] as dynamic).fold(
              (_) => const <ParentAccessCode>[],
              (List<ParentAccessCode> c) => c.where((c) => c.isActive).toList(),
            )
            as List<ParentAccessCode>;

    return [
      ...staff
          .where((s) => s.id != currentUserId)
          .map(
            (s) => _Recipient(
              id: s.id,
              name: s.name,
              subtitle: UserRoleDisplay.name(s.role),
            ),
          ),
      ...codes
          .where((c) => 'parent_${c.parentCode}' != currentUserId)
          .map(
            (c) => _Recipient(
              id: 'parent_${c.parentCode}',
              name: c.parentName ?? 'Parent',
              subtitle: 'Parent of ${c.studentNames.join(", ")}',
            ),
          ),
    ];
  }

  void _showComposeDialog(
    BuildContext context, {
    _Recipient? initialRecipient,
  }) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    _Recipient? selected = initialRecipient;
    String query = '';
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<_Recipient>>(
        future: _loadRecipients(),
        builder: (dialogContext, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              selected == null) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: SchoolPulseLoader()),
              ),
            );
          }
          final recipients = snapshot.data ?? const [];

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final filtered = query.isEmpty
                  ? recipients
                  : recipients
                        .where(
                          (r) =>
                              r.name.toLowerCase().contains(
                                query.toLowerCase(),
                              ) ||
                              r.subtitle.toLowerCase().contains(
                                query.toLowerCase(),
                              ),
                        )
                        .toList();

              return AlertDialog(
                title: Text(
                  selected == null
                      ? 'New Message'
                      : 'Message to ${selected!.name}',
                ),
                content: SizedBox(
                  width: 420,
                  height: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected == null) ...[
                        AppSearchField(
                          hintText: 'Search staff or parents...',
                          onChanged: (v) => setDialogState(() => query = v),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final r = filtered[index];
                              return ListTile(
                                title: Text(r.name),
                                subtitle: Text(r.subtitle),
                                onTap: () => setDialogState(() => selected = r),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: InputChip(
                                label: Text(selected!.name),
                                onDeleted: initialRecipient != null
                                    ? null
                                    : () =>
                                          setDialogState(() => selected = null),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TextField(
                            controller: bodyController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              labelText: 'Message',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  if (selected != null)
                    FilledButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              if (titleController.text.trim().isEmpty ||
                                  bodyController.text.trim().isEmpty)
                                return;
                              setDialogState(() => isSending = true);
                              try {
                                // Capped so a hung write can never leave the
                                // button spinning forever with no way out.
                                await NotificationService()
                                    .sendDirectNotification(
                                      userId: selected!.id,
                                      title: titleController.text.trim(),
                                      body: bodyController.text.trim(),
                                    )
                                    .timeout(const Duration(seconds: 15));
                                if (dialogContext.mounted)
                                  Navigator.pop(dialogContext);
                              } catch (e) {
                                setDialogState(() => isSending = false);
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send'),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
