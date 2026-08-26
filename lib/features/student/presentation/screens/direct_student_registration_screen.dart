import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart';

import 'admin_student_profile_screen.dart' show StudentProfileTab;

/// Direct enrolment is deliberately independent of admission applications.
/// It saves a tenant-scoped draft until the server atomically activates it.
class DirectStudentRegistrationScreen extends StatefulWidget {
  final String schoolId;
  const DirectStudentRegistrationScreen({super.key, required this.schoolId});
  @override
  State<DirectStudentRegistrationScreen> createState() =>
      _DirectStudentRegistrationScreenState();
}

class _DirectStudentRegistrationScreenState
    extends State<DirectStudentRegistrationScreen> {
  final _form = GlobalKey<FormState>();
  final _db = FirebaseFirestore.instance;
  final _repo = sl<StructureRepository>();
  final _uuid = const Uuid();
  late String _draftId;
  late String _studentId;
  int _step = -1;
  bool _saving = false, _enrolling = false, _consent = false, _override = false;
  String _entry = 'New admission',
      _sex = 'Female',
      _nationality = 'Ugandan',
      _boarding = 'Day learner',
      _overrideReason = '';
  AcademicYear? _year;
  SchoolClass? _class;
  String? _stream;
  List<AcademicYear> _years = [];
  List<SchoolClass> _classes = [];
  List<ClassStream> _allStreams = [];
  Map<String, dynamic> _modules = {};
  final _first = TextEditingController(),
      _last = TextEditingController(),
      _dob = TextEditingController(),
      _previousSchool = TextEditingController(),
      _previousClass = TextEditingController(),
      _term = TextEditingController(text: 'Term 1'),
      _transport = TextEditingController(),
      _house = TextEditingController(),
      _support = TextEditingController();
  final List<Map<String, dynamic>> _guardians = [], _documents = [];
  StreamSubscription? _yearsSub, _classesSub, _streamsSub, _schoolSub;

  @override
  void initState() {
    super.initState();
    _draftId = _uuid.v4();
    _studentId = _uuid.v4();
    _yearsSub = _repo.watchAcademicYears(widget.schoolId).listen((v) {
      if (mounted)
        setState(() {
          _years = v.where((x) => !x.isArchived).toList();
          _year ??= _years.where((x) => x.isCurrent).firstOrNull;
        });
    });
    _classesSub = _repo.watchClasses(widget.schoolId).listen((v) {
      if (mounted)
        setState(() => _classes = v.where((x) => x.isActive).toList());
    });
    _streamsSub = _repo.watchStreams(widget.schoolId).listen((v) {
      if (mounted) setState(() => _allStreams = v);
    });
    _schoolSub = _db
        .collection('schools')
        .doc(widget.schoolId)
        .snapshots()
        .listen((v) {
          if (mounted)
            setState(
              () => _modules = Map<String, dynamic>.from(
                v.data()?['modules'] ?? {},
              ),
            );
        });
    _offerResume();
  }

  Future<void> _offerResume() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final q = await _db
        .collection('direct_enrolment_drafts')
        .where('schoolId', isEqualTo: widget.schoolId)
        .where('createdBy', isEqualTo: auth.user.id)
        .where('status', isEqualTo: 'draft')
        .limit(1)
        .get();
    if (!mounted || q.docs.isEmpty) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Resume saved enrolment?'),
        content: const Text('A direct-enrolment draft is waiting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Start new'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) _load(q.docs.single);
  }

  void _load(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final l = Map<String, dynamic>.from(d['learner'] ?? {});
    final p = Map<String, dynamic>.from(d['placement'] ?? {});
    setState(() {
      _draftId = doc.id;
      _studentId = d['studentId'] as String? ?? _studentId;
      _step = (d['step'] as int?) ?? 0;
      _first.text = l['firstNames'] ?? '';
      _last.text = l['surname'] ?? '';
      _dob.text = l['dateOfBirth'] ?? '';
      _entry = l['entryType'] ?? _entry;
      _sex = l['sex'] ?? _sex;
      _nationality = l['nationality'] ?? _nationality;
      _previousSchool.text = l['previousSchool'] ?? '';
      _previousClass.text = l['previousClass'] ?? '';
      _term.text = p['term'] ?? _term.text;
      _year = _years.where((x) => x.id == p['academicYearId']).firstOrNull;
      _class = _classes.where((x) => x.id == p['classId']).firstOrNull;
      _stream = p['stream'];
      _guardians
        ..clear()
        ..addAll(
          List<Map<String, dynamic>>.from(
            (d['guardians'] ?? []).map((x) => Map<String, dynamic>.from(x)),
          ),
        );
      _documents
        ..clear()
        ..addAll(
          List<Map<String, dynamic>>.from(
            (d['documents'] ?? []).map((x) => Map<String, dynamic>.from(x)),
          ),
        );
      _consent = d['consentAcknowledged'] == true;
    });
  }

  Map<String, dynamic> get _data => {
    'schoolId': widget.schoolId,
    'studentId': _studentId,
    'status': 'draft',
    'step': _step,
    'learner': {
      'firstNames': _first.text.trim(),
      'surname': _last.text.trim(),
      'dateOfBirth': _dob.text.trim(),
      'sex': _sex,
      'nationality': _nationality,
      'entryType': _entry,
      'previousSchool': _previousSchool.text.trim(),
      'previousClass': _previousClass.text.trim(),
    },
    'guardians': _guardians,
    'placement': {
      'academicYearId': _year?.id,
      'academicYear': _year?.name,
      'classId': _class?.id,
      'className': _class?.name,
      'stream': _stream,
      'term': _term.text.trim(),
    },
    'services': {
      'boardingStatus': _boarding,
      'transportRoute': _transport.text.trim(),
      'house': _house.text.trim(),
    },
    'support': _support.text.trim(),
    'documents': _documents,
    'consentAcknowledged': _consent,
    'guardianOverride': _override ? {'reason': _overrideReason} : null,
  };
  Future<void> _save({bool quiet = false}) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    setState(() => _saving = true);
    try {
      await _db.collection('direct_enrolment_drafts').doc(_draftId).set({
        ..._data,
        'createdBy': auth.user.id,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!quiet && mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Draft saved')));
    } on FirebaseException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save draft: ${e.message ?? e.code}'),
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _guardianOk =>
      _guardians.isNotEmpty || (_override && _overrideReason.trim().isNotEmpty);
  bool get _valid => switch (_step) {
    0 =>
      _first.text.trim().isNotEmpty &&
          _last.text.trim().isNotEmpty &&
          _dob.text.trim().isNotEmpty &&
          (_entry != 'Transfer' ||
              (_previousSchool.text.trim().isNotEmpty &&
                  _previousClass.text.trim().isNotEmpty)),
    1 => _guardianOk,
    2 => _year != null && _class != null && _term.text.trim().isNotEmpty,
    4 => _consent,
    _ => true,
  };
  Future<bool> _leave() async {
    await _save(quiet: true);
    if (!mounted) return true;
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Leave enrolment?'),
            content: const Text('Your progress has been saved as a draft.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _next() async {
    if (!_valid) {
      _form.currentState?.validate();
      setState(() {});
      return;
    }
    await _save(quiet: true);
    if (!mounted) return;
    if (_step == 5) return _enrol();
    setState(() => _step++);
  }

  Future<void> _enrol() async {
    setState(() => _enrolling = true);
    try {
      final r = await FirebaseFunctions.instance
          .httpsCallable('directEnrolLearner')
          .call({'draftId': _draftId});
      final v = Map<String, dynamic>.from(r.data as Map);
      if (!mounted) return;
      await _db.collection('direct_enrolment_drafts').doc(_draftId).set({
        'status': 'enrolled',
      }, SetOptions(merge: true));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _Success(
            studentId: v['studentId'],
            number: v['studentNumber'],
            status: v['status'],
            placement: '${_class?.name} · ${_year?.name}',
          ),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? 'Enrolment failed. The draft is still saved.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  void dispose() {
    for (final x in [_yearsSub, _classesSub, _streamsSub, _schoolSub]) {
      x?.cancel();
    }
    for (final x in [
      _first,
      _last,
      _dob,
      _previousSchool,
      _previousClass,
      _term,
      _transport,
      _house,
      _support,
    ]) {
      x.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _step < 0,
    onPopInvokedWithResult: (p, _) async {
      if (!p && await _leave() && mounted) context.pop();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          _step < 0 ? 'Add a learner' : 'Enrol learner',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_step >= 0)
            TextButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save draft'),
            ),
        ],
      ),
      body: _step < 0 ? _choice() : _flow(),
    ),
  );
  Widget _choice() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose how this learner enters the school.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _choiceCard(
              'Direct enrolment',
              'Create an active learner record now',
              Icons.person_add_alt_1_outlined,
              true,
              () => setState(() => _step = 0),
            ),
            const SizedBox(height: 10),
            _choiceCard(
              'Admission application',
              'Capture an application for review before enrolment',
              Icons.description_outlined,
              false,
              () => context.push(
                '/staff/admin/admissions/new',
                extra: widget.schoolId,
              ),
            ),
            const SizedBox(height: 18),
            const _Notice('You can save a draft at any stage.'),
          ],
        ),
      ),
    ),
  );
  Widget _choiceCard(
    String title,
    String sub,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = selected
        ? (dark ? AppColors.white : AppColors.black)
        : Theme.of(context).colorScheme.surface;
    final ink = selected
        ? (dark ? AppColors.black : AppColors.white)
        : Theme.of(context).colorScheme.onSurface;
    final muted = selected
        ? (dark ? AppColors.grey700 : AppColors.grey200)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final outline = selected
        ? fill
        : Theme.of(context).colorScheme.outlineVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $sub',
      child: Material(
        color: fill,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: ink),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: ink, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: muted, height: 1.25),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_outline_rounded
                      : Icons.circle_outlined,
                  color: ink,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _flow() => Form(
    key: _form,
    child: Column(
      children: [
        Padding(padding: const EdgeInsets.all(20), child: _Progress(_step + 1)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [_body()],
          ),
        ),
        Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide())),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () =>
                    setState(() => _step = _step == 0 ? -1 : _step - 1),
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _enrolling ? null : _next,
                  child: Text(
                    _enrolling
                        ? 'Enrolling…'
                        : _step == 5
                        ? 'Enrol learner'
                        : _step == 3
                        ? 'Skip for now'
                        : 'Continue',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _body() => switch (_step) {
    0 => _details(),
    1 => _guardianPage(),
    2 => _placement(),
    3 => _services(),
    4 => _documentsPage(),
    _ => _review(),
  };
  Widget _details() => _section(
    'Learner details',
    'Record legal identity details required by your school.',
    [
      _field(
        _first,
        'First names',
        required: true,
        caps: TextCapitalization.words,
      ),
      _field(_last, 'Surname', required: true, caps: TextCapitalization.words),
      _field(
        _dob,
        'Date of birth',
        required: true,
        type: TextInputType.datetime,
        hint: 'DD/MM/YYYY',
      ),
      _select('Sex', _sex, const [
        'Female',
        'Male',
        'Other',
        'Prefer not to say',
      ], (v) => setState(() => _sex = v!)),
      _select('Nationality', _nationality, const [
        'Ugandan',
        'Other',
      ], (v) => setState(() => _nationality = v!)),
      _select('Entry type', _entry, const [
        'New admission',
        'Transfer',
        'Returning',
      ], (v) => setState(() => _entry = v!)),
      if (_entry == 'Transfer') ...[
        _field(_previousSchool, 'Previous school', required: true),
        _field(_previousClass, 'Previous class / level', required: true),
      ],
    ],
  );
  Widget _guardianPage() => _section(
    'Parent or guardian',
    'At least one adult contact is needed to activate a learner.',
    [
      ..._guardians.map(
        (g) => Card(
          child: ListTile(
            title: Text(g['name']),
            subtitle: Text('${g['relationship']} · ${g['phone']}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _guardian(g),
            ),
          ),
        ),
      ),
      OutlinedButton.icon(
        onPressed: () => _guardian(null),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add guardian'),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: _existing,
        icon: const Icon(Icons.search),
        label: const Text('Find existing family'),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _override,
        onChanged: (v) => setState(() => _override = v),
        title: const Text('Authorised staff override'),
        subtitle: const Text('A reason is required and will be audited.'),
      ),
      if (_override)
        TextFormField(
          initialValue: _overrideReason,
          onChanged: (v) => _overrideReason = v,
          decoration: const InputDecoration(
            labelText: 'Override reason',
            border: OutlineInputBorder(),
          ),
          validator: (v) => _override && (v == null || v.trim().isEmpty)
              ? 'Override reason is required'
              : null,
        ),
      if (!_guardianOk)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Add a guardian or provide an authorised override.'),
        ),
    ],
  );
  List<ClassStream> get _streams =>
      _allStreams.where((x) => x.classId == _class?.id).toList();
  Widget _placement() => _section(
    'Academic placement',
    'Subjects and teachers come from the class curriculum.',
    [
      _object(
        'Academic year',
        _year,
        _years,
        (x) => x.name,
        (v) => setState(() => _year = v),
      ),
      _object(
        'Class',
        _class,
        _classes,
        (x) => x.name,
        (v) => setState(() {
          _class = v;
          _stream = null;
        }),
      ),
      _select(
        'Stream / section (optional)',
        _stream ?? 'No stream',
        ['No stream', ..._streams.map((x) => x.name)],
        (v) => setState(() => _stream = v == 'No stream' ? null : v),
      ),
      _field(_term, 'Entry term', required: true),
      if ((_class?.capacity ?? 0) > 0)
        _Notice(
          'Capacity configured: ${_class!.capacity}. Availability is checked again on enrolment.',
        ),
    ],
  );
  bool _enabled(String key) => _modules.isEmpty || _modules[key] == true;
  Widget _services() => _section(
    'Support & services',
    'Optional — record only what applies.',
    [
      if (_enabled('boarding'))
        _select('Day or boarding status', _boarding, const [
          'Day learner',
          'Boarding learner',
        ], (v) => setState(() => _boarding = v!)),
      if (_enabled('transport'))
        _field(_transport, 'Transport route (optional)'),
      if (_enabled('houses')) _field(_house, 'House (optional)'),
      if (_enabled('studentSupport')) ...[
        _field(
          _support,
          'Health, medical or learning support (optional)',
          lines: 4,
        ),
        const _Notice(
          'Confidential support information is visible only to approved staff.',
        ),
      ],
      if (!_enabled('boarding') &&
          !_enabled('transport') &&
          !_enabled('houses') &&
          !_enabled('studentSupport'))
        const _Notice(
          'No optional service modules are enabled for this school.',
        ),
    ],
  );
  Widget _documentsPage() => _section(
    'Documents & consent',
    'Requirements are configured by your school. Files may be completed later where policy permits.',
    [
      if (_documents.isEmpty)
        const _Notice(
          'No files uploaded yet. Missing-document status is checked at enrolment.',
        ),
      ..._documents.map(
        (d) => Card(
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: Text(d['name']),
            subtitle: Text(
              d['status'] == 'uploading' ? 'Uploading…' : 'Uploaded',
            ),
            trailing: IconButton(
              tooltip: 'Remove',
              onPressed: () => setState(() => _documents.remove(d)),
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ),
      ),
      OutlinedButton.icon(
        onPressed: _upload,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload document'),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: _consent,
        onChanged: (v) => setState(() => _consent = v ?? false),
        title: const Text('Privacy and guardian consent acknowledged'),
      ),
      if (!_consent) const Text('Consent acknowledgement is required.'),
    ],
  );
  Widget _review() => _section(
    'Review & enrol',
    'Check the record before creating the learner.',
    [
      _summary(
        'Learner',
        '${_first.text} ${_last.text}',
        '${_dob.text} · $_entry',
      ),
      _summary(
        'Guardian',
        _guardians.isEmpty
            ? 'Authorised override'
            : _guardians.map((x) => x['name']).join(', '),
        _override ? _overrideReason : 'Primary/contact consent recorded',
      ),
      _summary(
        'Academic placement',
        '${_class?.name ?? 'Not selected'} · ${_year?.name ?? ''}',
        _term.text,
      ),
      _summary(
        'Services',
        _boarding,
        _transport.text.isEmpty ? 'No transport selected' : _transport.text,
      ),
      _summary(
        'Documents',
        _consent ? 'Consent confirmed' : 'Consent missing',
        '${_documents.length} file(s) uploaded',
      ),
      const _Notice(
        'A duplicate-safe student number is issued when enrolment is confirmed. Fee setup does not block enrolment.',
      ),
    ],
  );
  Widget _section(String title, String sub, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text(
        sub,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (final item in items) ...[item, const SizedBox(height: 12)],
            ],
          ),
        ),
      ),
    ],
  );
  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    TextInputType? type,
    String? hint,
    int lines = 1,
    TextCapitalization caps = TextCapitalization.none,
  }) => TextFormField(
    controller: c,
    keyboardType: type,
    maxLines: lines,
    textCapitalization: caps,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    ),
    validator: required
        ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null
        : null,
  );
  Widget _select(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> changed,
  ) => DropdownButtonFormField<String>(
    value: values.contains(value) ? value : values.first,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    items: values
        .map((x) => DropdownMenuItem(value: x, child: Text(x)))
        .toList(),
    onChanged: changed,
  );
  Widget _object<T>(
    String label,
    T? value,
    List<T> values,
    String Function(T) labelOf,
    ValueChanged<T?> changed,
  ) => DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    items: values
        .map((x) => DropdownMenuItem(value: x, child: Text(labelOf(x))))
        .toList(),
    onChanged: changed,
    validator: (x) => x == null ? '$label is required' : null,
  );
  Widget _summary(String title, String value, String detail) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text('$value\n$detail'),
  );
  Future<void> _guardian(Map<String, dynamic>? old) async {
    final n = TextEditingController(text: old?['name']),
        r = TextEditingController(text: old?['relationship']),
        p = TextEditingController(text: old?['phone']),
        e = TextEditingController(text: old?['email']);
    bool primary = old?['primary'] == true, pickup = old?['pickup'] == true;
    final v = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text(old == null ? 'Add guardian' : 'Edit guardian'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(n, 'Legal name', required: true),
                const SizedBox(height: 8),
                _field(r, 'Relationship', required: true),
                const SizedBox(height: 8),
                _field(p, 'Phone', required: true, type: TextInputType.phone),
                const SizedBox(height: 8),
                _field(e, 'Email', type: TextInputType.emailAddress),
                SwitchListTile(
                  title: const Text('Primary contact'),
                  value: primary,
                  onChanged: (x) => setD(() => primary = x),
                ),
                SwitchListTile(
                  title: const Text('Authorised pickup / emergency contact'),
                  value: pickup,
                  onChanged: (x) => setD(() => pickup = x),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (n.text.trim().isNotEmpty &&
                    r.text.trim().isNotEmpty &&
                    p.text.trim().isNotEmpty)
                  Navigator.pop(c, {
                    'id': old?['id'] ?? _uuid.v4(),
                    'name': n.text.trim(),
                    'relationship': r.text.trim(),
                    'phone': p.text.trim(),
                    'email': e.text.trim(),
                    'primary': primary,
                    'pickup': pickup,
                    'emergencyConsent': pickup,
                  });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (v != null && mounted)
      setState(() {
        if (v['primary'] == true)
          for (final g in _guardians) g['primary'] = false;
        final i = _guardians.indexWhere((x) => x['id'] == v['id']);
        if (i < 0)
          _guardians.add(v);
        else
          _guardians[i] = v;
      });
  }

  Future<void> _existing() async {
    final c = TextEditingController();
    final v = await showDialog<String>(
      context: context,
      builder: (x) => AlertDialog(
        title: const Text('Find existing family'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Guardian phone',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(x),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(x, c.text.trim()),
            child: const Text('Link'),
          ),
        ],
      ),
    );
    if (v != null && v.isNotEmpty)
      setState(
        () => _guardians.add({
          'id': _uuid.v4(),
          'name': 'Linked guardian',
          'relationship': 'Guardian',
          'phone': v,
          'email': '',
          'primary': _guardians.isEmpty,
          'pickup': false,
          'emergencyConsent': false,
        }),
      );
  }

  Future<void> _upload() async {
    final picked = await FilePicker.pickFiles(withData: true);
    final f = picked?.files.single;
    if (f?.bytes == null) return;
    final doc = <String, dynamic>{
      'id': _uuid.v4(),
      'name': f!.name,
      'status': 'uploading',
      'size': f.size,
    };
    setState(() => _documents.add(doc));
    try {
      final ref = FirebaseStorage.instance.ref(
        'schools/${widget.schoolId}/students/$_studentId/documents/${doc['id']}',
      );
      await ref.putData(
        f.bytes!,
        SettableMetadata(
          contentType: f.extension == 'pdf'
              ? 'application/pdf'
              : 'application/octet-stream',
        ),
      );
      final url = await ref.getDownloadURL();
      if (mounted)
        setState(
          () => doc
            ..['status'] = 'uploaded'
            ..['path'] = ref.fullPath
            ..['url'] = url,
        );
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() => _documents.remove(doc));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.message ?? e.code}')),
        );
      }
    }
  }
}

class _Progress extends StatelessWidget {
  final int step;
  const _Progress(this.step);
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Step $step of 6'),
      const SizedBox(height: 8),
      Row(
        children: List.generate(
          6,
          (i) => Expanded(
            child: Container(
              height: 7,
              margin: EdgeInsets.only(right: i == 5 ? 0 : 5),
              decoration: BoxDecoration(
                color: i < step ? Colors.black : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice(this.text);
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(c).textTheme.bodyMedium?.copyWith(fontSize: 15),
          ),
        ),
      ],
    ),
  );
}

class _Success extends StatelessWidget {
  final String studentId, number, status, placement;
  const _Success({
    required this.studentId,
    required this.number,
    required this.status,
    required this.placement,
  });
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Enrol learner')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: Colors.black,
              child: Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 18),
            Text(
              'Enrolment complete',
              style: Theme.of(c).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Student number', number),
                    _row('Status', status),
                    _row('Placement', placement),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => c.go('/staff/admin/students/$studentId'),
                child: const Text('Open learner profile'),
              ),
            ),
            const SizedBox(height: 8),
            // Each follow-up action lands on the tab that actually serves it,
            // rather than all four dropping the user on Overview.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => c.go(
                  '/staff/admin/students/$studentId'
                  '?tab=${StudentProfileTab.fees}',
                ),
                child: const Text('Set up fee plan'),
              ),
            ),
            TextButton(
              onPressed: () => c.go(
                '/staff/admin/students/$studentId'
                '?tab=${StudentProfileTab.identity}',
              ),
              child: const Text('Issue ID card later'),
            ),
            TextButton(
              onPressed: () => c.go(
                '/staff/admin/students/$studentId'
                '?tab=${StudentProfileTab.services}',
              ),
              child: const Text('Add transport or boarding'),
            ),
          ],
        ),
      ),
    ),
  );
  static Widget _row(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: const TextStyle(fontWeight: FontWeight.bold)),
        Flexible(child: Text(b, textAlign: TextAlign.end)),
      ],
    ),
  );
}
