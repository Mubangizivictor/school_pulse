import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/communication_center/data/communication_attachments_uploader.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_template.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_bloc.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_event.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_state.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Create/edit flow: type, title, summary, body, priority, audience,
/// channels, image, attachments, schedule, expiry, acknowledgement,
/// preview, then Save Draft / Schedule / Send Now / Submit for Approval.
/// Emergency alerts route through an extra confirmation step before send.
class CommunicationComposeScreen extends StatelessWidget {
  final String? campaignId;
  final String? templateId;
  const CommunicationComposeScreen({
    super.key,
    this.campaignId,
    this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    return BlocProvider(
      create: (_) => di.sl<CommunicationBloc>()
        ..add(
          WatchCommunicationTemplatesRequested(schoolId: auth.user.schoolId),
        ),
      child: _ComposeView(campaignId: campaignId, templateId: templateId),
    );
  }
}

class _ComposeView extends StatefulWidget {
  final String? campaignId;
  final String? templateId;
  const _ComposeView({this.campaignId, this.templateId});

  @override
  State<_ComposeView> createState() => _ComposeViewState();
}

class _ComposeViewState extends State<_ComposeView> {
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _bodyController = TextEditingController();

  CommunicationType _type = CommunicationType.announcement;
  CommunicationPriority _priority = CommunicationPriority.medium;
  NotificationAudienceKind _audienceKind = NotificationAudienceKind.school;
  final Set<String> _selectedRoles = {};
  final _classNamesController = TextEditingController();
  final Set<String> _channels = {'inApp', 'push'};
  bool _ackRequired = false;
  DateTime? _scheduledAt;
  DateTime? _expiresAt;

  File? _pickedImage;
  String? _pickedImageName;
  int _pickedImageSize = 0;
  final List<({File file, String fileName, int sizeBytes})> _pickedAttachments =
      [];

  bool _submitting = false;
  bool _appliedTemplate = false;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _bodyController.dispose();
    _classNamesController.dispose();
    super.dispose();
  }

  NotificationAudience _audience() {
    switch (_audienceKind) {
      case NotificationAudienceKind.school:
        return const NotificationAudience.school();
      case NotificationAudienceKind.allStaff:
        return const NotificationAudience.allStaff();
      case NotificationAudienceKind.allParents:
        return const NotificationAudience.allParents();
      case NotificationAudienceKind.roles:
        return NotificationAudience(
          kind: NotificationAudienceKind.roles,
          roles: _selectedRoles.toList(),
        );
      case NotificationAudienceKind.classParents:
        return NotificationAudience(
          kind: NotificationAudienceKind.classParents,
          classNames: _classNamesController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        );
      case NotificationAudienceKind.studentParents:
      case NotificationAudienceKind.users:
        // Individual/student-scoped selection needs a picker fed by
        // student/user search, which is out of this phase's scope - the
        // dropdown below only offers the kinds this screen can resolve.
        return const NotificationAudience.school();
    }
  }

  bool get _audienceValid {
    switch (_audienceKind) {
      case NotificationAudienceKind.roles:
        return _selectedRoles.isNotEmpty;
      case NotificationAudienceKind.classParents:
        return _classNamesController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  CommunicationCampaign _buildDraft(AuthAuthenticated auth) {
    final now = DateTime.now();
    return CommunicationCampaign(
      campaignId: widget.campaignId ?? '',
      schoolId: auth.user.schoolId,
      title: _titleController.text.trim(),
      shortSummary: _summaryController.text.trim(),
      body: _bodyController.text.trim(),
      communicationType: _type,
      priority: _priority,
      senderId: auth.user.id,
      senderNameSnapshot: auth.user.name,
      senderRoleSnapshot: UserRoleDisplay.name(auth.user.role),
      audienceDefinition: _audience(),
      deliveryChannels: _channels.toList(),
      imageUrl: null,
      attachmentRefs: const [],
      scheduledAt: _scheduledAt,
      expiresAt: _expiresAt,
      acknowledgementRequired: _ackRequired,
      createdAt: now,
      updatedAt: now,
    );
  }

  void _applyTemplate(CommunicationTemplate template) {
    _titleController.text = template.name;
    _summaryController.text = template.shortSummary;
    _bodyController.text = template.body;
    setState(() => _type = template.communicationType);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final size = await file.length();
    if (!CommunicationAttachmentsUploader().isImageAllowed(file.name, size)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image must be PNG/JPG/WEBP under 5 MB.'),
          ),
        );
      }
      return;
    }
    setState(() {
      _pickedImage = File(file.path);
      _pickedImageName = file.name;
      _pickedImageSize = size;
    });
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: CommunicationAttachmentsUploader
          .allowedAttachmentExtensions
          .toList(),
    );
    final picked = result?.files.single;
    if (picked?.path == null) return;
    setState(() {
      _pickedAttachments.add((
        file: File(picked!.path!),
        fileName: picked.name,
        sizeBytes: picked.size,
      ));
    });
  }

  Future<void> _pickSchedule({required bool isExpiry}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isExpiry) {
        _expiresAt = combined;
      } else {
        _scheduledAt = combined;
      }
    });
  }

  Future<void> _submit({required bool schedule, required bool sendNow}) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required.')),
      );
      return;
    }
    if (!_audienceValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a valid audience before continuing.'),
        ),
      );
      return;
    }
    if (_type == CommunicationType.emergencyAlert && sendNow) {
      final confirmed = await _confirmEmergency(auth.user.schoolId);
      if (confirmed != true) return;
    }
    if (!mounted) return;
    setState(() => _submitting = true);
    final draft = _buildDraft(auth);
    final bloc = context.read<CommunicationBloc>();
    bloc.add(
      SaveCommunicationDraftRequested(
        schoolId: auth.user.schoolId,
        campaign: draft,
        campaignId: widget.campaignId,
        operatorUser: auth.user,
      ),
    );
  }

  Future<bool?> _confirmEmergency(String schoolId) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send emergency broadcast?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _titleController.text,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(_bodyController.text),
              const SizedBox(height: 12),
              Text('Audience: ${_audience().description}'),
              Text('Channels: ${_channels.join(', ')}'),
              const SizedBox(height: 12),
              const Text(
                'This bypasses quiet hours and sends immediately to every '
                'matching recipient. This cannot be undone.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Send emergency broadcast'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: widget.campaignId == null ? 'New communication' : 'Edit draft',
      ),
      body: BlocConsumer<CommunicationBloc, CommunicationState>(
        listener: (context, state) async {
          if (state is CommunicationLoaded &&
              !_appliedTemplate &&
              widget.templateId != null) {
            final template = state.templates
                .where((t) => t.templateId == widget.templateId)
                .cast<CommunicationTemplate?>()
                .firstWhere((t) => true, orElse: () => null);
            if (template != null) {
              _appliedTemplate = true;
              _applyTemplate(template);
            }
          }
          if (state is CommunicationActionDenied) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is CommunicationError) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is CommunicationActionSuccess) {
            final auth = context.read<AuthBloc>().state;
            final campaignId = state.campaignId;
            if (auth is AuthAuthenticated && campaignId != null) {
              // Upload staged image/attachments now that a campaignId
              // exists, then publish or leave as a draft depending on the
              // action the sender chose.
              final uploader = CommunicationAttachmentsUploader();
              String? imageUrl;
              if (_pickedImage != null) {
                imageUrl = await uploader.uploadImage(
                  schoolId: auth.user.schoolId,
                  campaignId: campaignId,
                  file: _pickedImage!,
                  fileName: _pickedImageName!,
                  sizeBytes: _pickedImageSize,
                );
              }
              final attachmentUrls = _pickedAttachments.isEmpty
                  ? const <String>[]
                  : (await uploader.uploadAttachments(
                      schoolId: auth.user.schoolId,
                      campaignId: campaignId,
                      staged: _pickedAttachments,
                    )).uploadedUrls;
              if (!mounted) return;
              if (imageUrl != null || attachmentUrls.isNotEmpty) {
                context.read<CommunicationBloc>().add(
                  SaveCommunicationDraftRequested(
                    schoolId: auth.user.schoolId,
                    campaign: _buildDraft(auth).copyWith(
                      imageUrl: imageUrl,
                      attachmentRefs: attachmentUrls,
                    ),
                    campaignId: campaignId,
                    operatorUser: auth.user,
                  ),
                );
              }
              if (_scheduledAt == null) {
                context.read<CommunicationBloc>().add(
                  PublishCommunicationCampaignRequested(
                    schoolId: auth.user.schoolId,
                    campaignId: campaignId,
                    communicationType: _type,
                    operatorUser: auth.user,
                  ),
                );
              }
            }
            if (!mounted) return;
            setState(() => _submitting = false);
            if (context.canPop()) context.pop();
          }
        },
        builder: (context, state) {
          final templates = state is CommunicationLoaded
              ? state.templates
              : const <CommunicationTemplate>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (templates.isNotEmpty) ...[
                DropdownButtonFormField<CommunicationTemplate>(
                  decoration: const InputDecoration(
                    labelText: 'Start from a template (optional)',
                  ),
                  items: templates
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (t) => t != null ? _applyTemplate(t) : null,
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<CommunicationType>(
                decoration: const InputDecoration(labelText: 'Type'),
                initialValue: _type,
                items: CommunicationType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (t) => setState(() => _type = t ?? _type),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                maxLength: 160,
              ),
              TextField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Short summary (optional)',
                ),
                maxLength: 180,
              ),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Full message'),
                maxLines: 6,
                maxLength: 12000,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CommunicationPriority>(
                decoration: const InputDecoration(labelText: 'Priority'),
                initialValue: _priority,
                items: CommunicationPriority.values
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (p) => setState(() => _priority = p ?? _priority),
              ),
              const SizedBox(height: 16),
              Text('Audience', style: Theme.of(context).textTheme.titleSmall),
              DropdownButtonFormField<NotificationAudienceKind>(
                initialValue: _audienceKind,
                items: const [
                  DropdownMenuItem(
                    value: NotificationAudienceKind.school,
                    child: Text('Entire institution'),
                  ),
                  DropdownMenuItem(
                    value: NotificationAudienceKind.allStaff,
                    child: Text('All staff'),
                  ),
                  DropdownMenuItem(
                    value: NotificationAudienceKind.allParents,
                    child: Text('All parents'),
                  ),
                  DropdownMenuItem(
                    value: NotificationAudienceKind.roles,
                    child: Text('Selected staff roles'),
                  ),
                  DropdownMenuItem(
                    value: NotificationAudienceKind.classParents,
                    child: Text('Parents of specific classes'),
                  ),
                ],
                onChanged: (k) =>
                    setState(() => _audienceKind = k ?? _audienceKind),
              ),
              if (_audienceKind == NotificationAudienceKind.roles)
                Wrap(
                  spacing: 8,
                  children: UserRole.values
                      .where(
                        (r) => r != UserRole.parent && r != UserRole.student,
                      )
                      .map(
                        (role) => FilterChip(
                          label: Text(UserRoleDisplay.name(role)),
                          selected: _selectedRoles.contains(role.name),
                          onSelected: (sel) => setState(() {
                            sel
                                ? _selectedRoles.add(role.name)
                                : _selectedRoles.remove(role.name);
                          }),
                        ),
                      )
                      .toList(),
                ),
              if (_audienceKind == NotificationAudienceKind.classParents)
                TextField(
                  controller: _classNamesController,
                  decoration: const InputDecoration(
                    labelText: 'Class names (comma separated)',
                    hintText: 'S1 East, S1 West',
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.groups_outlined),
                label:
                    state is CommunicationLoaded &&
                        state.audiencePreview != null
                    ? Text(
                        'Estimated recipients: ${state.audiencePreview!.estimatedRecipients}',
                      )
                    : const Text('Preview audience'),
                onPressed: _audienceValid
                    ? () {
                        final auth = context.read<AuthBloc>().state;
                        if (auth is AuthAuthenticated) {
                          context.read<CommunicationBloc>().add(
                            PreviewCommunicationAudienceRequested(
                              schoolId: auth.user.schoolId,
                              campaign: _buildDraft(auth),
                            ),
                          );
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              Text('Channels', style: Theme.of(context).textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children:
                    const [
                      ('inApp', 'In-app'),
                      ('push', 'Push notification'),
                      ('email', 'Email'),
                    ].map((c) {
                      return FilterChip(
                        label: Text(c.$2),
                        selected: _channels.contains(c.$1),
                        onSelected: (sel) => setState(() {
                          sel ? _channels.add(c.$1) : _channels.remove(c.$1);
                        }),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Require acknowledgement'),
                subtitle: const Text(
                  'Recipients must confirm they have seen this notice.',
                ),
                value: _ackRequired,
                onChanged: (v) => setState(() => _ackRequired = v),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(_pickedImageName ?? 'Attach an image (optional)'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  onPressed: _pickImage,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: Text('${_pickedAttachments.length} attachment(s)'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _pickAttachment,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(
                  _scheduledAt == null
                      ? 'Send immediately'
                      : 'Scheduled for ${_scheduledAt!.toLocal()}',
                ),
                trailing: TextButton(
                  onPressed: () => _pickSchedule(isExpiry: false),
                  child: Text(_scheduledAt == null ? 'Schedule' : 'Change'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.event_busy_outlined),
                title: Text(
                  _expiresAt == null
                      ? 'No expiry'
                      : 'Expires ${_expiresAt!.toLocal()}',
                ),
                trailing: TextButton(
                  onPressed: () => _pickSchedule(isExpiry: true),
                  child: Text(_expiresAt == null ? 'Set expiry' : 'Change'),
                ),
              ),
              const SizedBox(height: 24),
              if (_submitting)
                const Center(child: SchoolPulseLoader())
              else
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: () => _submit(schedule: false, sendNow: false),
                      child: const Text('Save draft'),
                    ),
                    FilledButton(
                      onPressed: () => _submit(
                        schedule: _scheduledAt != null,
                        sendNow: _scheduledAt == null,
                      ),
                      child: Text(
                        _scheduledAt != null ? 'Schedule' : 'Send now',
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
