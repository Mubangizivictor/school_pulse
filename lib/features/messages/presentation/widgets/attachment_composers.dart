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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          border: Border(
            top: BorderSide(color: AppColors.border(context), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
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
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              labelText: 'QUESTION',
              labelStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted(context),
              ),
              hintText: 'Which day suits the class trip?',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.l),
          for (var i = 0; i < _options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _options[i],
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                      decoration: InputDecoration(
                        labelText: 'OPTION ${i + 1}',
                        labelStyle: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMuted(context),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (_options.length > 2)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textPrimary(context),
                      ),
                      onPressed: () =>
                          setState(() => _options.removeAt(i).dispose()),
                    ),
                ],
              ),
            ),
          if (_options.length < _maxOptions)
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => _options.add(TextEditingController())),
              icon: Icon(Icons.add, size: 18, color: AppColors.textPrimary(context)),
              label: Text(
                'ADD OPTION',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                side: BorderSide(color: AppColors.border(context)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
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
                backgroundColor: AppColors.textPrimary(context),
                foregroundColor: AppColors.background(context),
                disabledBackgroundColor: AppColors.disabled(context),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
              ),
              child: Text(
                'SEND POLL',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black,
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black,
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          child: child!,
        );
      },
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
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              labelText: 'EVENT TITLE',
              labelStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted(context),
              ),
              hintText: 'PTA meeting',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.l),
          OutlinedButton.icon(
            onPressed: _pickDateTime,
            icon: Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textPrimary(context)),
            label: Text(
              DateFormat('EEE, d MMM y • h:mm a').format(_start),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerLeft,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: BorderSide(color: AppColors.border(context)),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          TextField(
            controller: _location,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              labelText: 'WHERE (OPTIONAL)',
              labelStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted(context),
              ),
              hintText: 'Assembly hall',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
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
                backgroundColor: AppColors.textPrimary(context),
                foregroundColor: AppColors.background(context),
                disabledBackgroundColor: AppColors.disabled(context),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
              ),
              child: Text(
                'SEND EVENT',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
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
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: 'SEARCH CONTACTS...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted(context),
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.textPrimary(context)),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.m),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'NO CONTACTS MATCH "$_query"',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                  fontWeight: FontWeight.w700,
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
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.border(context), width: 0.5),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary(context),
                        border: Border.all(color: AppColors.textPrimary(context), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        contact.initials,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.background(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.name.toUpperCase(),
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    subtitle: Text(
                      (role.isEmpty
                          ? contact.role
                          : UserRoleDisplay.name(role.first)).toUpperCase(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, contact),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
