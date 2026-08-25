import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

class BroadcastSmsScreen extends StatefulWidget {
  const BroadcastSmsScreen({super.key});

  @override
  State<BroadcastSmsScreen> createState() => _BroadcastSmsScreenState();
}

class _BroadcastSmsScreenState extends State<BroadcastSmsScreen> {
  final _messageController = TextEditingController();
  final _titleController = TextEditingController();
  final Set<String> _selectedRecipients = {'Parents'};
  final Set<String> _selectedChannels = {'Push'}; // Default to Push
  final Set<String> _selectedClasses = {};
  bool _isScheduled = false;
  DateTime? _scheduledDateTime;

  @override
  void dispose() {
    _messageController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: const AdminAppBar(title: 'Broadcast Center'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildChannelSelector(),
                        const SizedBox(height: 24),
                        _buildComposer(),
                        const SizedBox(height: 24),
                        _buildRecipientSelector(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildChannelStats(),
                        const SizedBox(height: 24),
                        _buildRecentBroadcasts(),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildChannelSelector(),
                  const SizedBox(height: 16),
                  _buildComposer(),
                  const SizedBox(height: 16),
                  _buildRecipientSelector(),
                  const SizedBox(height: 16),
                  _buildRecentBroadcasts(),
                ],
              ),
      ),
    );
  }

  Widget _buildChannelSelector() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Channels',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ChannelTile(
                icon: Icons.notifications_active,
                label: 'Push & In-App',
                description: 'Free • System wide',
                isSelected: _selectedChannels.contains('Push'),
                onTap: () => _toggleChannel('Push'),
              ),
              const SizedBox(width: 12),
              _ChannelTile(
                icon: Icons.sms,
                label: 'SMS Text',
                description: 'Not connected yet',
                isSelected: false,
                isDisabled: true,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'SMS isn\'t connected to a provider yet. Ask your developer to wire up '
                      'Twilio/Africa\'s Talking, or use Push & In-App for now.',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleChannel(String channel) {
    setState(() {
      if (_selectedChannels.contains(channel)) {
        if (_selectedChannels.length > 1) _selectedChannels.remove(channel);
      } else {
        _selectedChannels.add(channel);
      }
    });
  }

  Widget _buildChannelStats() {
    if (_selectedChannels.contains('SMS')) {
      return _buildSmsCreditsCard();
    }
    return AppCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          const Icon(Icons.bolt, size: 32, color: Colors.black),
          const SizedBox(height: 12),
          const Text(
            'Push Delivery',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '99.9% Reliable • Instant',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    final charCount = _messageController.text.length;
    final isPush = _selectedChannels.contains('Push');
    final isSms = _selectedChannels.contains('SMS');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPush ? Icons.campaign : Icons.edit_note,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isPush ? 'Announcement Details' : 'Compose SMS',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isPush) ...[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Headline (e.g. Urgent Notice)',
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _messageController,
            maxLines: 4,
            maxLength: isSms ? 480 : 1000,
            decoration: InputDecoration(
              hintText: 'Type your message here...',
              labelText: 'Message Body',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: Theme.of(context).colorScheme.surface,
              filled: true,
              counterText: '',
            ),
            onChanged: (val) => setState(() {}),
          ),
          if (isSms) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_messageController.text.length / 160).ceil()} SMS Units per recipient',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$charCount / 480',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Switch(
                  value: _isScheduled,
                  onChanged: (val) => setState(() => _isScheduled = val),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Schedule for later',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _isScheduled
                            ? 'Message will be sent at selected time'
                            : 'Message will be sent immediately',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (_isScheduled)
                  FilledButton.tonalIcon(
                    onPressed: _selectDateTime,
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(
                      _scheduledDateTime == null
                          ? 'Set Time'
                          : '${_scheduledDateTime!.day}/${_scheduledDateTime!.month} ${_scheduledDateTime!.hour.toString().padLeft(2, '0')}:${_scheduledDateTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            onPressed: _messageController.text.trim().isEmpty
                ? null
                : _handleSend,
            label: _isScheduled ? 'Schedule Broadcast' : 'Send Broadcast Now',
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend() async {
    final schoolId = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId
        : null;

    if (_isScheduled && _scheduledDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time for scheduling.'),
        ),
      );
      return;
    }

    if (_selectedRecipients.contains('Specific Class Parents') &&
        _selectedClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one class to target.')),
      );
      return;
    }

    final title = _titleController.text.isEmpty
        ? 'School Announcement'
        : _titleController.text;
    final body = _messageController.text;
    final targets = [
      ..._selectedRecipients.where((r) => r != 'Specific Class Parents'),
      ..._selectedClasses.map((c) => 'Class:$c'),
    ];
    final isPush = _selectedChannels.contains('Push');
    final scheduleDate = _isScheduled ? _scheduledDateTime : null;

    // Show loading. A dedicated navigator key would be more robust still, but
    // capturing this dialog's own context (rather than reusing the screen's)
    // means the pop below targets the dialog route specifically even if the
    // screen underneath it rebuilds or navigates during the await.
    late BuildContext loadingDialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        loadingDialogContext = dialogContext;
        return const Center(child: SchoolPulseLoader());
      },
    );
    var dialogClosed = false;
    void closeLoadingDialog() {
      if (dialogClosed) return;
      dialogClosed = true;
      Navigator.of(loadingDialogContext).pop();
    }

    try {
      // Campaigns delegate to notification_requests server-side. This avoids
      // the old topic broadcast path, which had no recipient snapshot or
      // per-recipient read/delivery state.
      final audience = _campaignAudience();
      final draft = await FirebaseFunctions.instance
          .httpsCallable('saveCommunicationDraft')
          .call({
            'schoolId': schoolId,
            'campaign': {
              'title': title,
              'body': body,
              'shortSummary': body.length > 180 ? body.substring(0, 180) : body,
              'communicationType': 'announcement',
              'priority': 'medium',
              'audienceDefinition': audience,
              'deliveryChannels': [if (isPush) 'inApp', if (isPush) 'push'],
              if (scheduleDate != null)
                'scheduledAt': scheduleDate.toUtc().toIso8601String(),
            },
          })
          .timeout(const Duration(seconds: 15));
      final campaignId = (draft.data as Map)['campaignId'] as String;
      if (!_isScheduled) {
        await FirebaseFunctions.instance
            .httpsCallable('publishCommunicationCampaign')
            .call({'schoolId': schoolId, 'campaignId': campaignId})
            .timeout(const Duration(seconds: 15));
      }

      di.sl<AuditRepository>().logAction(
        schoolId: schoolId,
        title: _isScheduled ? 'Broadcast Scheduled' : 'Broadcast Sent',
        description:
            '"$title" sent to ${targets.join(', ')} via ${_selectedChannels.join(' & ')}.',
        iconName: 'send',
        colorHex: 'FF9C27B0',
        userId: FirebaseAuth.instance.currentUser?.uid,
      );

      closeLoadingDialog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isScheduled
                  ? 'Broadcast scheduled for ${_scheduledDateTime.toString()}'
                  : 'Broadcast sent successfully via ${_selectedChannels.join(" & ")}',
            ),
            backgroundColor: Colors.black,
          ),
        );
        _messageController.clear();
        _titleController.clear();
        setState(() {
          _isScheduled = false;
          _scheduledDateTime = null;
          _selectedClasses.clear();
        });
      }
    } catch (e) {
      closeLoadingDialog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.black),
        );
      }
    }
  }

  Map<String, dynamic> _campaignAudience() {
    final definitions = <Map<String, dynamic>>[];
    for (final recipient in _selectedRecipients) {
      switch (recipient) {
        case 'Parents':
          definitions.add({'kind': 'all_parents'});
        case 'All Staff':
          definitions.add({'kind': 'all_staff'});
        case 'Teachers Only':
          definitions.add({
            'kind': 'roles',
            'roles': ['teacher'],
          });
        case 'Bursars & Admin':
          definitions.add({
            'kind': 'roles',
            'roles': ['bursar', 'schoolAdmin'],
          });
        case 'Matrons (Girls)':
          definitions.add({
            'kind': 'roles',
            'roles': ['boardingMatron'],
          });
        case 'Patrons (Boys)':
          definitions.add({
            'kind': 'roles',
            'roles': ['boardingPatron'],
          });
        case 'Specific Class Parents':
          definitions.add({
            'kind': 'class_parents',
            'classNames': _selectedClasses.toList(),
          });
      }
    }
    return definitions.length == 1
        ? definitions.single
        : {'kind': 'anyOf', 'definitions': definitions};
  }

  Widget _buildRecipientSelector() {
    final groups = [
      {'id': 'Parents', 'icon': Icons.family_restroom},
      {'id': 'All Staff', 'icon': Icons.people},
      {'id': 'Teachers Only', 'icon': Icons.school},
      {'id': 'Bursars & Admin', 'icon': Icons.admin_panel_settings},
      {'id': 'Matrons (Girls)', 'icon': Icons.female},
      {'id': 'Patrons (Boys)', 'icon': Icons.male},
      {'id': 'Specific Class Parents', 'icon': Icons.class_},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Audience',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: groups.map((group) {
              final id = group['id'] as String;
              final icon = group['icon'] as IconData;
              final isSelected = _selectedRecipients.contains(id);
              return FilterChip(
                avatar: Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
                label: Text(id),
                selected: isSelected,
                selectedColor: Theme.of(context).colorScheme.primary,
                checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedRecipients.add(id);
                    } else {
                      _selectedRecipients.remove(id);
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (_selectedRecipients.contains('Specific Class Parents')) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Classes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildClassChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildClassChips() {
    final schoolId = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId
        : null;
    if (schoolId == null) return const SizedBox.shrink();

    // Real classes from Structure, not a hardcoded P.1-P.7 list - a school
    // using secondary (S.1-S.6) or another naming scheme was previously
    // offered classes that don't exist for them.
    return StreamBuilder<List<SchoolClass>>(
      stream: di.sl<StructureRepository>().watchClasses(schoolId),
      builder: (context, snapshot) {
        final classes = snapshot.data ?? const [];
        if (snapshot.connectionState == ConnectionState.waiting &&
            classes.isEmpty) {
          return const SizedBox(
            height: 32,
            child: Center(child: SchoolPulseLoader()),
          );
        }
        if (classes.isEmpty) {
          return const Text(
            'No classes configured yet.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: classes.where((c) => c.isActive).map((c) {
            return ChoiceChip(
              label: Text(c.name, style: const TextStyle(fontSize: 12)),
              selected: _selectedClasses.contains(c.name),
              onSelected: (v) => setState(() {
                if (v) {
                  _selectedClasses.add(c.name);
                } else {
                  _selectedClasses.remove(c.name);
                }
              }),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSmsCreditsCard() {
    return AppCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 32,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SMS Credits Available',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('schools')
                .doc(
                  context.select<AuthBloc, String?>((bloc) {
                    final state = bloc.state;
                    return state is AuthAuthenticated
                        ? state.user.schoolId
                        : null;
                  }),
                )
                .collection('config')
                .doc('system')
                .snapshots(),
            builder: (context, snapshot) {
              final credits =
                  (snapshot.data?.data()?['smsCredits'] as int?) ?? 0;
              return AnimatedNumberText(
                value: credits.toDouble(),
                suffix: ' Units',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SecondaryButton(
            label: 'Top Up Credits',
            onPressed: () => showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Top Up SMS Credits'),
                content: const Text(
                  'SMS credits are provisioned through your connected SMS gateway (Twilio). '
                  'Manage the connection and credit balance from System Configuration → External Integrations.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.go('/staff/admin/config');
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            ),
            icon: Icons.add_card,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBroadcasts() {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final schoolId = context.select<AuthBloc, String?>((bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user.schoolId : null;
    });

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Broadcasts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                TextButton(
                  onPressed: () => context.go('/staff/admin/broadcast-history'),
                  child: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('alerts')
                .where('schoolId', isEqualTo: schoolId)
                .where('type', whereIn: ['Push', 'SMS'])
                .orderBy('timestamp', descending: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: SchoolPulseLoader()),
                );
              }
              final docs = snapshot.data?.docs ?? const [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No broadcasts sent yet',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final targets = List<String>.from(
                    data['targets'] as List? ?? const [],
                  );
                  final to = targets.isEmpty ? 'Everyone' : targets.join(', ');
                  final msg = data['body'] as String? ?? '';
                  final status = data['status'] as String? ?? 'sent';
                  final isFailed = status == 'failed';
                  final isPush = data['type'] == 'Push';
                  final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    title: Row(
                      children: [
                        Icon(
                          isPush ? Icons.bolt : Icons.sms,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            to,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (isFailed
                                ? semantic.error
                                : semantic.success),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isFailed
                                  ? semantic.error
                                  : semantic.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        msg,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    trailing: Text(
                      timestamp != null
                          ? DateFormat('MMM dd').format(timestamp)
                          : '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ChannelTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDisabled
        ? Theme.of(context).colorScheme.outline
        : (isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary);
    return Expanded(
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
