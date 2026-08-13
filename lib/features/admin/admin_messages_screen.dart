import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
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

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: 'Messages',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            tooltip: 'New Message',
            onPressed: () => _showComposeDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .where('userId', isNull: false)
            .orderBy('timestamp', descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SchoolPulseLoader());
          }
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return EmptyState(
              icon: Icons.forum_outlined,
              title: 'No direct messages yet',
              message:
                  'Send an individual message to a parent or staff member.',
              ctaLabel: 'New Message',
              onCtaPressed: () => _showComposeDialog(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final recipientId = data['userId'] as String? ?? '';
              final isParent = recipientId.startsWith('parent_');
              return AppCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isParent ? Colors.purple : Colors.blue)
                        .withValues(alpha: 0.1),
                    child: Icon(
                      isParent ? Icons.family_restroom : Icons.badge_outlined,
                      color: isParent ? Colors.purple : Colors.blue,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    data['title'] as String? ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['body'] as String? ?? '',
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
                ),
              );
            },
          );
        },
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
      ...staff.map(
        (s) => _Recipient(
          id: s.id,
          name: s.name,
          subtitle: UserRoleDisplay.name(s.role),
        ),
      ),
      ...codes.map(
        (c) => _Recipient(
          id: 'parent_${c.parentCode}',
          name: c.parentName ?? 'Unnamed Parent',
          subtitle: 'Parent • ${c.studentNames.join(', ')}',
        ),
      ),
    ];
  }

  void _showComposeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    _Recipient? selected;
    String query = '';
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<_Recipient>>(
        future: _loadRecipients(),
        builder: (dialogContext, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
                          (r) => r.name.toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                        )
                        .toList();

              return AlertDialog(
                title: const Text('New Message'),
                content: SizedBox(
                  width: 420,
                  height: 460,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected == null) ...[
                        Text(
                          'To:',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search staff or parents...',
                            prefixIcon: Icon(Icons.search, size: 20),
                            isDense: true,
                          ),
                          onChanged: (v) => setDialogState(() => query = v),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: filtered.isEmpty
                              ? const Center(child: Text('No matches'))
                              : ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final r = filtered[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(r.name),
                                      subtitle: Text(
                                        r.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () =>
                                          setDialogState(() => selected = r),
                                    );
                                  },
                                ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Chip(
                                label: Text(selected!.name),
                                onDeleted: () =>
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
                                  bodyController.text.trim().isEmpty) {
                                return;
                              }
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
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
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
