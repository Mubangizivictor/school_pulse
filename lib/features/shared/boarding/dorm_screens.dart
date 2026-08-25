import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/shared/boarding/dorm_widgets.dart';

/// Presentation-only dormitory screens shared by the Matron and Patron wings.
/// The forms collect input and the lists render, but nothing is persisted yet -
/// the data wiring lands separately.

/// Values collected by [AddDormitoryScreen], returned to the caller so the
/// screen stays presentation-only and the caller owns persistence.
class DormitoryFormResult {
  final String name;
  final int capacity;
  final String? location;
  final String? description;

  const DormitoryFormResult({
    required this.name,
    required this.capacity,
    this.location,
    this.description,
  });
}

/// Add / edit dormitory form.
class AddDormitoryScreen extends StatefulWidget {
  final String? dormitoryName;
  final int? capacity;
  final String? location;

  const AddDormitoryScreen({
    super.key,
    this.dormitoryName,
    this.capacity,
    this.location,
  });

  @override
  State<AddDormitoryScreen> createState() => _AddDormitoryScreenState();
}

class _AddDormitoryScreenState extends State<AddDormitoryScreen> {
  final _name = TextEditingController();
  final _capacity = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.text = widget.dormitoryName ?? '';
    _capacity.text = widget.capacity?.toString() ?? '';
    _location.text = widget.location ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _capacity.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a dormitory name.')));
      return;
    }
    final location = _location.text.trim();
    final description = _description.text.trim();
    Navigator.pop(
      context,
      DormitoryFormResult(
        name: name,
        capacity: int.tryParse(_capacity.text.trim()) ?? 0,
        location: location.isEmpty ? null : location,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dormitoryName == null ? 'Add Dormitory' : 'Edit Dormitory',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  DormFormField(
                    label: 'Dormitory Name',
                    hint: 'Enter dormitory name',
                    icon: Icons.home_outlined,
                    controller: _name,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DormFormField(
                    label: 'Capacity',
                    hint: 'Enter capacity',
                    icon: Icons.groups_outlined,
                    controller: _capacity,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DormFormField(
                    label: 'Location (optional)',
                    hint: 'Enter location',
                    icon: Icons.location_on_outlined,
                    controller: _location,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DormFormField(
                    label: 'Description (optional)',
                    hint: 'Add description',
                    icon: Icons.notes_outlined,
                    controller: _description,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  DormPrimaryButton(
                    label: 'Save Dormitory',
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Leadership choices returned by [SetDormLeadershipScreen].
class DormLeadershipResult {
  final String? roomLeader;
  final String? dormPrefect;

  const DormLeadershipResult({this.roomLeader, this.dormPrefect});
}

/// Room leader / dorm prefect picker.
class SetDormLeadershipScreen extends StatefulWidget {
  final String? roomLeaderName;
  final String? roomLeaderClass;
  final String? dormPrefectName;
  final String? dormPrefectClass;

  /// Opens a student picker and returns the chosen name, or null if the
  /// caller has not supplied one yet.
  final Future<String?> Function(BuildContext context, String title)? onPick;

  const SetDormLeadershipScreen({
    super.key,
    this.roomLeaderName,
    this.roomLeaderClass,
    this.dormPrefectName,
    this.dormPrefectClass,
    this.onPick,
  });

  @override
  State<SetDormLeadershipScreen> createState() =>
      _SetDormLeadershipScreenState();
}

class _SetDormLeadershipScreenState extends State<SetDormLeadershipScreen> {
  String? _leader;
  String? _prefect;

  @override
  void initState() {
    super.initState();
    _leader = widget.roomLeaderName;
    _prefect = widget.dormPrefectName;
  }

  Future<void> _pick(bool isLeader) async {
    final picker = widget.onPick;
    if (picker == null) return;
    final chosen = await picker(
      context,
      isLeader ? 'Select Room Leader' : 'Select Dorm Prefect',
    );
    if (chosen == null || !mounted) return;
    setState(() {
      if (isLeader) {
        _leader = chosen;
      } else {
        _prefect = chosen;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Set Dorm Leadership')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(
              'Room Leader',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Select the overall leader for this dormitory',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            DormPersonPicker(
              name: _leader,
              subtitle: widget.roomLeaderClass,
              placeholder: 'Select room leader',
              onTap: () => _pick(true),
            ),
            const SizedBox(height: AppSpacing.x3l),
            Text(
              'Dorm Prefect (Assistant)',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Select the assistant prefect',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            DormPersonPicker(
              name: _prefect,
              subtitle: widget.dormPrefectClass,
              placeholder: 'Select dorm prefect',
              onTap: () => _pick(false),
            ),
            const SizedBox(height: AppSpacing.x4l),
            DormPrimaryButton(
              label: 'Save Leadership',
              onPressed: () => Navigator.pop(
                context,
                DormLeadershipResult(
                  roomLeader: _leader,
                  dormPrefect: _prefect,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One entry rendered by [TransferHistoryScreen].
class TransferHistoryEntry {
  final String studentName;
  final String fromLabel;
  final String toLabel;
  final bool isDormTransfer;
  final String dateLabel;
  final String timeLabel;

  const TransferHistoryEntry({
    required this.studentName,
    required this.fromLabel,
    required this.toLabel,
    required this.isDormTransfer,
    required this.dateLabel,
    required this.timeLabel,
  });
}

/// Bed and dormitory transfer history, filtered by a three-way tab bar.
/// Renders whatever the caller supplies; an empty list shows an empty state
/// rather than invented rows.
class TransferHistoryScreen extends StatelessWidget {
  final List<TransferHistoryEntry> entries;

  const TransferHistoryScreen({super.key, this.entries = const []});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    List<Widget> tiles(bool Function(TransferHistoryEntry) test) => entries
        .where(test)
        .map(
          (e) => TransferHistoryTile(
            studentName: e.studentName,
            fromLabel: e.fromLabel,
            toLabel: e.toLabel,
            typeLabel: e.isDormTransfer ? 'Dorm Transfer' : 'Bed Transfer',
            typeColor: e.isDormTransfer ? Colors.black : primary,
            dateLabel: e.dateLabel,
            timeLabel: e.timeLabel,
          ),
        )
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transfer History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Bed Transfers'),
              Tab(text: 'Dorm Transfers'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _HistoryList(entries: tiles((_) => true)),
              _HistoryList(entries: tiles((e) => !e.isDormTransfer)),
              _HistoryList(entries: tiles((e) => e.isDormTransfer)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<Widget> entries;

  const _HistoryList({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.swap_horiz_rounded,
        title: 'No Transfers Yet',
        message: 'Bed and dormitory moves will appear here.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: entries,
    );
  }
}
