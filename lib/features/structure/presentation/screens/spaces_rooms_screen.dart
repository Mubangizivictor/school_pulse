import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../domain/services/space_rules.dart';
import '../../domain/services/structure_tenant_resolver.dart';

/// Standalone Step 12 module. It intentionally owns the new nested spaces
/// schema, so it can move to Academic Settings without the wizard changing it.
class SpacesRoomsScreen extends StatefulWidget {
  const SpacesRoomsScreen({super.key});

  @override
  State<SpacesRoomsScreen> createState() => _SpacesRoomsScreenState();
}

class _SpacesRoomsScreenState extends State<SpacesRoomsScreen> {
  final _firestore = FirebaseFirestore.instance;
  late final Future<String> _schoolId = StructureTenantResolver(
    firestore: _firestore,
    auth: FirebaseAuth.instance,
  ).resolve();

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _schoolId,
    builder: (context, tenant) {
      if (tenant.hasError)
        return _Message(error: tenant.error, retry: () => setState(() {}));
      if (!tenant.hasData)
        return const Center(child: CircularProgressIndicator());
      return _SpacesBody(firestore: _firestore, schoolId: tenant.data!);
    },
  );
}

class _SpacesBody extends StatelessWidget {
  const _SpacesBody({required this.firestore, required this.schoolId});
  final FirebaseFirestore firestore;
  final String schoolId;

  CollectionReference<Map<String, dynamic>> get _spaces =>
      firestore.collection('schools').doc(schoolId).collection('spaces');
  DocumentReference<Map<String, dynamic>> get _settings => firestore
      .collection('schools')
      .doc(schoolId)
      .collection('spaceSettings')
      .doc('current');

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: _settings.snapshots(),
    builder: (context, settings) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _spaces.orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (settings.hasError || snapshot.hasError) {
          return _Message(
            error: settings.error ?? snapshot.error,
            retry: () {},
          );
        }
        if (!settings.hasData || !snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final spaces = snapshot.data!.docs
            .where((d) => d.data()['active'] != false)
            .toList();
        final enabled = settings.data!.data()?['roomSchedulingEnabled'] == true;
        final schedulable = spaces
            .where(
              (d) =>
                  d.data()['schedulable'] == true &&
                  SpaceRules.teachingTypes.contains(d.data()['type']),
            )
            .length;
        Future<void> saveMode(bool useNamed) async {
          final error = SpaceRules.validateMode(
            roomSchedulingEnabled: useNamed,
            schedulableTeachingSpaces: schedulable,
          );
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                action: SnackBarAction(
                  label: 'Add a space',
                  onPressed: () => _sheet(context),
                ),
              ),
            );
            return;
          }
          await _settings.set({
            'roomSchedulingEnabled': useNamed,
            'defaultClassRoomMode': !useNamed,
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': FirebaseAuth.instance.currentUser?.uid ?? '',
          });
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    const Text(
                      'Add named rooms only if you schedule shared physical spaces.',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'TIMETABLE ROOMS',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ModeCard(
                      selected: !enabled,
                      title: 'Class rooms only',
                      detail:
                          'Use each class’s usual room. Add named rooms later if needed.',
                      badge: 'Recommended',
                      onTap: () => saveMode(false),
                    ),
                    const SizedBox(height: 12),
                    _ModeCard(
                      selected: enabled,
                      title: 'Schedule named rooms',
                      detail:
                          'Assign classrooms, labs and halls to prevent room clashes.',
                      onTap: () => saveMode(true),
                    ),
                    const Divider(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Named spaces',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _sheet(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add space'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (spaces.isEmpty)
                      _Empty(onAdd: () => _sheet(context))
                    else
                      ..._groups(context, spaces),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  List<Widget> _groups(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> spaces,
  ) {
    final teaching = spaces
        .where((d) => SpaceRules.teachingTypes.contains(d.data()['type']))
        .toList();
    final other = spaces
        .where((d) => !SpaceRules.teachingTypes.contains(d.data()['type']))
        .toList();
    return [
      if (teaching.isNotEmpty) ...[
        _Heading('Teaching spaces'),
        ...teaching.map(
          (d) => _SpaceRow(
            data: d.data(),
            onEdit: () => _sheet(context, d),
            onArchive: () => _archive(context, d),
          ),
        ),
      ],
      if (other.isNotEmpty) ...[
        _Heading('Other facilities'),
        ...other.map(
          (d) => _SpaceRow(
            data: d.data(),
            onEdit: () => _sheet(context, d),
            onArchive: () => _archive(context, d),
          ),
        ),
      ],
    ];
  }

  Future<void> _archive(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> space,
  ) async {
    final refs = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('timetable_lessons')
        .where('roomId', isEqualTo: space.id)
        .limit(1)
        .get();
    if (refs.docs.isNotEmpty) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This space is used by timetable entries. Reassign it before archiving.',
            ),
          ),
        );
      return;
    }
    await space.reference.update({
      'active': false,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': FirebaseAuth.instance.currentUser?.uid ?? '',
    });
  }

  Future<void> _sheet(
    BuildContext context, [
    QueryDocumentSnapshot<Map<String, dynamic>>? existing,
  ]) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _SpaceSheet(
      firestore: firestore,
      schoolId: schoolId,
      existing: existing,
    ),
  );
}

class _SpaceSheet extends StatefulWidget {
  const _SpaceSheet({
    required this.firestore,
    required this.schoolId,
    this.existing,
  });
  final FirebaseFirestore firestore;
  final String schoolId;
  final QueryDocumentSnapshot<Map<String, dynamic>>? existing;
  @override
  State<_SpaceSheet> createState() => _SpaceSheetState();
}

class _SpaceSheetState extends State<_SpaceSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.existing?.data()['name'],
  );
  late final _building = TextEditingController(
    text: widget.existing?.data()['building'],
  );
  late final _code = TextEditingController(
    text: widget.existing?.data()['code'],
  );
  late final _capacity = TextEditingController(
    text: widget.existing?.data()['capacity']?.toString(),
  );
  String _type = '';
  bool _schedulable = false;
  bool _saving = false;
  static const types = [
    'Classroom',
    'Science lab',
    'Computer lab',
    'Library',
    'Hall',
    'Staff room',
    'Office',
    'Sick bay',
    'Kitchen',
    'Dormitory',
    'Store',
    'Other',
  ];
  @override
  void initState() {
    super.initState();
    _type = widget.existing?.data()['type'] ?? '';
    _schedulable = widget.existing?.data()['schedulable'] ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _building.dispose();
    _code.dispose();
    _capacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 16,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null ? 'Add a space' : 'Edit space',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('Create a room or facility used by the school.'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Space name'),
              validator: (_) => SpaceRules.validate(
                name: _name.text,
                type: _type,
                capacity: _capacity.text,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _type.isEmpty ? null : _type,
              decoration: const InputDecoration(labelText: 'Space type'),
              items: types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() {
                _type = v ?? '';
                if (widget.existing == null)
                  _schedulable = SpaceRules.defaultSchedulable(_type);
              }),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _building,
                    decoration: const InputDecoration(
                      labelText: 'Building / block (optional)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _code,
                    decoration: const InputDecoration(
                      labelText: 'Room code (optional)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _capacity,
              decoration: const InputDecoration(
                labelText: 'Capacity (optional)',
                helperText: 'Whole number of learners',
              ),
              keyboardType: TextInputType.number,
              validator: (_) => SpaceRules.validate(
                name: _name.text,
                type: _type,
                capacity: _capacity.text,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use in timetable'),
              subtitle: const Text(
                'Allows this space to be selected for scheduled lessons.',
              ),
              value: _schedulable,
              onChanged: (v) => setState(() => _schedulable = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving…' : 'Save space'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final name = SpaceRules.normalize(_name.text);
      final code = SpaceRules.normalize(_code.text);
      final col = widget.firestore
          .collection('schools')
          .doc(widget.schoolId)
          .collection('spaces');
      final all = await col.get();
      await widget.firestore.runTransaction((tx) async {
        final duplicate = all.docs.any(
          (d) =>
              d.id != widget.existing?.id &&
              d.data()['active'] != false &&
              (d.data()['normalizedName'] == name ||
                  (code.isNotEmpty && d.data()['normalizedCode'] == code)),
        );
        if (duplicate)
          throw StateError(
            'A space with this name or room code already exists.',
          );
        final ref = widget.existing?.reference ?? col.doc(const Uuid().v4());
        tx.set(ref, {
          'name': _name.text.trim(),
          'normalizedName': name,
          'normalizedCode': code,
          'type': _type,
          if (_code.text.trim().isNotEmpty) 'code': _code.text.trim(),
          if (_building.text.trim().isNotEmpty)
            'building': _building.text.trim(),
          if (_capacity.text.trim().isNotEmpty)
            'capacity': int.parse(_capacity.text),
          'schedulable': _schedulable,
          'active': true,
          if (widget.existing == null)
            'createdAt': FieldValue.serverTimestamp(),
          if (widget.existing == null)
            'createdBy': FirebaseAuth.instance.currentUser?.uid ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': FirebaseAuth.instance.currentUser?.uid ?? '',
        }, SetOptions(merge: true));
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
        );
      setState(() => _saving = false);
    }
  }
}


class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.title,
    required this.detail,
    required this.onTap,
    this.badge,
  });
  final bool selected;
  final String title, detail;
  final String? badge;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: title,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (badge != null)
                        Text(
                          badge!,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(detail),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class _SpaceRow extends StatelessWidget {
  const _SpaceRow({
    required this.data,
    required this.onEdit,
    required this.onArchive,
  });
  final Map<String, dynamic> data;
  final VoidCallback onEdit, onArchive;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    minVerticalPadding: 12,
    leading: const Icon(Icons.meeting_room_outlined, size: 30),
    title: Text(
      data['name'] ?? '',
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
    subtitle: Text(
      [
        data['type'],
        if ((data['code'] ?? '').isNotEmpty) data['code'],
        if ((data['building'] ?? '').isNotEmpty) data['building'],
        if (data['capacity'] != null) 'Capacity ${data['capacity']}',
        data['schedulable'] == true ? 'Timetable' : 'Not schedulable',
      ].join(' · '),
    ),
    trailing: PopupMenuButton<String>(
      onSelected: (v) => v == 'edit' ? onEdit() : onArchive(),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'archive', child: Text('Archive')),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          const Icon(Icons.location_city_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            'No named spaces yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add only when you use named classrooms or shared rooms.',
            textAlign: TextAlign.center,
          ),
          TextButton(onPressed: onAdd, child: const Text('Add a space')),
        ],
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({this.error, required this.retry});
  final Object? error;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44),
          const SizedBox(height: 12),
          Text(error == null ? 'Loading spaces…' : 'Unable to load spaces'),
          if (error != null)
            Text(error.toString(), textAlign: TextAlign.center),
          OutlinedButton(onPressed: retry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
