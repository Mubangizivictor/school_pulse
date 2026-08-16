import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import '../../../data/calendar_attachments_uploader.dart';
import 'add_event_draft.dart';

/// Step two owns event context: category, location, organizer, audience and
/// attachments. The filename is retained to avoid breaking callers while
/// replacing the previous recurrence-only step.
class Step2Recurrence extends StatefulWidget {
  final AddEventDraft draft;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const Step2Recurrence({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onNext,
  });
  @override
  State<Step2Recurrence> createState() => _Step2RecurrenceState();
}

const _audienceOptions = <NotificationAudienceKind, String>{
  NotificationAudienceKind.school: 'All School',
  NotificationAudienceKind.allStaff: 'Staff',
  NotificationAudienceKind.allParents: 'Parents',
  NotificationAudienceKind.studentParents: 'Students',
  NotificationAudienceKind.roles: 'Specific Roles',
};

const _roleOptions = [
  'Admin',
  'Teacher',
  'Class Teacher',
  'Accountant',
  'Librarian',
  'Transport Officer',
  'Nurse',
  'Front Desk',
];

class _Step2RecurrenceState extends State<Step2Recurrence> {
  late final location = TextEditingController(text: widget.draft.location);
  late final organizer = TextEditingController(text: widget.draft.organizer);

  @override
  void dispose() {
    location.dispose();
    organizer.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: CalendarAttachmentsUploader.allowedExtensions.toList(),
      withData: false,
    );
    final file = result?.files.single;
    if (file?.path == null) return;
    final sizeBytes = file!.size;
    if (sizeBytes > CalendarAttachmentsUploader.maxSizeBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${file.name} is larger than 10 MB')),
        );
      }
      return;
    }
    setState(() {
      widget.draft.stagedAttachments.add(
        StagedCalendarAttachment(
          file: File(file.path!),
          fileName: file.name,
          sizeBytes: sizeBytes,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _select(
        'Category',
        widget.draft.category,
        ['Academic', 'Meeting', 'Activity', 'Sports', 'Other'],
        (v) => setState(() => widget.draft.category = v ?? ''),
      ),
      const SizedBox(height: 18),
      _field(
        'Location',
        'Enter location',
        location,
        (v) => widget.draft.location = v,
      ),
      const SizedBox(height: 18),
      _field(
        'Organized By',
        'School Administration',
        organizer,
        (v) => widget.draft.organizer = v,
      ),
      const SizedBox(height: 18),
      DropdownButtonFormField<NotificationAudienceKind>(
        initialValue: widget.draft.audienceKind,
        decoration: const InputDecoration(
          labelText: 'Visible To',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: _audienceOptions.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) => setState(
          () =>
              widget.draft.audienceKind = v ?? NotificationAudienceKind.school,
        ),
      ),
      if (widget.draft.audienceKind == NotificationAudienceKind.roles) ...[
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _roleOptions
              .map(
                (role) => FilterChip(
                  label: Text(role),
                  selected: widget.draft.audienceRoles.contains(role),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      widget.draft.audienceRoles.add(role);
                    } else {
                      widget.draft.audienceRoles.remove(role);
                    }
                  }),
                ),
              )
              .toList(),
        ),
      ],
      const SizedBox(height: 18),
      Text(
        'Attachments (Optional)',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
      ),
      const SizedBox(height: 6),
      InkWell(
        onTap: _pickAttachment,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 78,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: AppColors.primary(context),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to attach a file (PDF, image, doc — up to 10 MB)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ),
      ),
      if (widget.draft.existingAttachments.isNotEmpty ||
          widget.draft.stagedAttachments.isNotEmpty) ...[
        const SizedBox(height: 10),
        ...widget.draft.existingAttachments.map(
          (a) => _AttachmentTile(
            name: a.name,
            onRemove: () =>
                setState(() => widget.draft.existingAttachments.remove(a)),
          ),
        ),
        ...widget.draft.stagedAttachments.map(
          (a) => _AttachmentTile(
            name: a.fileName,
            onRemove: () =>
                setState(() => widget.draft.stagedAttachments.remove(a)),
          ),
        ),
      ],
      const SizedBox(height: 30),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onBack,
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: widget.onNext,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    ],
  );
  Widget _field(
    String label,
    String hint,
    TextEditingController controller,
    ValueChanged<String> changed,
  ) => TextField(
    controller: controller,
    onChanged: changed,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
  );
  Widget _select(
    String label,
    String current,
    List<String> values,
    ValueChanged<String?> changed,
  ) => DropdownButtonFormField<String>(
    initialValue: values.contains(current) ? current : null,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
        .toList(),
    onChanged: changed,
  );
}

class _AttachmentTile extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;
  const _AttachmentTile({required this.name, required this.onRemove});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(Icons.attach_file, size: 16, color: AppColors.textMuted(context)),
        const SizedBox(width: 6),
        Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        IconButton(
          icon: const Icon(Icons.close, size: 16),
          onPressed: onRemove,
          visualDensity: VisualDensity.compact,
        ),
      ],
    ),
  );
}
