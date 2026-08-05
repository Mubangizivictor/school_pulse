import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

/// The bottom sheets behind the Poll, Event and Contact entries in the
/// attachment menu. Each returns its payload through `Navigator.pop` and
/// knows nothing about Firestore - the chat screen does the sending.

class PollDraft {
  final String question;
  final List<String> options;

  const PollDraft({required this.question, required this.options});
}

class EventDraft {
  final String title;
  final DateTime start;
  final String? location;

  const EventDraft({required this.title, required this.start, this.location});
}

/// Shared chrome so the three sheets sit at the same height and follow the
/// keyboard the same way.
class _SheetShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.l),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Flexible(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}

class PollComposerSheet extends StatefulWidget {
  const PollComposerSheet({super.key});

  @override
  State<PollComposerSheet> createState() => _PollComposerSheetState();
}

class _PollComposerSheetState extends State<PollComposerSheet> {
  static const int _maxOptions = 6;

  final TextEditingController _question = TextEditingController();
  final List<TextEditingController> _options = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _question.dispose();
    for (final option in _options) {
      option.dispose();
    }
    super.dispose();
  }

  /// A poll needs a question and at least two distinct answers.
  bool get _canSend =>
      _question.text.trim().isNotEmpty &&
      _options.where((o) => o.text.trim().isNotEmpty).length >= 2;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'New poll',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _question,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Question',
              hintText: 'Which day suits the class trip?',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.m),
          for (var i = 0; i < _options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _options[i],
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Option ${i + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  // The first two options are the minimum, so they can't be
                  // removed.
                  if (_options.length > 2)
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () =>
                          setState(() => _options.removeAt(i).dispose()),
                    ),
                ],
              ),
            ),
          if (_options.length < _maxOptions)
            TextButton.icon(
              onPressed: () =>
                  setState(() => _options.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add option'),
            ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSend
                  ? () => Navigator.pop(
                      context,
                      PollDraft(
                        question: _question.text.trim(),
                        options: _options
                            .map((o) => o.text.trim())
                            .where((o) => o.isNotEmpty)
                            .toList(),
                      ),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.disabled(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Send poll',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventComposerSheet extends StatefulWidget {
  const EventComposerSheet({super.key});

  @override
  State<EventComposerSheet> createState() => _EventComposerSheetState();
}

class _EventComposerSheetState extends State<EventComposerSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _location = TextEditingController();
  DateTime _start = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (!mounted) return;

    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _start.hour,
        time?.minute ?? _start.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'New event',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Event',
              hintText: 'PTA meeting',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.m),
          OutlinedButton.icon(
            onPressed: _pickDateTime,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(DateFormat('EEE, d MMM y • h:mm a').format(_start)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerLeft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _location,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Where (optional)',
              hintText: 'Assembly hall',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _title.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(
                      context,
                      EventDraft(
                        title: _title.text.trim(),
                        start: _start,
                        location: _location.text.trim().isEmpty
                            ? null
                            : _location.text.trim(),
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.disabled(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Send event',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-select picker over the school directory, used to share somebody's
/// contact card into a chat.
class ContactPickerSheet extends StatefulWidget {
  final List<MessageContact> contacts;

  const ContactPickerSheet({super.key, required this.contacts});

  @override
  State<ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<ContactPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final term = _query.trim().toLowerCase();
    final filtered = term.isEmpty
        ? widget.contacts
        : widget.contacts
              .where((c) => c.name.toLowerCase().contains(term))
              .toList();

    return _SheetShell(
      title: 'Share a contact',
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search contacts...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.s),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Text(
                'No contacts match "$_query"',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final contact = filtered[index];
                final role = UserRole.values.where(
                  (r) => r.name == contact.role,
                );
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.electricBlue.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      contact.initials,
                      style: const TextStyle(color: AppColors.electricBlue),
                    ),
                  ),
                  title: Text(contact.name, style: AppTypography.titleSmall),
                  subtitle: Text(
                    role.isEmpty
                        ? contact.role
                        : UserRoleDisplay.name(role.first),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  onTap: () => Navigator.pop(context, contact),
                );
              },
            ),
        ],
      ),
    );
  }
}
