import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Institution-facing support source of truth.  Platform-internal messages
/// are deliberately never queried by this screen.
class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, dynamic>(
      (b) => b.state is AuthAuthenticated
          ? (b.state as AuthAuthenticated).user
          : null,
    );
    if (user == null) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    final schoolId = user.schoolId as String;
    final requests = FirebaseFirestore.instance
        .collection('institutions')
        .doc(schoolId)
        .collection('support_requests');
    final access = FirebaseFirestore.instance
        .collection('institutions')
        .doc(schoolId)
        .collection('support_access_requests')
        .where('status', isEqualTo: 'active');
    return Scaffold(
      appBar: const AdminAppBar(title: 'Support Center'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _NewRequestSheet(institutionId: schoolId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: requests
            .orderBy('updatedAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _State(
              icon: Icons.error_outline,
              title: 'Couldn’t load support requests',
              message: 'Check your connection and try again.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: SchoolPulseLoader());
          }
          final rows = snapshot.data!.docs;
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: access.snapshots(),
            builder: (context, accessSnapshot) {
              final active = accessSnapshot.data?.docs ?? const [];
              final counts = <String, int>{};
              for (final row in rows) {
                final status = row.data()['status'] as String? ?? 'submitted';
                counts[status] = (counts[status] ?? 0) + 1;
              }
              return RefreshIndicator(
                onRefresh: () async {},
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (active.isNotEmpty)
                      ...active.map(
                        (doc) => _SupportAccessBanner(
                          institutionId: schoolId,
                          request: doc,
                        ),
                      ),
                    Text(
                      'Get help from School Pulse',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track official support conversations and temporary access approvals.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Count(
                          label: 'Open',
                          count:
                              (counts['submitted'] ?? 0) +
                              (counts['open'] ?? 0) +
                              (counts['investigating'] ?? 0),
                        ),
                        _Count(
                          label: 'Waiting for us',
                          count: counts['waiting_for_institution'] ?? 0,
                        ),
                        _Count(
                          label: 'Waiting for School Pulse',
                          count: counts['waiting_for_school_pulse'] ?? 0,
                        ),
                        _Count(
                          label: 'Urgent',
                          count: rows
                              .where(
                                (e) => [
                                  'urgent',
                                  'critical',
                                ].contains(e.data()['priority']),
                              )
                              .length,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          'Your requests',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showHelp(context),
                          child: const Text('Help & guides'),
                        ),
                      ],
                    ),
                    if (rows.isEmpty)
                      const _State(
                        icon: Icons.support_agent,
                        title: 'No support requests yet',
                        message:
                            'Create a request to contact School Pulse support.',
                      )
                    else
                      ...rows.map(
                        (doc) =>
                            _RequestCard(institutionId: schoolId, row: doc),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showHelp(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Help & documentation'),
      content: const Text(
        'Use the relevant module’s setup guidance for staff, students, attendance, reports, integrations, security, and subscription. Include the affected module in your request so support can help faster.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.institutionId, required this.row});
  final String institutionId;
  final QueryDocumentSnapshot<Map<String, dynamic>> row;
  @override
  Widget build(BuildContext context) {
    final d = row.data();
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupportRequestDetailScreen(
              institutionId: institutionId,
              requestId: row.id,
            ),
          ),
        ),
        leading: Icon(_icon(d['moduleKey'] as String?)),
        title: Text(d['subject'] as String? ?? 'Support request'),
        subtitle: Text(
          '${d['category'] ?? 'Other'} • ${_label(d['status'] as String?)}',
        ),
        trailing: Chip(label: Text(_label(d['priority'] as String?))),
      ),
    );
  }

  IconData _icon(String? module) => module == 'attendance'
      ? Icons.fact_check_outlined
      : Icons.support_agent_outlined;
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.count});
  final String label;
  final int count;
  @override
  Widget build(BuildContext context) => Chip(label: Text('$count $label'));
}

class _State extends StatelessWidget {
  const _State({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title, message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Center(
      child: Column(
        children: [
          Icon(icon, size: 42),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _SupportAccessBanner extends StatelessWidget {
  const _SupportAccessBanner({
    required this.institutionId,
    required this.request,
  });
  final String institutionId;
  final QueryDocumentSnapshot<Map<String, dynamic>> request;
  @override
  Widget build(BuildContext context) {
    final d = request.data();
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Pulse Support Access Active',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text('Reason: ${d['reason'] ?? 'Support diagnostics'}'),
            Text('Expires: ${_date(d['expiresAt'])}'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => FirebaseFunctions.instance
                    .httpsCallable('decideSupportAccess')
                    .call({
                      'institutionId': institutionId,
                      'supportAccessRequestId': request.id,
                      'decision': 'revoked',
                    }),
                child: const Text('Revoke access'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportRequestDetailScreen extends StatelessWidget {
  const SupportRequestDetailScreen({
    super.key,
    required this.institutionId,
    required this.requestId,
  });
  final String institutionId, requestId;
  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('institutions')
        .doc(institutionId)
        .collection('support_requests')
        .doc(requestId);
    return Scaffold(
      appBar: const AdminAppBar(title: 'Support request'),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ref.snapshots(),
        builder: (context, s) {
          if (!s.hasData) return const Center(child: SchoolPulseLoader());
          if (!s.data!.exists) {
            return const _State(
              icon: Icons.search_off,
              title: 'Request unavailable',
              message: 'It may have been removed or you no longer have access.',
            );
          }
          final d = s.data!.data()!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                d['subject'] ?? 'Support request',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(_label(d['status']))),
                  Chip(label: Text(_label(d['priority']))),
                  Chip(label: Text(d['moduleKey'] ?? 'other')),
                ],
              ),
              const SizedBox(height: 16),
              Text(d['description'] ?? ''),
              if ((d['attachments'] as List? ?? const []).isNotEmpty)
                _Section(
                  title: 'Attachments',
                  text: (d['attachments'] as List)
                      .map((e) => e is Map ? e['name'] : e.toString())
                      .join('\n'),
                ),
              if ((d['reproductionSteps'] ?? '').toString().isNotEmpty)
                _Section(
                  title: 'Steps to reproduce',
                  text: d['reproductionSteps'],
                ),
              if ((d['expectedBehavior'] ?? '').toString().isNotEmpty)
                _Section(title: 'Expected', text: d['expectedBehavior']),
              if ((d['actualBehavior'] ?? '').toString().isNotEmpty)
                _Section(title: 'Actual', text: d['actualBehavior']),
              _Thread(institutionId: institutionId, requestId: requestId),
              const SizedBox(height: 12),
              _ReplyBox(institutionId: institutionId, requestId: requestId),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _status(context, 'reopened'),
                    child: const Text('Reopen'),
                  ),
                  OutlinedButton(
                    onPressed: () => _status(context, 'closed'),
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () => _status(context, 'cancelled'),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _status(BuildContext c, String status) => FirebaseFunctions
      .instance
      .httpsCallable('changeInstitutionSupportStatus')
      .call({
        'institutionId': institutionId,
        'supportRequestId': requestId,
        'status': status,
      })
      .then((_) {});
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.text});
  final String title, text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        Text(text),
      ],
    ),
  );
}

class _Thread extends StatelessWidget {
  const _Thread({required this.institutionId, required this.requestId});
  final String institutionId, requestId;
  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('institutions')
        .doc(institutionId)
        .collection('support_requests')
        .doc(requestId)
        .collection('responses')
        .where('visibility', isEqualTo: 'institution_visible')
        .orderBy('createdAt');
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, s) {
        if (!s.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: SchoolPulseLoader(),
          );
        }
        if (s.data!.docs.isEmpty) {
          return const _Section(title: 'Conversation', text: 'No replies yet.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Conversation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...s.data!.docs.map((e) {
              final d = e.data();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(d['authorDisplayName'] ?? 'Support'),
                subtitle: Text(d['body'] ?? ''),
              );
            }),
          ],
        );
      },
    );
  }
}

class _ReplyBox extends StatefulWidget {
  const _ReplyBox({required this.institutionId, required this.requestId});
  final String institutionId, requestId;
  @override
  State<_ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<_ReplyBox> {
  final controller = TextEditingController();
  bool saving = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: TextField(
      controller: controller,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Add information',
        suffixIcon: IconButton(
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.send),
          onPressed: saving
              ? null
              : () async {
                  if (controller.text.trim().isEmpty) return;
                  setState(() => saving = true);
                  try {
                    await FirebaseFunctions.instance
                        .httpsCallable('addInstitutionSupportResponse')
                        .call({
                          'institutionId': widget.institutionId,
                          'supportRequestId': widget.requestId,
                          'body': controller.text,
                        });
                    controller.clear();
                  } finally {
                    if (mounted) setState(() => saving = false);
                  }
                },
        ),
      ),
    ),
  );
}

class _NewRequestSheet extends StatefulWidget {
  const _NewRequestSheet({required this.institutionId});
  final String institutionId;
  @override
  State<_NewRequestSheet> createState() => _NewRequestSheetState();
}

class _NewRequestSheetState extends State<_NewRequestSheet> {
  final subject = TextEditingController(),
      description = TextEditingController(),
      steps = TextEditingController(),
      expected = TextEditingController(),
      actual = TextEditingController();
  String module = 'attendance', category = 'Bug', priority = 'normal';
  bool saving = false;
  PlatformFile? file;
  @override
  void dispose() {
    for (final c in [subject, description, steps, expected, actual]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.of(context).viewInsets.bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New support request',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          DropdownButtonFormField(
            initialValue: module,
            items: const [
              'attendance',
              'students',
              'staff',
              'finance',
              'reports',
              'messaging',
              'security',
              'integrations',
              'payments',
              'offline_sync',
              'other',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => module = v!),
            decoration: const InputDecoration(labelText: 'Affected module'),
          ),
          DropdownButtonFormField(
            initialValue: category,
            items: const [
              'Login / Authentication',
              'Attendance',
              'Finance',
              'Reports',
              'Integrations',
              'Security',
              'Data Import',
              'Data Export',
              'Performance',
              'Offline Sync',
              'Bug',
              'Feature Question',
              'Training',
              'Billing Question',
              'Other',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => category = v!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          TextField(
            controller: subject,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          TextField(
            controller: description,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Describe the issue'),
          ),
          TextField(
            controller: steps,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Steps to reproduce'),
          ),
          TextField(
            controller: expected,
            decoration: const InputDecoration(labelText: 'Expected behavior'),
          ),
          TextField(
            controller: actual,
            decoration: const InputDecoration(labelText: 'Actual behavior'),
          ),
          DropdownButtonFormField(
            initialValue: priority,
            items: const ['low', 'normal', 'high', 'urgent']
                .map((v) => DropdownMenuItem(value: v, child: Text(_label(v))))
                .toList(),
            onChanged: (v) => setState(() => priority = v!),
            decoration: const InputDecoration(labelText: 'Priority'),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  final picked = await FilePicker.pickFiles(
                    withData: true,
                    type: FileType.custom,
                    allowedExtensions: [
                      'png',
                      'jpg',
                      'jpeg',
                      'webp',
                      'pdf',
                      'csv',
                    ],
                  );
                  if (picked?.files.singleOrNull != null) {
                    setState(() => file = picked!.files.single);
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: Text(
                  file == null ? 'Attach image, PDF or CSV' : file!.name,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: saving ? null : _submit,
                child: Text(saving ? 'Submitting…' : 'Submit'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  Future<void> _submit() async {
    if (subject.text.trim().isEmpty || description.text.trim().isEmpty) return;
    setState(() => saving = true);
    try {
      final id = 'SUP-${DateTime.now().microsecondsSinceEpoch}';
      await FirebaseFunctions.instance
          .httpsCallable('submitInstitutionSupportRequest')
          .call({
            'institutionId': widget.institutionId,
            'supportRequestId': id,
            'moduleKey': module,
            'category': category,
            'subject': subject.text,
            'description': description.text,
            'reproductionSteps': steps.text,
            'expectedBehavior': expected.text,
            'actualBehavior': actual.text,
            'priority': priority,
            'affectedPlatform': 'School Pulse',
          });
      if (file?.bytes != null) {
        final ext = file!.extension?.toLowerCase() ?? '';
        final ok =
            ['png', 'jpg', 'jpeg', 'webp', 'pdf', 'csv'].contains(ext) &&
            file!.size <= 10 * 1024 * 1024;
        if (!ok) {
          throw Exception(
            'Attachments must be PNG, JPG, WEBP, PDF or CSV under 10 MB.',
          );
        }
        final path =
            'institutions/${widget.institutionId}/support/$id/${file!.name}';
        await FirebaseStorage.instance
            .ref(path)
            .putData(file!.bytes!, SettableMetadata(contentType: _mime(ext)));
        await FirebaseFunctions.instance
            .httpsCallable('addInstitutionSupportAttachment')
            .call({
              'institutionId': widget.institutionId,
              'supportRequestId': id,
              'name': file!.name,
              'path': path,
              'contentType': _mime(ext),
            });
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not submit request: $e')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  String _mime(String ext) => ['png', 'jpg', 'jpeg', 'webp'].contains(ext)
      ? 'image/${ext == 'jpg' ? 'jpeg' : ext}'
      : ext == 'pdf'
      ? 'application/pdf'
      : 'text/csv';
}

String _label(dynamic value) => (value?.toString() ?? 'Unknown')
    .replaceAll('_', ' ')
    .split(' ')
    .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
    .join(' ');
String _date(dynamic value) => value is Timestamp
    ? '${value.toDate().toLocal()}'
    : 'the configured expiry';
