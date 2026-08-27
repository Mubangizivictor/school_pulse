import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_plan.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_billing_repository.dart';
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
  String _selectedPath = 'direct';
  bool _draftPersisted = false;
  bool _saving = false, _enrolling = false, _consent = false, _override = false;
  bool _submittedCurrentStep = false;
  final _firstInvalidKey = GlobalKey();
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
  List<Map<String, dynamic>> _documentRequirements = const [];
  final _first = TextEditingController(),
      _middle = TextEditingController(),
      _last = TextEditingController(),
      _dob = TextEditingController(),
      _previousSchool = TextEditingController(),
      _previousClass = TextEditingController(),
      _term = TextEditingController(text: 'Term 1'),
      _transport = TextEditingController(),
      _house = TextEditingController(),
      _support = TextEditingController();
  final _guardianSearch = TextEditingController();
  final List<Map<String, dynamic>> _guardians = [], _documents = [];
  StreamSubscription? _yearsSub, _classesSub, _streamsSub, _termsSub;
  StreamSubscription? _schoolSub;
  List<AcademicTerm> _terms = [];

  // Fees step state. The matched plan is a read-only snapshot from
  // `findMatchingFeePlan` (see enrollment_setup_wizard_screen.dart's
  // `_FinanceStep` for the same pattern) - never a client-typed amount.
  MatchedFeePlan? _feePlanMatch;
  bool _feePlanLoading = false;
  String? _feePlanMatchedKey;
  final Set<String> _selectedFeeAddOnIds = {};
  bool _bursaryEnabled = false;
  final _bursaryReason = TextEditingController();
  final _bursaryAmount = TextEditingController();
  bool _bursaryIsPercentage = true;

  int get _feeBilledTotalUgx => (_feePlanMatch?.lines ?? const [])
      .where((l) => l.required || _selectedFeeAddOnIds.contains(l.chargeId))
      .fold(0, (sum, l) => sum + l.amountUgx);

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
    _termsSub = _repo.watchAcademicTerms(widget.schoolId).listen((v) {
      if (mounted)
        setState(() => _terms = v.where((x) => !x.isArchived).toList());
    });
    _schoolSub = _db
        .collection('schools')
        .doc(widget.schoolId)
        .snapshots()
        .listen((v) {
          if (mounted)
            setState(() {
              final data = v.data() ?? const <String, dynamic>{};
              _modules = Map<String, dynamic>.from(data['modules'] ?? {});
              _documentRequirements = List<Map<String, dynamic>>.from(
                (data['enrolmentPolicy']?['documentRequirements'] as List? ??
                        const [])
                    .map((item) => Map<String, dynamic>.from(item as Map)),
              );
            });
        });
  }

  void _load(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final l = Map<String, dynamic>.from(d['learner'] ?? {});
    final p = Map<String, dynamic>.from(d['placement'] ?? {});
    setState(() {
      _draftId = doc.id;
      _draftPersisted = true;
      _studentId = d['studentId'] as String? ?? _studentId;
      _step = (d['step'] as int?) ?? 0;
      _first.text = l['firstNames'] ?? '';
      _middle.text = l['middleName'] ?? '';
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
      final fees = Map<String, dynamic>.from(d['fees'] ?? {});
      _selectedFeeAddOnIds
        ..clear()
        ..addAll(List<String>.from(fees['selectedOptionalLineIds'] ?? []));
      final bursary = fees['bursary'] as Map<String, dynamic>?;
      _bursaryEnabled = bursary != null;
      if (bursary != null) {
        _bursaryReason.text = bursary['reason'] ?? '';
        _bursaryAmount.text = '${bursary['amount'] ?? ''}';
        _bursaryIsPercentage = bursary['isPercentage'] ?? true;
      }
    });
  }

  Map<String, dynamic> get _data => {
    'schoolId': widget.schoolId,
    'studentId': _studentId,
    'status': 'draft',
    'step': _step,
    'learner': {
      'firstNames': _first.text.trim(),
      'middleName': _middle.text.trim(),
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
    'fees': {
      'planId': _feePlanMatch?.planId,
      'selectedOptionalLineIds': _selectedFeeAddOnIds.toList(),
      'bursary': _bursaryEnabled
          ? {
              'reason': _bursaryReason.text.trim(),
              'amount': double.tryParse(_bursaryAmount.text.trim()) ?? 0,
              'isPercentage': _bursaryIsPercentage,
            }
          : null,
    },
  };
  Future<void> _save({bool quiet = false}) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    // Choosing a route starts only an in-memory wizard. A saved draft must
    // contain an actual learner signal or progress beyond the first step.
    if (!_isMeaningfulDraft) {
      if (!quiet && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter learner information before saving a draft.'),
          ),
        );
      }
      return;
    }
    setState(() => _saving = true);
    if (!quiet && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving…'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    try {
      await _db.collection('direct_enrolment_drafts').doc(_draftId).set({
        ..._data,
        'createdBy': auth.user.id,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!_draftPersisted) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _draftPersisted = true;
      if (!quiet && mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved just now')));
    } on FirebaseException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to save — Retry (${e.message ?? e.code})'),
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _isMeaningfulDraft =>
      _first.text.trim().isNotEmpty ||
      _middle.text.trim().isNotEmpty ||
      _last.text.trim().isNotEmpty ||
      _dob.text.trim().isNotEmpty ||
      _guardians.isNotEmpty ||
      _step > 0;

  bool get _guardianOk =>
      _guardians.isNotEmpty || (_override && _overrideReason.trim().isNotEmpty);
  bool get _canUseGuardianOverride {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated) return false;
    return state.user.roles.any(
      (role) => const {
        UserRole.schoolAdmin,
        UserRole.director,
        UserRole.headTeacher,
        UserRole.deputyHead,
        UserRole.admissions,
        UserRole.registrar,
      }.contains(role),
    );
  }

  String? _dateOfBirthError(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Date of birth is required';
    final parts = raw.split('/');
    if (parts.length != 3) return 'Enter date as DD/MM/YYYY';
    final day = int.tryParse(parts[0]),
        month = int.tryParse(parts[1]),
        year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null)
      return 'Enter a valid date of birth';
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day)
      return 'Enter a valid date of birth';
    final now = DateTime.now();
    if (date.isAfter(now)) return 'Date of birth must be in the past';
    var age = now.year - date.year;
    if (DateTime(now.year, date.month, date.day).isAfter(now)) age--;
    return age < 3 || age > 18
        ? 'Learner age must be between 3 and 18 years'
        : null;
  }

  bool get _valid => switch (_step) {
    0 =>
      _first.text.trim().isNotEmpty &&
          _last.text.trim().isNotEmpty &&
          _dateOfBirthError(_dob.text) == null &&
          (_entry != 'Transfer' ||
              (_previousSchool.text.trim().isNotEmpty &&
                  _previousClass.text.trim().isNotEmpty)),
    1 => _guardianOk,
    2 => _year != null && _class != null && _term.text.trim().isNotEmpty,
    3 =>
      (!_enabled('transport') ||
              _boarding != 'Day learner' ||
              _transport.text.trim().isNotEmpty) &&
          (!_enabled('houses') ||
              _boarding != 'Boarding learner' ||
              _house.text.trim().isNotEmpty),
    5 => _consent && _requiredDocumentsComplete,
    6 => _allRequiredComplete,
    _ => true,
  };
  bool get _requiredDocumentsComplete => _documentRequirements
      .where((requirement) => requirement['required'] == true)
      .every(
        (requirement) => _documents.any(
          (document) =>
              document['status'] == 'uploaded' &&
              document['requirementId'] == requirement['id'],
        ),
      );
  bool get _allRequiredComplete =>
      _first.text.trim().isNotEmpty &&
      _last.text.trim().isNotEmpty &&
      _dateOfBirthError(_dob.text) == null &&
      _guardianOk &&
      _year != null &&
      _class != null &&
      _term.text.trim().isNotEmpty &&
      _consent &&
      _requiredDocumentsComplete;
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
      setState(() => _submittedCurrentStep = true);
      _form.currentState?.validate();
      await Future<void>.delayed(Duration.zero);
      final invalid = _firstInvalidKey.currentContext;
      if (invalid != null) {
        await Scrollable.ensureVisible(
          invalid,
          duration: const Duration(milliseconds: 250),
          alignment: .15,
        );
      }
      return;
    }
    setState(() => _submittedCurrentStep = false);
    await _save(quiet: true);
    if (!mounted) return;
    if (_step == 6) return _enrol();
    setState(() => _step++);
  }

  // A long multi-step form can outlast the cached ID token; force a refresh
  // before the call instead of letting a stale token surface as a confusing
  // "unauthenticated" failure after all the data entry. This can fail
  // transiently on a flaky connection (very plausible mid-form), so retry a
  // few times before concluding the user is actually signed out - a single
  // network hiccup here must never be reported to the user as "your session
  // expired," since the real Firebase session is untouched.
  Future<void> _refreshIdTokenWithRetry() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      try {
        await user.getIdToken(true);
        return;
      } catch (_) {
        if (attempt == 2) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
  }

  Future<void> _enrol() async {
    setState(() => _enrolling = true);
    try {
      await _refreshIdTokenWithRetry();
      final r = await FirebaseFunctions.instance
          .httpsCallable('directEnrolLearner')
          .call({
            'draftId': _draftId,
            if (_feePlanMatch != null) 'feePlanId': _feePlanMatch!.planId,
            'selectedOptionalLineIds': _selectedFeeAddOnIds.toList(),
            if (_bursaryEnabled)
              'bursary': {
                'reason': _bursaryReason.text.trim(),
                'amount': double.tryParse(_bursaryAmount.text.trim()) ?? 0,
                'isPercentage': _bursaryIsPercentage,
              },
          });
      final v = Map<String, dynamic>.from(r.data as Map);
      if (!mounted) return;
      final billingWarning = v['billingWarning'] as String?;
      if (billingWarning != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Learner enrolled, but billing: $billingWarning'),
          ),
        );
      }
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
              e.code == 'unauthenticated'
                  ? (FirebaseAuth.instance.currentUser == null
                        ? 'Your session expired. Sign in again — your progress is saved as a draft.'
                        : 'Could not verify your sign-in — check your connection and try again. Your progress is saved as a draft.')
                  : e.message ?? 'Enrolment failed. The draft is still saved.',
            ),
          ),
        );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not verify your sign-in — check your connection and try again. Your progress is saved as a draft.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  void dispose() {
    for (final x in [
      _yearsSub,
      _classesSub,
      _streamsSub,
      _termsSub,
      _schoolSub,
    ]) {
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
      _guardianSearch,
      _bursaryReason,
      _bursaryAmount,
    ]) {
      x.dispose();
    }
    super.dispose();
  }

  String get _studentCategory =>
      _boarding == 'Boarding learner' ? 'boarding' : 'day';

  Future<void> _lookupFeePlan() async {
    final year = _year, cls = _class;
    if (year == null || cls == null) return;
    final termId = _termIdFor(year);
    final key = '${year.id}|$termId|${cls.id}|$_studentCategory';
    if (_feePlanMatchedKey == key) return;
    _feePlanMatchedKey = key;
    if (termId == null) {
      setState(() {
        _feePlanMatch = null;
        _selectedFeeAddOnIds.clear();
        _feePlanLoading = false;
      });
      return;
    }
    setState(() => _feePlanLoading = true);
    final result = await sl<FeeBillingRepository>().findMatchingFeePlan(
      schoolId: widget.schoolId,
      academicYearId: year.id,
      termId: termId,
      classId: cls.id,
      studentCategory: _studentCategory,
    );
    if (!mounted) return;
    setState(() {
      _feePlanMatch = result.fold((_) => null, (m) => m);
      _selectedFeeAddOnIds.clear();
      _feePlanLoading = false;
    });
  }

  // `_term` is a free-text field on this wizard (unlike the structured
  // AcademicTerm picker in the 12-step enrollment wizard), so there is no
  // guaranteed termId to hand `findMatchingFeePlan`. Best-effort: match it
  // against this school's real terms for the selected year by name.
  String? _termIdFor(AcademicYear year) {
    final typed = _term.text.trim().toLowerCase();
    return _terms
        .where(
          (t) =>
              t.academicYearId == year.id &&
              (t.name.toLowerCase() == typed || t.isCurrent),
        )
        .firstOrNull
        ?.id;
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
          _step < 0 ? 'Add learner' : 'Enrol learner',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_step < 0)
            IconButton(
              tooltip: 'Help',
              icon: const Icon(Icons.help_outline_rounded),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Adding a learner'),
                  content: const Text(
                    'Choose direct enrolment for learners already accepted by the school. '
                    'Choose an admission application for prospective learners. You can save meaningful progress and resume it later.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              ),
            ),
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
  Widget _choice() {
    final auth = context.read<AuthBloc>().state;
    final uid = auth is AuthAuthenticated ? auth.user.id : null;
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _academicContext(),
              const SizedBox(height: 20),
              Text(
                'Choose an enrolment path',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the option that best matches this learner’s status.\nYou can save your progress and return anytime.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.28,
                ),
              ),
              const SizedBox(height: 16),
              _choiceCard(
                'Direct enrolment',
                'Create an active learner record now',
                Icons.person_add_alt_1_outlined,
                _selectedPath == 'direct',
                () => setState(() => _selectedPath = 'direct'),
                forWhom: 'For learners already accepted by the school',
                estimate: 'About 7 minutes',
              ),
              const SizedBox(height: 12),
              _choiceCard(
                'Admission application',
                'Collect an application for review before enrolment',
                Icons.description_outlined,
                _selectedPath == 'admission',
                () => setState(() => _selectedPath = 'admission'),
                forWhom: 'For prospective learners',
                estimate: 'About 3 minutes',
              ),
              if (uid != null) ...[
                const SizedBox(height: 24),
                _draftSection(uid),
              ],
              const SizedBox(height: 20),
              _whatYouNeed(),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_selectedPath == 'direct') {
                    setState(() => _step = 0);
                  } else {
                    context.push(
                      '/staff/admin/admissions/new',
                      extra: widget.schoolId,
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  'Continue with ${_selectedPath == 'direct' ? 'direct enrolment' : 'admission application'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceCard(
    String title,
    String sub,
    IconData icon,
    bool selected,
    VoidCallback onTap, {
    required String forWhom,
    required String estimate,
  }) {
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 27, color: ink),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 21,
                              color: ink,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle_outline_rounded
                          : Icons.circle_outlined,
                      color: ink,
                      size: 27,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 41, top: 5),
                  child: Text(
                    sub,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: muted,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 41, top: 12),
                  child: Text(
                    '•  $forWhom',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 15, color: ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 41, top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 21, color: ink),
                      const SizedBox(width: 10),
                      Text(
                        estimate,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _academicContext() {
    final year =
        _years.where((item) => item.isCurrent).firstOrNull?.name ??
        'Academic year';
    final term =
        _terms.where((item) => item.isCurrent).firstOrNull?.name ??
        'Current term';
    return OutlinedButton.icon(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Academic context is set in School structure.'),
        ),
      ),
      icon: const Icon(Icons.calendar_month_outlined),
      label: Row(
        children: [
          Expanded(
            child: Text(
              '$year · $term · Main campus',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text('Change', style: TextStyle(fontWeight: FontWeight.w700)),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(68),
        alignment: Alignment.centerLeft,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  bool _isResumable(Map<String, dynamic> data) {
    if (data['status'] != 'draft') return false;
    final learner = Map<String, dynamic>.from(data['learner'] ?? const {});
    return (learner['firstNames'] as String? ?? '').trim().isNotEmpty ||
        (learner['surname'] as String? ?? '').trim().isNotEmpty ||
        ((data['step'] as num?)?.toInt() ?? 0) > 0;
  }

  Widget _draftSection(String uid) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db
            .collection('direct_enrolment_drafts')
            .where('schoolId', isEqualTo: widget.schoolId)
            .where('createdBy', isEqualTo: uid)
            .where('status', isEqualTo: 'draft')
            .snapshots(),
        builder: (context, snapshot) {
          final drafts =
              (snapshot.data?.docs ??
                      const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                  .where((doc) => _isResumable(doc.data()))
                  .toList()
                ..sort(
                  (a, b) =>
                      _draftDate(b.data()).compareTo(_draftDate(a.data())),
                );
          if (drafts.isEmpty) return const SizedBox.shrink();
          final latest = drafts.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'In progress',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _resumeRow(latest),
              if (drafts.length >= 2) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showAllDrafts(drafts),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: Text('View all drafts (${drafts.length})'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ],
            ],
          );
        },
      );

  DateTime _draftDate(Map<String, dynamic> data) =>
      (data['updatedAt'] as Timestamp?)?.toDate() ??
      (data['createdAt'] as Timestamp?)?.toDate() ??
      DateTime.fromMillisecondsSinceEpoch(0);

  Widget _resumeRow(QueryDocumentSnapshot<Map<String, dynamic>> draft) {
    final learner = Map<String, dynamic>.from(
      draft.data()['learner'] ?? const {},
    );
    final name = '${learner['firstNames'] ?? ''} ${learner['surname'] ?? ''}'
        .trim();
    return OutlinedButton(
      onPressed: () => _load(draft),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(78),
        alignment: Alignment.centerLeft,
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name.isEmpty ? 'Resume draft' : 'Resume draft · $name',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'Last saved ${_savedLabel(_draftDate(draft.data()))}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  String _savedLabel(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0)
      return 'today at ${TimeOfDay.fromDateTime(time).format(context)}';
    return '${now.difference(time).inDays} days ago';
  }

  Future<void> _showAllDrafts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> drafts,
  ) async => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'In progress',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final draft in drafts)
            ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: Text(_draftName(draft.data())),
              subtitle: Text(
                'Last saved ${_savedLabel(_draftDate(draft.data()))}',
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _load(draft);
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Discard draft',
                onPressed: () => _confirmDiscard(draft, sheetContext),
              ),
            ),
        ],
      ),
    ),
  );

  String _draftName(Map<String, dynamic> data) {
    final learner = Map<String, dynamic>.from(data['learner'] ?? const {});
    final name = '${learner['firstNames'] ?? ''} ${learner['surname'] ?? ''}'
        .trim();
    return name.isEmpty ? 'Untitled enrolment draft' : name;
  }

  Future<void> _confirmDiscard(
    QueryDocumentSnapshot<Map<String, dynamic>> draft,
    BuildContext sheetContext,
  ) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard draft?'),
        content: const Text(
          'This removes the saved progress and cannot be resumed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep draft'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true) {
      await draft.reference.set({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (sheetContext.mounted) Navigator.pop(sheetContext);
    }
  }

  Widget _whatYouNeed() => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you’ll need',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _need(
            Icons.person_outline,
            'Learner details',
            'Full name, date of birth, and other learner information',
          ),
          _need(
            Icons.phone_outlined,
            'Guardian contact',
            'Parent/guardian details and communication preferences',
          ),
          _need(
            Icons.account_balance_outlined,
            'Placement information',
            'Grade/Year level and programme preferences',
          ),
          _need(
            Icons.verified_user_outlined,
            'Consent & documents',
            'Authorisations and supporting documents (if applicable)',
          ),
          const Divider(height: 30),
          _need(
            Icons.lock_outline,
            'Your information is secure',
            'Handled in accordance with our privacy policy.',
          ),
        ],
      ),
    ),
  );
  Widget _need(IconData icon, String title, String detail) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                detail,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _flow() => Form(
    key: _form,
    child: Column(
      children: [
        Padding(padding: const EdgeInsets.all(20), child: _Progress(_step + 1)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              if (_submittedCurrentStep) _ErrorSummary(step: _step + 1),
              _body(),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide())),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() {
                    _submittedCurrentStep = false;
                    _step = _step == 0 ? -1 : _step - 1;
                  }),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _enrolling ? null : _next,
                    child: Text(
                      _enrolling
                          ? 'Enrolling…'
                          : _step == 6
                          ? 'Enrol learner'
                          : 'Continue',
                    ),
                  ),
                ),
              ],
            ),
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
    4 => _fees(),
    5 => _documentsPage(),
    _ => _review(),
  };
  Widget _details() => _section(
    'Learner details',
    'Record legal identity details required by your school.',
    [
      _field(
        _first,
        'First name',
        required: true,
        caps: TextCapitalization.words,
      ),
      _field(_middle, 'Middle name (optional)', caps: TextCapitalization.words),
      _field(
        _last,
        'Last name',
        required: true,
        caps: TextCapitalization.words,
      ),
      _field(
        _dob,
        'Date of birth',
        required: true,
        type: TextInputType.datetime,
        hint: 'DD/MM/YYYY',
        dateOfBirth: true,
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
    'At least one parent or guardian is required to activate enrolment.',
    [
      _field(
        _guardianSearch,
        'Search existing guardians',
        hint: 'Search by name, email or phone',
      ),
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
      if (_canUseGuardianOverride) ...[
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _override,
          onChanged: (v) => setState(() => _override = v),
          title: const Text('Authorised override'),
          subtitle: const Text(
            'Use only when a guardian cannot be linked. This is recorded in the audit log.',
          ),
        ),
      ],
      if (_override && _canUseGuardianOverride)
        TextFormField(
          initialValue: _overrideReason,
          onChanged: (v) => _overrideReason = v,
          decoration: const InputDecoration(labelText: 'Reason for override *'),
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
        required: false,
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
    'Tell us about support or services this learner needs.',
    [
      if (_enabled('boarding'))
        _select(
          'Day or boarding status',
          _boarding,
          const ['Day learner', 'Boarding learner'],
          (v) => setState(() {
            _boarding = v!;
            if (_boarding != 'Day learner') _transport.clear();
          }),
        ),
      if (_enabled('transport') && _boarding == 'Day learner')
        _field(_transport, 'Transport route', required: true),
      if (_enabled('houses') && _boarding == 'Boarding learner')
        _field(_house, 'House / dormitory', required: true),
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
  Widget _fees() {
    // Build-time trigger (not just on step transition) so a lookup that
    // couldn't resolve a termId yet (terms/years/classes still streaming
    // in) retries automatically on the next rebuild instead of being
    // permanently cached against a null result.
    WidgetsBinding.instance.addPostFrameCallback((_) => _lookupFeePlan());
    final match = _feePlanMatch;
    final required = (match?.lines ?? const []).where((l) => l.required);
    final optional = (match?.lines ?? const []).where((l) => !l.required);
    return _section('Fees', 'Set up this learner\'s fee plan.', [
      if (_feePlanLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (match == null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Notice(
              'No published fee plan matches this class, term and '
              'day/boarding status yet. You can continue enrolling - '
              'billing will stay pending until a fee plan is published in '
              'Structure > Academics > Fee Plans.',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push(
                '/staff/admin/structure/academics/fee-structures',
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Open Fee Plans'),
            ),
          ],
        )
      else ...[
        Text(
          'Select required fee plan *',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(match.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan summary',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final line in required)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(line.name)),
                      Text(CurrencyFormatter.ugx(line.amountUgx.toDouble())),
                    ],
                  ),
                ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    CurrencyFormatter.ugx(
                      required
                          .fold<int>(0, (s, l) => s + l.amountUgx)
                          .toDouble(),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (optional.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Optional services',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            'Select any additional services you would like to add.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          for (final line in optional)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              value: _selectedFeeAddOnIds.contains(line.chargeId),
              title: Text(line.name),
              subtitle: Text(CurrencyFormatter.ugx(line.amountUgx.toDouble())),
              onChanged: (checked) => setState(() {
                if (checked ?? false) {
                  _selectedFeeAddOnIds.add(line.chargeId);
                } else {
                  _selectedFeeAddOnIds.remove(line.chargeId);
                }
              }),
            ),
        ],
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total billed',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              CurrencyFormatter.ugx(_feeBilledTotalUgx.toDouble()),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
      const Divider(height: 32),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _bursaryEnabled,
        onChanged: (v) => setState(() => _bursaryEnabled = v),
        title: const Text('Award bursary / discount'),
        subtitle: const Text('Reduces this learner\'s billed fees.'),
      ),
      if (_bursaryEnabled) ...[
        _select(
          'Type',
          _bursaryIsPercentage ? 'Percentage' : 'Fixed amount',
          const ['Percentage', 'Fixed amount'],
          (v) => setState(() => _bursaryIsPercentage = v == 'Percentage'),
        ),
        const SizedBox(height: 8),
        _field(
          _bursaryAmount,
          _bursaryIsPercentage ? 'Discount (%)' : 'Discount (UGX)',
          type: TextInputType.number,
        ),
        const SizedBox(height: 8),
        _field(_bursaryReason, 'Reason', lines: 2),
      ],
    ]);
  }

  Widget _documentsPage() {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final error = Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents & consent',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Requirements are configured by your school. Files may be completed later where policy permits.',
          style: TextStyle(color: onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supporting files',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (_documentRequirements.isNotEmpty) ...[
                  Text(
                    'Required documents',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  for (final requirement in _documentRequirements.where(
                    (r) => r['required'] == true,
                  ))
                    _documentRequirementRow(requirement),
                  const SizedBox(height: 12),
                  if (_documentRequirements.any(
                    (r) => r['required'] != true,
                  )) ...[
                    Text(
                      'Optional documents',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    for (final requirement in _documentRequirements.where(
                      (r) => r['required'] != true,
                    ))
                      _documentRequirementRow(requirement),
                  ],
                ] else if (_documents.isEmpty)
                  const _Notice(
                    'No files uploaded yet. Missing-document status is checked at enrolment.',
                  )
                else
                  ..._documents.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.insert_drive_file_outlined),
                        title: Text(d['name']),
                        subtitle: Text(
                          d['status'] == 'uploading'
                              ? 'Uploading…'
                              : 'Uploaded',
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove',
                          onPressed: () => setState(() => _documents.remove(d)),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: () => _upload(),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload document'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            side: BorderSide(
              color: _consent ? Theme.of(context).dividerColor : error,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy and guardian consent',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'I consent to the enrolment of this learner and confirm that the information provided is true and correct. We collect and use personal information in accordance with the Privacy Notice for Learner Enrolment.',
                        style: TextStyle(color: onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Checkbox(
                  value: _consent,
                  onChanged: (v) => setState(() => _consent = v ?? false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _documentRequirementRow(Map<String, dynamic> requirement) {
    final uploaded = _documents
        .where((d) => d['requirementId'] == requirement['id'])
        .firstOrNull;
    final required = requirement['required'] == true;
    final types =
        (requirement['allowedTypes'] as List?)?.join(', ') ?? 'PDF, JPG or PNG';
    final limit = requirement['maxSizeMb'] ?? 10;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        uploaded == null
            ? Icons.description_outlined
            : Icons.check_circle_outline,
      ),
      title: Text(
        '${requirement['name'] ?? 'Document'}${required ? ' *' : ' (optional)'}',
      ),
      subtitle: Text(
        uploaded == null
            ? '${required ? 'Missing — required' : 'Not uploaded'}\n$types up to $limit MB'
            : '${uploaded['name']} · Uploaded',
      ),
      isThreeLine: true,
      trailing: OutlinedButton(
        onPressed: () => _upload(requirement: requirement),
        child: Text(uploaded == null ? 'Upload' : 'Replace'),
      ),
    );
  }

  Widget _review() {
    final missing = <String>[
      if (_first.text.trim().isEmpty ||
          _last.text.trim().isEmpty ||
          _dateOfBirthError(_dob.text) != null)
        'Learner details are incomplete',
      if (!_guardianOk) 'Parent/guardian is incomplete',
      if (_year == null || _class == null || _term.text.trim().isEmpty)
        'Academic placement is incomplete',
      if (!_consent) 'Guardian consent is required',
      if (!_requiredDocumentsComplete) 'A required document is missing',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & enrol',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Check your information before you enrol.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (missing.isNotEmpty)
          Semantics(
            liveRegion: true,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.error),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Some required information is missing',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final m in missing)
                    Padding(
                      padding: const EdgeInsets.only(left: 32, top: 2),
                      child: Text(
                        '• $m',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        _summary(
          'Learner',
          '${_first.text} ${_last.text}',
          '${_dob.text} · $_entry',
          complete:
              _first.text.trim().isNotEmpty &&
              _last.text.trim().isNotEmpty &&
              _dateOfBirthError(_dob.text) == null,
        ),
        _summary(
          'Parent/guardian',
          _guardians.isEmpty
              ? 'Authorised override'
              : _guardians.map((x) => x['name']).join(', '),
          _override ? _overrideReason : 'Primary/contact consent recorded',
          complete: _guardianOk,
        ),
        _summary(
          'Academic placement',
          '${_class?.name ?? 'Not selected'} · ${_year?.name ?? ''}',
          _term.text,
          complete:
              _year != null && _class != null && _term.text.trim().isNotEmpty,
        ),
        _summary(
          'Support & services',
          _boarding,
          _transport.text.isEmpty ? 'No transport selected' : _transport.text,
          complete: true,
        ),
        _summary(
          'Fees',
          _feePlanMatch == null
              ? 'Billing pending'
              : CurrencyFormatter.ugx(_feeBilledTotalUgx.toDouble()),
          _feePlanMatch == null
              ? 'No fee plan matched yet'
              : _bursaryEnabled
              ? 'Bursary/discount will be applied'
              : _feePlanMatch!.name,
          complete: true,
        ),
        _summary(
          'Documents & consent',
          _consent ? 'Consent confirmed' : 'Consent missing',
          '${_documents.length} file(s) uploaded',
          complete: _consent && _requiredDocumentsComplete,
        ),
        const SizedBox(height: 8),
        const _Notice(
          'After you confirm, a duplicate-safe learner ID is generated. Fee setup does not block enrolment.',
        ),
      ],
    );
  }

  Widget _section(String title, String sub, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Text(
        sub,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 20),
      for (final item in items) ...[item, const SizedBox(height: 16)],
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
    bool dateOfBirth = false,
  }) => Container(
    key: identical(c, _first) ? _firstInvalidKey : null,
    child: TextFormField(
      controller: c,
      keyboardType: type,
      maxLines: lines,
      textCapitalization: caps,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        suffixIcon: dateOfBirth
            ? const Icon(Icons.calendar_today_outlined)
            : null,
      ),
      onTap: dateOfBirth
          ? () async {
              final now = DateTime.now();
              final selected = await showDatePicker(
                context: context,
                initialDate: DateTime(now.year - 8),
                firstDate: DateTime(now.year - 100),
                lastDate: now,
              );
              if (selected != null)
                c.text =
                    '${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}/${selected.year}';
            }
          : null,
      validator: dateOfBirth
          ? _dateOfBirthError
          : required
          ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null
          : null,
      autovalidateMode: _submittedCurrentStep
          ? AutovalidateMode.always
          : AutovalidateMode.onUserInteraction,
    ),
  );
  Widget _select(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> changed, {
    bool required = true,
  }) => DropdownButtonFormField<String>(
    value: values.contains(value) ? value : values.first,
    decoration: InputDecoration(labelText: required ? '$label *' : label),
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
    ValueChanged<T?> changed, {
    bool required = true,
  }) => DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(labelText: required ? '$label *' : label),
    items: values
        .map((x) => DropdownMenuItem(value: x, child: Text(labelOf(x))))
        .toList(),
    onChanged: changed,
    validator: required ? (x) => x == null ? '$label is required' : null : null,
  );
  Widget _summary(
    String title,
    String value,
    String detail, {
    required bool complete,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => setState(() {
          _submittedCurrentStep = false;
          _step = switch (title) {
            'Learner' => 0,
            'Parent/guardian' => 1,
            'Academic placement' => 2,
            'Support & services' => 3,
            'Fees' => 4,
            _ => 5,
          };
        }),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$value\n$detail'),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              complete ? Icons.check_circle_outline : Icons.error_outline,
              size: 18,
              color: complete ? scheme.primary : scheme.error,
            ),
            const SizedBox(width: 6),
            Text(complete ? 'Complete' : 'Incomplete'),
            const SizedBox(width: 8),
            const Text('Edit'),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }

  static const _phoneCodes = ['+256', '+254', '+255', '+250', '+44', '+1'];

  String? _phoneError(String digits) {
    if (digits.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[0-9]+$').hasMatch(digits))
      return 'Enter a valid phone number';
    if (digits.length < 7 || digits.length > 12) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _emailError(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    return ok ? null : 'Enter a valid email address';
  }

  Future<void> _guardian(Map<String, dynamic>? old) async {
    final n = TextEditingController(text: old?['name']),
        r = TextEditingController(text: old?['relationship']),
        e = TextEditingController(text: old?['email']);
    final oldPhone = (old?['phone'] as String?) ?? '';
    var code = _phoneCodes.firstWhere(
      (c) => oldPhone.startsWith(c),
      orElse: () => '+256',
    );
    final p = TextEditingController(
      text: oldPhone.startsWith(code)
          ? oldPhone.substring(code.length).trim()
          : oldPhone,
    );
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      child: DropdownButtonFormField<String>(
                        value: code,
                        decoration: const InputDecoration(labelText: 'Code *'),
                        items: _phoneCodes
                            .map(
                              (x) => DropdownMenuItem(value: x, child: Text(x)),
                            )
                            .toList(),
                        onChanged: (x) => setD(() => code = x ?? code),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: p,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(labelText: 'Phone *'),
                        validator: (v) => _phoneError(v?.trim() ?? ''),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: e,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                  ),
                  validator: (v) => _emailError(v ?? ''),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
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
                    _phoneError(p.text.trim()) == null &&
                    _emailError(e.text) == null)
                  Navigator.pop(c, {
                    'id': old?['id'] ?? _uuid.v4(),
                    'name': n.text.trim(),
                    'relationship': r.text.trim(),
                    'phone': '$code${p.text.trim()}',
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

  Future<void> _upload({Map<String, dynamic>? requirement}) async {
    final picked = await FilePicker.pickFiles(withData: true);
    final f = picked?.files.single;
    if (f?.bytes == null) return;
    final doc = <String, dynamic>{
      'id': _uuid.v4(),
      'name': f!.name,
      'status': 'uploading',
      'size': f.size,
      if (requirement != null) 'requirementId': requirement['id'],
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
  static const _labels = [
    'Learner',
    'Guardian',
    'Placement',
    'Support',
    'Fees',
    'Documents',
    'Review',
  ];
  final int step;
  const _Progress(this.step);
  @override
  Widget build(BuildContext c) {
    final scheme = Theme.of(c).colorScheme;
    return Semantics(
      label: 'Step $step of 7: ${_labels[step - 1]}',
      child: Row(
        children: List.generate(7, (i) {
          final index = i + 1;
          final done = index < step;
          final current = index == step;
          final fill = done || current
              ? (current ? scheme.onSurface : scheme.onSurface)
              : Colors.transparent;
          final circle = Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: current || done ? fill : Colors.transparent,
              border: Border.all(
                color: current || done ? fill : scheme.outlineVariant,
              ),
            ),
            child: done
                ? Icon(Icons.check, size: 14, color: scheme.surface)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: current ? scheme.surface : scheme.onSurfaceVariant,
                    ),
                  ),
          );
          return i == 6
              ? circle
              : Expanded(
                  child: Row(
                    children: [
                      circle,
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: done
                              ? scheme.onSurface
                              : scheme.outlineVariant,
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }
}

class _ErrorSummary extends StatelessWidget {
  final int step;
  const _ErrorSummary({required this.step});
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.error),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Please correct the required information in step $step before continuing.',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
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
