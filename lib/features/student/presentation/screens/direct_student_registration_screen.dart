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
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_breakpoints.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_plan.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_billing_repository.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/transport_structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/student/data/student_document_uploader.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
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
  // Bumped on every _save() dispatch; a save only commits its own
  // _draftPersisted/success side effects if it's still the most recently
  // dispatched one by the time its write resolves. Without this, an earlier
  // slow save (e.g. dispatched by _next() before guardians were added) can
  // land after a later, faster save and silently overwrite it with stale
  // data - including resetting createdAt, since it read !_draftPersisted
  // before the first save had a chance to flip it.
  int _saveGeneration = 0;
  bool _saving = false, _enrolling = false, _consent = false, _override = false;
  bool _reviewed = false;
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
  EducationalLevel? _selectedLevel;
  Campus? _selectedCampus;
  List<AcademicYear> _years = [];
  List<SchoolClass> _classes = [];
  List<ClassStream> _allStreams = [];
  List<EducationalLevel> _levels = [];
  List<Campus> _campuses = [];
  bool _levelsLoaded = false;
  bool _classesLoaded = false;
  bool _campusesLoaded = false;
  Map<String, dynamic> _modules = {};
  List<Map<String, dynamic>> _documentRequirements = const [];
  // Tenant-configured guardian-consent policy
  // (`schools/{id}.enrolmentPolicy`). Defaults mirror
  // guardian_consent.js's DEFAULT_CONSENT_METHODS so the wizard works even
  // for a school that hasn't set enrolmentPolicy yet.
  List<String> _consentMethods = const ['guardian_signs_now', 'secure_link'];
  String _consentPolicyVersion = 'v1';
  String? _privacyNoticeUrl;
  String _consentText =
      'I consent to the enrolment of this learner and confirm that the '
      'information provided is true and correct. We collect and use '
      'personal information in accordance with the Privacy Notice for '
      'Learner Enrolment.';
  // Locally selected method for the active guardian, before capture.
  String? _selectedConsentMethod;
  bool _consentActionInFlight = false;
  final _witnessName = TextEditingController();
  final _witnessRelationship = TextEditingController();
  List<String> _mealOptions = const [];
  String? _supportNotesPolicyUrl;
  List<TransportRoute> _routes = const [];
  List<TransportVehicle> _vehicles = const [];
  final Map<String, int> _routeOccupancy = {};
  StreamSubscription? _routesSub, _vehiclesSub, _occupancySub;
  final _audit = AuditRepository();
  // 'none' | 'school' — separate from the free-text legacy `_transport`
  // controller, which is retained only for the boarding/house field.
  String _transportChoice = 'none';
  String? _selectedRouteId;
  String? _mealChoice;
  // Defaults to '' (not null) so the "nothing changed" guard in
  // _saveSupportNotes short-circuits correctly when the support notes field
  // was never touched - otherwise every draft autosave attempted a write to
  // the clinical-restricted subcollection for an empty note, which fails
  // with a permission-denied for any staff member without a health/support
  // role and surfaced as a generic "Unable to save" error on the whole
  // draft, even though nothing about support notes had actually changed.
  String _lastSavedSupportText = '';
  bool _supportNotesAccessDenied = false;
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
  // Mirror of draft.guardianConsent, written server-side only by
  // guardian_consent.js's callables — never set directly by this client.
  Map<String, dynamic>? _guardianConsent;
  StreamSubscription? _yearsSub,
      _classesSub,
      _streamsSub,
      _termsSub,
      _levelsSub,
      _campusesSub;
  StreamSubscription? _schoolSub;
  StreamSubscription? _draftConsentSub;
  List<AcademicTerm> _terms = [];

  /// Tenant-configured entry types (`schools/{id}.enrolmentPolicy.entryTypes`).
  /// Defaults are used only when the school hasn't configured any.
  List<String> _entryTypeOptions = const [
    'New admission',
    'Transfer',
    'Returning',
  ];

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
  ScholarshipAwardType _bursaryType = ScholarshipAwardType.partial;

  // Same finance-capability permission used to gate scholarship/discount
  // assignment in enrollment_setup_wizard_bloc.dart's `_FinanceStep` - this
  // wizard has no bloc, so the check is cached locally per screen instance
  // rather than re-evaluated on every rebuild.
  bool? _canManageFinance;

  Future<bool> _checkFinancePermission() async {
    if (_canManageFinance != null) return _canManageFinance!;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return false;
    final result = await sl<PermissionEvaluator>().can(
      Permission.enrollmentBursaryAssign,
      auth.user,
    );
    final allowed = result.fold((_) => false, (v) => v);
    if (mounted) setState(() => _canManageFinance = allowed);
    return allowed;
  }

  int get _feeBilledTotalUgx => (_feePlanMatch?.lines ?? const [])
      .where((l) => l.required || _selectedFeeAddOnIds.contains(l.chargeId))
      .fold(0, (sum, l) => sum + l.amountUgx);

  void _retrySnack(String message, VoidCallback retry) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: 'Retry', onPressed: retry),
      ),
    );
  }

  void _subscribeYears() {
    _yearsSub?.cancel();
    _yearsSub = _repo.watchAcademicYears(widget.schoolId).listen(
      (v) {
        if (mounted)
          setState(() {
            _years = v.where((x) => !x.isArchived).toList();
            _year ??= _years.where((x) => x.isCurrent).firstOrNull;
          });
      },
      onError: (_) =>
          _retrySnack('Could not load academic years.', _subscribeYears),
    );
  }

  void _subscribeClasses() {
    _classesSub?.cancel();
    _classesSub = _repo.watchClasses(widget.schoolId).listen(
      (v) {
        if (mounted)
          setState(() => _classes = v.where((x) => x.isActive).toList());
        _classesLoaded = true;
      },
      onError: (_) => _retrySnack('Could not load classes.', _subscribeClasses),
    );
  }

  void _subscribeStreams() {
    _streamsSub?.cancel();
    _streamsSub = _repo.watchStreams(widget.schoolId).listen(
      (v) {
        if (mounted) setState(() => _allStreams = v);
      },
      onError: (_) =>
          _retrySnack('Could not load class streams.', _subscribeStreams),
    );
  }

  void _subscribeTerms() {
    _termsSub?.cancel();
    _termsSub = _repo.watchAcademicTerms(widget.schoolId).listen(
      (v) {
        if (mounted)
          setState(() => _terms = v.where((x) => !x.isArchived).toList());
      },
      onError: (_) =>
          _retrySnack('Could not load academic terms.', _subscribeTerms),
    );
  }

  void _subscribeLevels() {
    _levelsSub?.cancel();
    _levelsSub = _repo.watchLevels(widget.schoolId).listen(
      (v) {
        if (mounted)
          setState(() {
            _levels = v.where((x) => x.isActive).toList();
            _selectedLevel ??= _levels
                .where((x) => x.id == _class?.levelId)
                .firstOrNull;
            _levelsLoaded = true;
          });
      },
      onError: (_) =>
          _retrySnack('Could not load education levels.', _subscribeLevels),
    );
  }

  void _subscribeCampuses() {
    _campusesSub?.cancel();
    _campusesSub = _repo.watchCampuses(widget.schoolId).listen(
      (v) {
        if (mounted)
          setState(() {
            _campuses = v.where((x) => x.isActive).toList();
            _selectedCampus ??=
                _campuses.where((x) => x.isPrimary).firstOrNull ??
                _campuses.firstOrNull;
            _campusesLoaded = true;
          });
      },
      onError: (_) =>
          _retrySnack('Could not load campuses.', _subscribeCampuses),
    );
  }

  @override
  void initState() {
    super.initState();
    _draftId = _uuid.v4();
    _studentId = _uuid.v4();
    _subscribeYears();
    _subscribeClasses();
    _subscribeStreams();
    _subscribeTerms();
    _subscribeLevels();
    _subscribeCampuses();
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
              final policy = Map<String, dynamic>.from(
                data['enrolmentPolicy'] ?? {},
              );
              _mealOptions = List<String>.from(
                policy['mealOptions'] as List? ?? const [],
              );
              _supportNotesPolicyUrl =
                  policy['supportNotesPolicyUrl'] as String?;
              final configuredConsentMethods = List<String>.from(
                policy['consentMethods'] as List? ?? const [],
              );
              _consentMethods = configuredConsentMethods.isNotEmpty
                  ? configuredConsentMethods
                  : const ['guardian_signs_now', 'secure_link'];
              _consentPolicyVersion =
                  policy['consentPolicyVersion'] as String? ?? 'v1';
              _privacyNoticeUrl = policy['privacyNoticeUrl'] as String?;
              _consentText =
                  (policy['consentText'] as String?)?.trim().isNotEmpty == true
                  ? policy['consentText'] as String
                  : _consentText;
              if (_selectedConsentMethod != null &&
                  !_consentMethods.contains(_selectedConsentMethod)) {
                _selectedConsentMethod = null;
              }
              final configuredEntryTypes = List<String>.from(
                policy['entryTypes'] as List? ?? const [],
              );
              _entryTypeOptions = configuredEntryTypes.isNotEmpty
                  ? configuredEntryTypes
                  : const ['New admission', 'Transfer', 'Returning'];
              if (!_entryTypeOptions.contains(_entry)) {
                _entry = _entryTypeOptions.first;
              }
            });
        });
    _routesSub = _repo.watchTransportRoutes(widget.schoolId).listen((v) {
      if (mounted)
        setState(() => _routes = v.where((x) => x.isActive).toList());
    });
    _vehiclesSub = _repo.watchTransportVehicles(widget.schoolId).listen((v) {
      if (mounted)
        setState(() => _vehicles = v.where((x) => x.isActive).toList());
    });
    _occupancySub = _db
        .collection('students')
        .where('schoolId', isEqualTo: widget.schoolId)
        .where('services.transportRouteId', isNotEqualTo: null)
        .snapshots()
        .listen((snap) {
          if (!mounted) return;
          final counts = <String, int>{};
          for (final doc in snap.docs) {
            final routeId =
                (doc.data()['services']
                        as Map<String, dynamic>?)?['transportRouteId']
                    as String?;
            if (routeId == null) continue;
            counts[routeId] = (counts[routeId] ?? 0) + 1;
          }
          setState(
            () => _routeOccupancy
              ..clear()
              ..addAll(counts),
          );
        });
  }

  int _routeCapacity(String routeId) => _vehicles
      .where((v) => v.routeId == routeId)
      .fold(0, (sum, v) => sum + v.capacity);
  int _routeAvailable(String routeId) {
    final capacity = _routeCapacity(routeId);
    if (capacity <= 0) return 0;
    return capacity - (_routeOccupancy[routeId] ?? 0);
  }

  List<TransportRoute> get _availableRoutes =>
      _routes.where((r) => _routeAvailable(r.id) > 0).toList();

  void _load(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final l = Map<String, dynamic>.from(d['learner'] ?? {});
    final p = Map<String, dynamic>.from(d['placement'] ?? {});
    final s = Map<String, dynamic>.from(d['services'] ?? {});
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
      _selectedLevel = _levels
          .where((x) => x.id == (p['levelId'] ?? _class?.levelId))
          .firstOrNull;
      _selectedCampus = _campuses
          .where((x) => x.id == (p['campusId'] ?? _class?.campusId))
          .firstOrNull;
      _boarding = s['boardingStatus'] as String? ?? _boarding;
      _transportChoice = s['transportChoice'] as String? ?? _transportChoice;
      _selectedRouteId = s['transportRouteId'] as String?;
      _mealChoice = s['mealChoice'] as String?;
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
      _guardianConsent = d['guardianConsent'] != null
          ? Map<String, dynamic>.from(d['guardianConsent'] as Map)
          : null;
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
        _bursaryType =
            ScholarshipAwardType.values
                .where((t) => t.name == bursary['type'])
                .firstOrNull ??
            ScholarshipAwardType.partial;
      }
    });
    _loadSupportNotes();
    _watchDraftConsent();
  }

  /// A secure consent link is redeemed by the guardian outside this app (an
  /// unauthenticated web page hitting `resolveGuardianConsentLink`), so
  /// staff need a live view of `draft.guardianConsent` rather than only the
  /// snapshot taken when the draft was first opened.
  void _watchDraftConsent() {
    _draftConsentSub?.cancel();
    _draftConsentSub = _db
        .collection('direct_enrolment_drafts')
        .doc(_draftId)
        .snapshots()
        .listen((snap) {
          if (!mounted) return;
          final consent = snap.data()?['guardianConsent'];
          setState(
            () => _guardianConsent = consent != null
                ? Map<String, dynamic>.from(consent as Map)
                : null,
          );
        });
  }

  Future<void> _loadSupportNotes() async {
    try {
      final snap = await _db
          .collection('direct_enrolment_drafts')
          .doc(_draftId)
          .collection('restricted')
          .doc('support')
          .get();
      final notes = snap.data()?['notes'] as String? ?? '';
      if (!mounted) return;
      setState(() {
        _support.text = notes;
        _lastSavedSupportText = notes;
        _supportNotesAccessDenied = false;
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' && mounted) {
        setState(() => _supportNotesAccessDenied = true);
      }
    }
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
      'levelId': _selectedLevel?.id,
      'levelName': _selectedLevel?.name,
      'campusId': _selectedCampus?.id,
      'campusName': _selectedCampus?.name,
      'classId': _class?.id,
      'className': _class?.name,
      'stream': _stream,
      'term': _term.text.trim(),
    },
    'services': {
      'boardingStatus': _boarding,
      'transportChoice': _boarding == 'Boarding learner'
          ? 'none'
          : _transportChoice,
      'transportRouteId': _boarding == 'Boarding learner'
          ? null
          : (_transportChoice == 'school' ? _selectedRouteId : null),
      'mealChoice': _mealOptions.isEmpty ? null : _mealChoice,
      'house': _house.text.trim(),
    },
    'documents': _documents,
    'consentAcknowledged': _consent,
    'guardianOverride': _override ? {'reason': _overrideReason} : null,
    'fees': {
      'planId': _feePlanMatch?.planId,
      'selectedOptionalLineIds': _selectedFeeAddOnIds.toList(),
      'bursary': _bursaryEnabled
          ? {
              'type': _bursaryType.name,
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
    // Snapshot both the outgoing generation number and whether this dispatch
    // considers the draft "new" before the network round-trip, so a slower
    // earlier save can never overwrite fields a faster later save already
    // wrote (see _saveGeneration doc comment above).
    final generation = ++_saveGeneration;
    final isFirstSaveForThisDispatch = !_draftPersisted;
    try {
      await _db
          .collection('direct_enrolment_drafts')
          .doc(_draftId)
          .set({
            ..._data,
            'createdBy': auth.user.id,
            'updatedAt': FieldValue.serverTimestamp(),
            if (isFirstSaveForThisDispatch)
              'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      if (generation != _saveGeneration) return;
      await _saveSupportNotes(auth.user.id);
      _draftPersisted = true;
      if (!quiet && mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved just now')));
    } on FirebaseException catch (e) {
      if (generation != _saveGeneration) return;
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to save — Retry (${e.message ?? e.code})'),
          ),
        );
    } catch (_) {
      if (generation != _saveGeneration) return;
      // Any other failure (e.g. genuinely offline, no connectivity at all)
      // must not trap the user on the current step - the draft simply
      // stays unsaved locally and the next successful save reconciles it.
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to save right now. Your progress will sync when you\'re back online.',
            ),
          ),
        );
    } finally {
      if (generation == _saveGeneration && mounted)
        setState(() => _saving = false);
    }
  }

  // Support/health notes are never stored on the draft doc that ordinary
  // enrolment staff can read — they live in a dedicated restricted
  // subcollection gated by `canManageClinicalRecords()` in firestore.rules,
  // mirroring the `student_medical_support` precedent. Every write is
  // logged so an approved reviewer can see who recorded what and when.
  Future<void> _saveSupportNotes(String userId) async {
    final text = _support.text.trim();
    if (text == _lastSavedSupportText) return;
    await _db
        .collection('direct_enrolment_drafts')
        .doc(_draftId)
        .collection('restricted')
        .doc('support')
        .set({
          'schoolId': widget.schoolId,
          'notes': text,
          'updatedBy': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    await _audit.logAction(
      schoolId: widget.schoolId,
      title: 'Support & health notes updated',
      description: text.isEmpty
          ? 'Support notes cleared for draft enrolment $_draftId'
          : 'Support notes recorded for draft enrolment $_draftId',
      iconName: 'health_and_safety',
      colorHex: '#F59E0B',
      userId: userId,
      relatedEntityId: _draftId,
    );
    _lastSavedSupportText = text;
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

  bool get _canChangeAcademicContext => _canUseGuardianOverride;

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
    2 =>
      _selectedLevel != null &&
          _year != null &&
          _class != null &&
          _term.text.trim().isNotEmpty,
    3 =>
      (!_enabled('transport') ||
              _isBoarding ||
              _transportChoice != 'school' ||
              _selectedRouteId != null) &&
          (!_enabled('houses') ||
              !_isBoarding ||
              _house.text.trim().isNotEmpty),
    5 => _consentSatisfied && _requiredDocumentsComplete,
    6 => _allRequiredComplete && _reviewed,
    _ => true,
  };

  /// True once guardian consent is captured via a permitted method, or the
  /// legacy single-checkbox flag was already set on an older draft.
  bool get _consentSatisfied => _consent || _consentCaptured;
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
      _selectedLevel != null &&
      _year != null &&
      _class != null &&
      _term.text.trim().isNotEmpty &&
      _consentSatisfied &&
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
                'type': _bursaryType.name,
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
      _levelsSub,
      _campusesSub,
      _schoolSub,
      _draftConsentSub,
      _routesSub,
      _vehiclesSub,
      _occupancySub,
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
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the option that best matches this learner’s status.\nYou can save your progress and return anytime.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                    Icon(icon, size: 24, color: ink),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: ink, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle_outline_rounded
                          : Icons.circle_outlined,
                      color: ink,
                      size: 24,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 36, top: 4),
                  child: Text(
                    sub,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: muted),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 36, top: 10),
                  child: Text(
                    '•  $forWhom',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: ink),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 36, top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 18, color: ink),
                      const SizedBox(width: 8),
                      Text(
                        estimate,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: ink),
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
    final campusLabel = !_campusesLoaded
        ? 'Loading campus…'
        : (_selectedCampus?.name ?? 'Main campus');
    final canChange = _canChangeAcademicContext && _campuses.length > 1;
    return OutlinedButton.icon(
      onPressed: canChange
          ? _pickCampus
          : (_canChangeAcademicContext
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Only one campus is configured for this school.',
                      ),
                    ),
                  )
                : null),
      icon: const Icon(Icons.calendar_month_outlined),
      label: Row(
        children: [
          Expanded(
            child: Text(
              '$year · $term · $campusLabel',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_canChangeAcademicContext) ...[
            const Text('Change', style: TextStyle(fontWeight: FontWeight.w700)),
            const Icon(Icons.chevron_right_rounded),
          ],
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

  Future<void> _pickCampus() async {
    final picked = await showModalBottomSheet<Campus>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Choose campus',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            for (final campus in _campuses)
              ListTile(
                leading: Icon(
                  campus.id == _selectedCampus?.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(campus.name),
                onTap: () => Navigator.pop(sheetContext, campus),
              ),
          ],
        ),
      ),
    );
    if (picked != null && picked.id != _selectedCampus?.id && mounted) {
      setState(() {
        _selectedCampus = picked;
        // Re-filtering classes by campus may make the current selection
        // incompatible; clear it (and the dependent stream) if so.
        if (_class != null &&
            _class!.campusId.isNotEmpty &&
            _class!.campusId != picked.id) {
          _class = null;
          _stream = null;
        }
      });
    }
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
        personName: true,
      ),
      _field(
        _middle,
        'Middle name (optional)',
        caps: TextCapitalization.words,
        personName: true,
      ),
      _field(
        _last,
        'Last name',
        required: true,
        caps: TextCapitalization.words,
        personName: true,
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
      _select(
        'Entry type',
        _entry,
        _entryTypeOptions,
        (v) => setState(() => _entry = v!),
      ),
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
      if (_guardians.length < 2) ...[
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
      ] else
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'A student can be linked to at most 2 parents/guardians. '
            'Remove one to add another.',
          ),
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
  List<SchoolClass> get _classesForSelectedLevel => _classes
      .where(
        (x) =>
            (_selectedLevel == null || x.levelId == _selectedLevel!.id) &&
            (x.campusId.isEmpty || x.campusId == _selectedCampus?.id),
      )
      .toList();
  List<ClassStream> get _activeClassStreams =>
      _allStreams.where((x) => x.classId == _class?.id && x.isActive).toList();

  Widget _placement() {
    final wide = MediaQuery.of(context).size.width >= AppBreakpoints.tablet;
    final classStreams = _activeClassStreams;
    final mainCard = _section(
      'Academic placement',
      'Choose where this learner will study for the selected academic year.',
      [
        _academicContext(),
        if (!_levelsLoaded)
          const _FieldLoadingPlaceholder(label: 'Education level')
        else if (_levels.isEmpty)
          _EmptyConfigNotice(
            message: 'No education levels configured for this school yet.',
            canOpenSetup: _canChangeAcademicContext,
            onOpenSetup: () => context.push(
              '/staff/admin/structure/academics/education-levels',
            ),
          )
        else
          _object<EducationalLevel>(
            'Education level',
            _selectedLevel,
            _levels,
            (x) => x.name,
            (v) => setState(() {
              _selectedLevel = v;
              if (_class != null && _class!.levelId != v?.id) {
                _class = null;
                _stream = null;
              }
            }),
          ),
        if (!_classesLoaded && _selectedLevel != null)
          const _FieldLoadingPlaceholder(label: 'Class')
        else if (_selectedLevel != null && _classesForSelectedLevel.isEmpty)
          _EmptyConfigNotice(
            message: 'No classes configured for this education level yet.',
            canOpenSetup: _canChangeAcademicContext,
            onOpenSetup: () =>
                context.push('/staff/admin/structure/academics/classes'),
          )
        else
          IgnorePointer(
            ignoring: _selectedLevel == null,
            child: Opacity(
              opacity: _selectedLevel == null ? 0.5 : 1,
              child: _object<SchoolClass>(
                'Class',
                _class,
                _classesForSelectedLevel,
                (x) => x.name,
                (v) => setState(() {
                  _class = v;
                  _stream = null;
                }),
              ),
            ),
          ),
        if (_class != null && classStreams.isEmpty)
          const Text('No streams for this class')
        else if (classStreams.isNotEmpty)
          _select(
            'Stream / section (optional)',
            _stream ?? 'No stream',
            ['No stream', ...classStreams.map((x) => x.name)],
            (v) => setState(() => _stream = v == 'No stream' ? null : v),
            required: false,
          ),
        if (_enabled('boarding'))
          _DayBoardingSelector(
            value: _boarding,
            onChanged: (v) => setState(() {
              _boarding = v;
              if (_boarding != 'Day learner') _transport.clear();
            }),
          ),
        _object(
          'Entry type',
          _entryTypeOptions.contains(_entry) ? _entry : _entryTypeOptions.first,
          _entryTypeOptions,
          (x) => x,
          (v) => setState(() => _entry = v!),
        ),
        _field(_term, 'Entry term', required: true),
        if ((_class?.capacity ?? 0) > 0)
          _Notice(
            'Capacity configured: ${_class!.capacity}. Availability is checked again on enrolment.',
          ),
      ],
    );
    final summaryCard = _enrolmentSummaryCard();
    return wide
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: mainCard),
                const SizedBox(width: 20),
                SizedBox(width: 340, child: summaryCard),
              ],
            ),
          )
        : Column(children: [mainCard, const SizedBox(height: 20), summaryCard]);
  }

  Widget _enrolmentSummaryCard() {
    final scheme = Theme.of(context).colorScheme;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    Widget checklistRow(String label, bool done) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: done ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrolment summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          checklistRow('Learner details complete', true),
          checklistRow('Guardian linked', true),
          checklistRow(
            _class != null ? 'Class selected' : 'Class not selected',
            _class != null,
          ),
          const Divider(height: 24),
          row('Academic year', _year?.name ?? 'Not selected'),
          row(
            'Campus',
            _selectedCampus?.name ??
                (_campuses.isEmpty ? 'Main campus' : 'Not selected'),
          ),
          row('Education level', _selectedLevel?.name ?? 'Not selected'),
          row('Class', _class?.name ?? 'Not selected'),
          row('Stream/section', _stream ?? 'Not set'),
          row('Day/boarding', _boarding),
          row('Entry type', _entry),
          const SizedBox(height: 12),
          const _Notice(
            'What happens next? Health, support and document details can be completed now or later, depending on your school\'s policy.',
          ),
        ],
      ),
    );
  }

  bool _enabled(String key) => _modules.isEmpty || _modules[key] == true;
  bool get _isBoarding => _boarding == 'Boarding learner';
  bool get _mealsEnabled => _enabled('meals') && _mealOptions.isNotEmpty;

  Widget _placementSummaryStrip() {
    final scheme = Theme.of(context).colorScheme;
    final parts = [
      _year?.name,
      _term.text.trim(),
      'Main campus',
      _class?.name,
      _boarding,
    ].where((x) => x != null && x.trim().isNotEmpty).join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _isBoarding ? Icons.home_work_outlined : Icons.school_outlined,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected placement',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  parts.isEmpty ? 'Not selected yet' : parts,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(String title, List<Widget> children) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _choiceTile({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _schoolServicesCard() {
    final routeChoices = _availableRoutes;
    return _serviceCard('School services', [
      if (!_isBoarding && _enabled('transport')) ...[
        Text('Transport', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            _choiceTile(
              icon: Icons.directions_bus_filled_outlined,
              label: 'No school transport',
              selected: _transportChoice == 'none',
              onTap: () => setState(() {
                _transportChoice = 'none';
                _selectedRouteId = null;
              }),
            ),
            const SizedBox(width: 10),
            _choiceTile(
              icon: Icons.directions_bus_outlined,
              label: 'Use school transport',
              selected: _transportChoice == 'school',
              onTap: () => setState(() => _transportChoice = 'school'),
            ),
          ],
        ),
        if (_transportChoice == 'none')
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Transport details are only needed if school transport is required.',
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (_transportChoice == 'school') ...[
          const SizedBox(height: 12),
          if (_routes.isEmpty)
            const _Notice(
              'No transport routes are configured for this school yet.',
            )
          else if (routeChoices.isEmpty)
            const _Notice(
              'All configured transport routes are at full capacity. Choose "No school transport" or contact Structure > Transport to add capacity.',
            )
          else
            DropdownButtonFormField<String>(
              initialValue: routeChoices.any((r) => r.id == _selectedRouteId)
                  ? _selectedRouteId
                  : null,
              decoration: const InputDecoration(labelText: 'Route *'),
              items: routeChoices
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                        '${r.name} · ${_routeAvailable(r.id)} seats available',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedRouteId = v),
              validator: (v) => v == null ? 'Select a transport route' : null,
              autovalidateMode: _submittedCurrentStep
                  ? AutovalidateMode.always
                  : AutovalidateMode.onUserInteraction,
            ),
        ],
        const Divider(height: 30),
      ],
      if (_isBoarding && _enabled('houses')) ...[
        _field(_house, 'House / dormitory', required: true),
        const Divider(height: 30),
      ],
      if (_enabled('meals')) ...[
        Text('Meals', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (!_mealsEnabled)
          const _Notice('This school has not configured meal services yet.')
        else ...[
          Row(
            children: [
              _choiceTile(
                icon: Icons.no_meals_outlined,
                label: 'Not required',
                selected: _mealChoice == null,
                onTap: () => setState(() => _mealChoice = null),
              ),
              const SizedBox(width: 10),
              _choiceTile(
                icon: Icons.restaurant_outlined,
                label: _mealOptions.first,
                selected: _mealChoice != null,
                onTap: () => setState(() => _mealChoice = _mealOptions.first),
              ),
            ],
          ),
          if (_mealOptions.length > 1 && _mealChoice != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: DropdownButtonFormField<String>(
                initialValue: _mealOptions.contains(_mealChoice)
                    ? _mealChoice
                    : _mealOptions.first,
                decoration: const InputDecoration(labelText: 'Meal option'),
                items: _mealOptions
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _mealChoice = v),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Meal options are set by your school and can be updated later.',
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
      if (!_enabled('transport') && !_enabled('houses') && !_enabled('meals'))
        const _Notice(
          'No optional service modules are enabled for this school.',
        ),
    ]);
  }

  Widget _healthSupportCard() {
    final scheme = Theme.of(context).colorScheme;
    return _serviceCard('Health & learning support (optional)', [
      if (_supportNotesAccessDenied)
        const _Notice(
          'You do not have permission to view or edit restricted support notes for this learner. Continue without changes, or ask an approved support/health staff member to complete this section.',
        )
      else ...[
        Text(
          'Support information',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _support,
          maxLines: 4,
          maxLength: 1000,
          decoration: const InputDecoration(
            hintText:
                'Share only information the school needs to support the learner.',
          ),
        ),
      ],
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restricted information',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Visible only to approved staff with support access.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _showSupportAccessSheet,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Review access'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  if (_supportNotesPolicyUrl != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () =>
                            launchUrlString(_supportNotesPolicyUrl!),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View school support & consent policy',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  void _showSupportAccessSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Who can see support notes',
                style: Theme.of(
                  c,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Restricted support and health information is visible only '
                'to staff with an approved support/health role at this '
                'school (e.g. School Nurse, designated support staff, '
                'School Admin). Every view and edit is recorded in the '
                'audit log.',
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(c).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _services() {
    final wide = MediaQuery.of(context).size.width >= AppBreakpoints.tablet;
    final schoolCard = _schoolServicesCard();
    final healthCard = _healthSupportCard();
    return _section(
      'Support & services',
      'Add the services this learner needs. Health and learning information is optional and restricted.',
      [
        _placementSummaryStrip(),
        const SizedBox(height: 20),
        wide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: schoolCard),
                    const SizedBox(width: 20),
                    Expanded(child: healthCard),
                  ],
                ),
              )
            : Column(
                children: [schoolCard, const SizedBox(height: 16), healthCard],
              ),
        const SizedBox(height: 20),
        const _Notice('You can update support plans later.'),
      ],
    );
  }

  /// Multiple published plans can never match the same selector - the
  /// backend (`publishFeePlan`) enforces one published plan per
  /// (year, term, class, category) at publish time - so ambiguity here can
  /// only mean the plan for a *different* selector than the one currently
  /// resolved is mid-republish. Treated as "needs finance review" rather
  /// than silently picking one.
  Future<List<FeePlan>> _checkForAmbiguousPlans() async {
    final year = _year, cls = _class;
    final termId = year == null ? null : _termIdFor(year);
    if (year == null || cls == null || termId == null) return const [];
    return sl<FeeBillingRepository>().findPublishedPlansForSelector(
      schoolId: widget.schoolId,
      academicYearId: year.id,
      termId: termId,
      classId: cls.id,
      studentCategory: _studentCategory,
    );
  }

  Widget _fees() {
    // Build-time trigger (not just on step transition) so a lookup that
    // couldn't resolve a termId yet (terms/years/classes still streaming
    // in) retries automatically on the next rebuild instead of being
    // permanently cached against a null result.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lookupFeePlan();
      _checkFinancePermission();
    });
    final isWide = MediaQuery.of(context).size.width >= 900;
    final feePlanCard = _feePlanCard();
    final billingSummaryCard = _billingSummaryCard();
    return _section(
      'Fees & billing',
      "Review the billing status for this learner's placement. "
          "Final fees are managed by your school's published plans.",
      [
        if (isWide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: feePlanCard),
                const SizedBox(width: 16),
                Expanded(child: billingSummaryCard),
              ],
            ),
          )
        else ...[
          feePlanCard,
          const SizedBox(height: 16),
          billingSummaryCard,
        ],
        const SizedBox(height: 16),
        _bursaryCard(),
      ],
    );
  }

  Widget _cardShell({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );

  Widget _cardTitle(String text) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );

  Widget _feePlanCard() {
    final match = _feePlanMatch;
    final required = (match?.lines ?? const []).where((l) => l.required);
    final optional = (match?.lines ?? const []).where((l) => !l.required);
    return _cardShell(
      child: FutureBuilder<List<FeePlan>>(
        future: match == null ? null : _checkForAmbiguousPlans(),
        builder: (context, snapshot) {
          final ambiguous = (snapshot.data?.length ?? 0) > 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle('Fee plan'),
              const SizedBox(height: 14),
              if (_feePlanLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (ambiguous)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Notice(
                      'More than one published fee plan matches this class, '
                      'term and day/boarding status. An authorised finance '
                      'user must review and assign the correct plan before '
                      'billing can proceed.',
                    ),
                    const SizedBox(height: 8),
                    _financeAccessAction(),
                  ],
                )
              else if (match == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'No matching published fee plan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "A fee plan has not yet been published for this "
                      "learner's class, term and day/boarding status.",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _Notice(
                      'You can continue enrolment. Billing will remain '
                      'pending until a Finance Manager publishes and '
                      'assigns a fee plan.',
                    ),
                    const SizedBox(height: 8),
                    _financeAccessAction(),
                  ],
                )
              else ...[
                Text(match.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
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
                if (optional.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Optional services',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  for (final line in optional)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      value: _selectedFeeAddOnIds.contains(line.chargeId),
                      title: Text(line.name),
                      subtitle: Text(
                        CurrencyFormatter.ugx(line.amountUgx.toDouble()),
                      ),
                      onChanged: (checked) => setState(() {
                        if (checked ?? false) {
                          _selectedFeeAddOnIds.add(line.chargeId);
                        } else {
                          _selectedFeeAddOnIds.remove(line.chargeId);
                        }
                      }),
                    ),
                ],
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      CurrencyFormatter.ugx(_feeBilledTotalUgx.toDouble()),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// "Open fee plans" only for users who can actually act on the fee
  /// module; everyone else gets a non-actionable pointer to Finance so
  /// nobody is shown a dead-end/permission-denied button.
  Widget _financeAccessAction() => FutureBuilder<bool>(
    future: _checkFinancePermission(),
    builder: (context, snapshot) {
      if (snapshot.data == true) {
        return Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => context.push(
                '/staff/admin/structure/academics/fee-structures',
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Open fee plans'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Only visible if you have the fee plan permission.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      }
      return Text(
        'Contact a Finance Manager to publish or assign a fee plan.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    },
  );

  /// Explicit statuses only - never an invented amount/placeholder.
  ({String label, Color color, IconData icon}) get _billingStatus {
    if (_feePlanLoading) {
      return (
        label: 'Checking…',
        color: Colors.grey,
        icon: Icons.hourglass_empty,
      );
    }
    if (_feePlanMatch != null) {
      return (
        label: 'Fee plan assigned',
        color: Colors.green,
        icon: Icons.check_circle_outline,
      );
    }
    return (
      label: 'Pending fee plan',
      color: Colors.orange,
      icon: Icons.schedule_outlined,
    );
  }

  Widget _billingSummaryCard() {
    final status = _billingStatus;
    return _cardShell(
      child: FutureBuilder<List<FeePlan>>(
        future: _feePlanMatch == null ? null : _checkForAmbiguousPlans(),
        builder: (context, snapshot) {
          final ambiguous = (snapshot.data?.length ?? 0) > 1;
          final resolvedStatus = ambiguous
              ? (
                  label: 'Needs finance review',
                  color: Colors.red,
                  icon: Icons.error_outline,
                )
              : status;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle('Billing summary'),
              const SizedBox(height: 14),
              _summaryRow('Academic year', _year?.name ?? 'Selected placement'),
              _summaryRow(
                'Term',
                _term.text.trim().isEmpty
                    ? 'Selected placement'
                    : _term.text.trim(),
              ),
              _summaryRow('Class', _class?.name ?? 'Selected placement'),
              _summaryRow('Day / boarding', _boarding),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status', style: Theme.of(context).textTheme.labelLarge),
                  _StatusChip(
                    label: resolvedStatus.label,
                    color: resolvedStatus.color,
                    icon: resolvedStatus.icon,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount due',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    ambiguous || _feePlanMatch == null
                        ? 'Not available yet'
                        : CurrencyFormatter.ugx(_feeBilledTotalUgx.toDouble()),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (ambiguous || _feePlanMatch == null) ...[
                const SizedBox(height: 6),
                Text(
                  'A fee plan must be published and assigned before fees '
                  'are available.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _bursaryCard() => _cardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle('Bursary or discount (optional)'),
        const SizedBox(height: 4),
        Text(
          'Only approved school bursaries and discounts may be assigned.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        if (_bursaryEnabled)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _bursaryType.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _bursaryIsPercentage
                            ? '${_bursaryAmount.text}% reduction'
                            : '${CurrencyFormatter.ugx(double.tryParse(_bursaryAmount.text) ?? 0)} reduction',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_bursaryReason.text.trim().isNotEmpty)
                        Text(_bursaryReason.text.trim()),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _bursaryEnabled = false),
                  child: const Text('Remove'),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _openAwardSelector,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Select approved award'),
              ),
              const SizedBox(width: 12),
              Text(
                'No award selected',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Awards are recorded and require the correct finance '
                'permission.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _openAwardSelector() async {
    final allowed = await _checkFinancePermission();
    if (!mounted) return;
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You do not have permission to assign a bursary or discount. '
            'Ask a Finance Manager.',
          ),
        ),
      );
      return;
    }
    final result = await showModalBottomSheet<_AwardSelection>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AwardSelectorSheet(),
    );
    if (result == null || !mounted) return;
    setState(() {
      _bursaryEnabled = true;
      _bursaryType = result.type;
      _bursaryIsPercentage = result.isPercentage;
      _bursaryAmount.text = result.amount.toString();
      _bursaryReason.text = result.reason;
    });
  }

  bool get _consentCaptured => _guardianConsent?['status'] == 'captured';
  bool get _consentPending => _guardianConsent?['status'] == 'pending';

  /// What's actually missing, surfaced verbatim under the disabled Continue
  /// button so staff never has to guess.
  String? get _documentsConsentBlockingReason {
    final missing = _documentRequirements
        .where(
          (r) =>
              r['required'] == true &&
              !_documents.any(
                (d) =>
                    d['requirementId'] == r['id'] && d['status'] == 'uploaded',
              ),
        )
        .map((r) => r['name'] as String? ?? 'A required document')
        .toList();
    final reasons = <String>[
      if (missing.isNotEmpty) '${missing.join(', ')} still required',
      if (!_consentCaptured && !_consentPending) 'Guardian consent not started',
      if (_consentPending) 'Waiting on guardian to complete the secure link',
    ];
    return reasons.isEmpty ? null : reasons.join(' · ');
  }

  Widget _documentsPage() {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final isWide = MediaQuery.of(context).size.width >= 900;
    final blockingReason = _documentsConsentBlockingReason;
    final documentsCard = _serviceCard('Supporting documents', [
      Text(
        'Upload any available documents. Items marked as optional can be completed later.',
        style: TextStyle(color: onSurfaceVariant, fontSize: 12.5),
      ),
      const SizedBox(height: 12),
      if (_documentRequirements.isEmpty)
        const _Notice(
          'No files uploaded yet. Missing-document status is checked at enrolment.',
        )
      else
        for (final requirement in _documentRequirements)
          _documentRequirementRow(requirement),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => _upload(),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload document'),
      ),
      const SizedBox(height: 6),
      Text(
        'Only upload files you are authorised to share. Accepted formats and limits are shown before upload.',
        style: TextStyle(color: onSurfaceVariant, fontSize: 11.5),
      ),
    ]);
    final consentCard = _guardianConsentCard();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents & consent',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Requirements are set by your school. You can complete permitted documents later.',
          style: TextStyle(color: onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (isWide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: documentsCard),
                const SizedBox(width: 16),
                Expanded(child: consentCard),
              ],
            ),
          )
        else ...[
          documentsCard,
          const SizedBox(height: 16),
          consentCard,
        ],
        const SizedBox(height: 16),
        const _Notice(
          'Consent records include method, guardian, timestamp, policy version and staff audit trail. '
          'We collect and use personal information in accordance with the Privacy Notice for Learner Enrolment.',
        ),
        if (blockingReason != null) ...[
          const SizedBox(height: 10),
          Text(
            'Complete required consent to continue: $blockingReason',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _guardianConsentCard() {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final scheme = Theme.of(context).colorScheme;
    final status = _guardianConsent?['status'] as String?;
    return _serviceCard('Guardian consent', [
      Row(
        children: [
          Expanded(
            child: Text(
              'Consent must be captured from the linked guardian or using an approved school process.',
              style: TextStyle(color: onSurfaceVariant, fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 8),
          _ConsentStatusChip(status: status),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        'Policy $_consentPolicyVersion',
        style: TextStyle(color: onSurfaceVariant, fontSize: 11),
      ),
      const SizedBox(height: 10),
      if (_consentMethods.contains('guardian_signs_now'))
        _consentMethodTile(
          method: 'guardian_signs_now',
          icon: Icons.draw_outlined,
          title: 'Guardian signs now',
          subtitle:
              'Capture consent with guardian present (digital signature).',
        ),
      if (_consentMethods.contains('secure_link'))
        _consentMethodTile(
          method: 'secure_link',
          icon: Icons.link,
          title: 'Send secure consent link',
          subtitle:
              'Send a secure link to the guardian to complete consent online.',
        ),
      if (_consentMethods.contains('verbal'))
        _consentMethodTile(
          method: 'verbal',
          icon: Icons.record_voice_over_outlined,
          title: 'Record approved in-person/verbal consent',
          subtitle:
              'Use when consent is obtained in person or via a phone call, in line with school policy.',
        ),
      if (_selectedConsentMethod == 'verbal') ...[
        const SizedBox(height: 8),
        TextField(
          controller: _witnessName,
          decoration: const InputDecoration(labelText: 'Witness name *'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _witnessRelationship,
          decoration: const InputDecoration(
            labelText: 'Witness relationship *',
          ),
        ),
      ],
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed:
              _consentActionInFlight ||
                  _selectedConsentMethod == null ||
                  _consentCaptured
              ? null
              : () async {
                  if (_selectedConsentMethod == 'verbal') {
                    if (_witnessName.text.trim().isEmpty ||
                        _witnessRelationship.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Witness name and relationship are required for verbal consent.',
                          ),
                        ),
                      );
                      return;
                    }
                    await _recordGuardianConsent(
                      method: 'verbal',
                      witnessName: _witnessName.text.trim(),
                      witnessRelationship: _witnessRelationship.text.trim(),
                    );
                  } else if (_selectedConsentMethod == 'guardian_signs_now') {
                    await _recordGuardianConsent(
                      method: 'guardian_signs_now',
                      signatureDataUrl:
                          'staff-confirmed:${DateTime.now().toIso8601String()}',
                    );
                  } else {
                    await _recordGuardianConsent(method: 'secure_link');
                  }
                },
          icon: _consentActionInFlight
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.shield_outlined),
          label: Text(
            _consentCaptured ? 'Consent captured' : 'Capture guardian consent',
          ),
        ),
      ),
      const SizedBox(height: 6),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _viewPrivacyNotice,
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('View privacy notice'),
        ),
      ),
      if (status == 'withdrawn') ...[
        const SizedBox(height: 6),
        Text(
          'Consent was withdrawn. Capture it again before enrolling.',
          style: TextStyle(color: scheme.error, fontSize: 12),
        ),
      ],
    ]);
  }

  Widget _consentMethodTile({
    required String method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selectedConsentMethod == method;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _consentCaptured
            ? null
            : () => setState(() => _selectedConsentMethod = method),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _documentRequirementRow(Map<String, dynamic> requirement) {
    final uploaded = _documents
        .where((d) => d['requirementId'] == requirement['id'])
        .firstOrNull;
    final required = requirement['required'] == true;
    final types =
        (requirement['allowedTypes'] as List?)?.join(', ').toUpperCase() ??
        'PDF, JPG OR PNG';
    final limit =
        requirement['maxSizeMb'] ?? StudentDocumentUploader.defaultMaxSizeMb;
    final status = uploaded?['status'] as String?;
    final scheme = Theme.of(context).colorScheme;

    IconData leadingIcon;
    Color? leadingColor;
    String statusLabel;
    if (uploaded == null) {
      leadingIcon = Icons.description_outlined;
      statusLabel = required ? 'Not uploaded' : 'Optional';
    } else if (status == 'uploading') {
      leadingIcon = Icons.cloud_upload_outlined;
      statusLabel = 'Uploading…';
    } else if (status == 'failed') {
      leadingIcon = Icons.error_outline;
      leadingColor = scheme.error;
      statusLabel = 'Upload failed';
    } else if (status == 'rejected') {
      leadingIcon = Icons.cancel_outlined;
      leadingColor = scheme.error;
      statusLabel = 'Rejected — re-upload required';
    } else {
      leadingIcon = Icons.check_circle_outline;
      leadingColor = Colors.green;
      statusLabel = 'Uploaded';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(leadingIcon, color: leadingColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          requirement['name'] as String? ?? 'Document',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          required ? 'Required' : 'Optional',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    uploaded == null
                        ? '$statusLabel · $types up to $limit MB'
                        : '${uploaded['name']} · $statusLabel',
                    style: TextStyle(
                      color: leadingColor ?? scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _upload(requirement: requirement),
              child: Text(
                uploaded == null
                    ? 'Upload'
                    : (status == 'failed' || status == 'rejected')
                    ? 'Retry'
                    : 'Replace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _review() {
    final learnerComplete =
        _first.text.trim().isNotEmpty &&
        _last.text.trim().isNotEmpty &&
        _dateOfBirthError(_dob.text) == null;
    final placementComplete =
        _year != null && _class != null && _term.text.trim().isNotEmpty;
    final documentsComplete = _consentSatisfied && _requiredDocumentsComplete;
    final billingPending = _feePlanMatch == null;
    final blocking = <_ChecklistItem>[
      if (!learnerComplete)
        const _ChecklistItem(step: 0, text: 'Learner details are incomplete'),
      if (!_guardianOk)
        const _ChecklistItem(step: 1, text: 'Parent or guardian is incomplete'),
      if (!placementComplete)
        const _ChecklistItem(step: 2, text: 'Academic placement is incomplete'),
      if (!_consentSatisfied)
        const _ChecklistItem(step: 5, text: 'Guardian consent is required'),
      if (!_requiredDocumentsComplete)
        const _ChecklistItem(step: 5, text: 'A required document is missing'),
    ];
    final allRequiredComplete = blocking.isEmpty;
    final canEnrol = allRequiredComplete && _reviewed;

    final rows = [
      _ReviewRow(
        icon: Icons.person_outline,
        title: 'Learner details',
        summary: 'Basic details, enrolment type and start date.',
        status: learnerComplete
            ? _ReviewStatus.complete
            : _ReviewStatus.blocked,
        onEdit: () => _goToStep(0),
      ),
      _ReviewRow(
        icon: Icons.people_outline,
        title: 'Parent or guardian',
        summary: 'Primary contact and consent recorded.',
        status: _guardianOk ? _ReviewStatus.complete : _ReviewStatus.blocked,
        onEdit: () => _goToStep(1),
      ),
      _ReviewRow(
        icon: Icons.school_outlined,
        title: 'Academic placement',
        summary: 'Year level, campus and class placement.',
        status: placementComplete
            ? _ReviewStatus.complete
            : _ReviewStatus.blocked,
        onEdit: () => _goToStep(2),
      ),
      _ReviewRow(
        icon: Icons.favorite_border,
        title: 'Support & services',
        summary: 'Learning needs and supports.',
        status: _ReviewStatus.complete,
        onEdit: () => _goToStep(3),
      ),
      _ReviewRow(
        icon: Icons.credit_card_outlined,
        title: 'Fees & billing',
        summary: 'Fee plan setup and billing status.',
        status: billingPending ? _ReviewStatus.pending : _ReviewStatus.complete,
        statusLabel: billingPending ? 'Billing pending' : null,
        onEdit: () => _goToStep(4),
      ),
      _ReviewRow(
        icon: Icons.description_outlined,
        title: 'Documents & consent',
        summary: 'Consent confirmed and documents uploaded.',
        status: documentsComplete
            ? _ReviewStatus.complete
            : _ReviewStatus.blocked,
        onEdit: () => _goToStep(5),
      ),
    ];

    final checklist = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Enrolment checklist',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          for (final row in rows) row,
        ],
      ),
    );

    final readyCard = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to enrol',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _ReadinessLine(
            ok: allRequiredComplete,
            title: 'Required details complete',
            detail:
                'Learner details, academic placement and other required information have been provided.',
          ),
          const SizedBox(height: 10),
          _ReadinessLine(
            ok: _guardianOk,
            title: 'Guardian consent captured',
            detail: 'Primary contact consent has been recorded.',
          ),
          const SizedBox(height: 10),
          _ReadinessLine(
            ok: !billingPending,
            pending: billingPending,
            title: billingPending ? 'Billing pending' : 'Fee plan matched',
            detail: billingPending
                ? 'A fee plan has not been set up yet. This does not block enrolment.'
                : 'A fee plan has been matched for this learner.',
          ),
          const SizedBox(height: 10),
          _ReadinessLine(
            ok: documentsComplete,
            title: 'Supporting documents',
            detail: documentsComplete
                ? 'Required documents are complete.'
                : 'Can be completed later where policy permits.',
          ),
          const SizedBox(height: 16),
          const _Notice(
            'When you enrol, School Pulse creates a duplicate-safe learner record and records this action in the audit log.',
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: !allRequiredComplete,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _reviewed,
              onChanged: allRequiredComplete
                  ? (v) => setState(() => _reviewed = v ?? false)
                  : null,
              title: const Text('I have reviewed the information above *'),
              subtitle: Text(
                allRequiredComplete
                    ? 'You must confirm to enable enrolment.'
                    : blocking.first.text,
                style: TextStyle(
                  color: allRequiredComplete
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );

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
          'Check the enrolment before creating the learner record.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (blocking.isNotEmpty)
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
                  for (final item in blocking)
                    Padding(
                      padding: const EdgeInsets.only(left: 32, top: 2),
                      child: InkWell(
                        onTap: () => _goToStep(item.step),
                        child: Text(
                          '• ${item.text} — Edit',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [checklist, const SizedBox(height: 16), readyCard],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: checklist),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: readyCard),
              ],
            );
          },
        ),
        if (!canEnrol) ...[
          const SizedBox(height: 8),
          Text(
            'You can edit any section before enrolling.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  void _goToStep(int step) => setState(() {
    _submittedCurrentStep = false;
    _step = step;
  });

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
    bool personName = false,
  }) => Container(
    key: identical(c, _first) ? _firstInvalidKey : null,
    child: TextFormField(
      controller: c,
      keyboardType: type,
      maxLines: lines,
      textCapitalization: caps,
      inputFormatters: personName
          ? [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-']"))]
          : null,
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
          : personName
          ? (v) {
              final value = v?.trim() ?? '';
              if (required && value.isEmpty) return '$label is required';
              if (value.isNotEmpty &&
                  !RegExp(r"^[a-zA-Z][a-zA-Z\s\-']*$").hasMatch(value)) {
                return 'Use letters, spaces, hyphens, or apostrophes only';
              }
              return null;
            }
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
    if (old == null && _guardians.length >= 2) return;
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
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
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
    if (_guardians.length >= 2) return;
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

  final _documentUploader = StudentDocumentUploader();

  Future<void> _upload({Map<String, dynamic>? requirement}) async {
    final picked = await FilePicker.pickFiles(withData: true);
    final f = picked?.files.single;
    if (f?.bytes == null) return;
    final allowedTypes = (requirement?['allowedTypes'] as List?)
        ?.map((e) => e.toString())
        .toList();
    final maxSizeMb = requirement?['maxSizeMb'] as int?;
    final validation = _documentUploader.validate(
      fileName: f!.name,
      sizeBytes: f.size,
      allowedTypes: allowedTypes,
      maxSizeMb: maxSizeMb,
    );
    if (!validation.allowed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validation.reason ?? 'File not accepted.')),
        );
      }
      return;
    }
    final existing = requirement == null
        ? null
        : _documents
              .where((d) => d['requirementId'] == requirement['id'])
              .firstOrNull;
    final doc = <String, dynamic>{
      'id': existing?['id'] ?? _uuid.v4(),
      'name': f.name,
      'status': 'uploading',
      'size': f.size,
      if (requirement != null) 'requirementId': requirement['id'],
    };
    setState(() {
      if (existing != null) _documents.remove(existing);
      _documents.add(doc);
    });
    try {
      final path = await _documentUploader.upload(
        schoolId: widget.schoolId,
        studentId: _studentId,
        docId: doc['id'] as String,
        fileName: f.name,
        bytes: f.bytes!,
      );
      final url = await FirebaseStorage.instance.ref(path).getDownloadURL();
      if (mounted) {
        setState(
          () => doc
            ..['status'] = 'uploaded'
            ..['path'] = path
            ..['url'] = url,
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() => doc['status'] = 'failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.message ?? e.code}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _upload(requirement: requirement),
            ),
          ),
        );
      }
    }
  }

  Future<void> _recordGuardianConsent({
    required String method,
    String? signatureDataUrl,
    String? witnessName,
    String? witnessRelationship,
  }) async {
    final guardian = _guardians.firstOrNull;
    if (guardian == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link a guardian before capturing consent.'),
        ),
      );
      return;
    }
    setState(() => _consentActionInFlight = true);
    try {
      if (method == 'secure_link') {
        await FirebaseFunctions.instance
            .httpsCallable('requestGuardianConsentLink')
            .call({
              'draftId': _draftId,
              'guardianId': guardian['id'],
              'schoolId': widget.schoolId,
            });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Secure consent link sent to the guardian.'),
            ),
          );
        }
      } else {
        await FirebaseFunctions.instance
            .httpsCallable('recordGuardianConsentByStaff')
            .call({
              'draftId': _draftId,
              'guardianId': guardian['id'],
              'schoolId': widget.schoolId,
              'method': method,
              if (signatureDataUrl != null)
                'signatureDataUrl': signatureDataUrl,
              if (witnessName != null) 'witnessName': witnessName,
              if (witnessRelationship != null)
                'witnessRelationship': witnessRelationship,
            });
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not record consent — ${e.message ?? e.code}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not record consent — $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _consentActionInFlight = false);
    }
  }

  Future<void> _viewPrivacyNotice() async {
    if (_privacyNoticeUrl == null || _privacyNoticeUrl!.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Privacy notice'),
          content: SingleChildScrollView(child: Text(_consentText)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }
    await launchUrlString(_privacyNoticeUrl!);
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

class _DayBoardingSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _DayBoardingSelector({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Day / boarding *', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'Day learner',
              label: Text('Day learner'),
              icon: Icon(Icons.directions_walk_rounded),
            ),
            ButtonSegment(
              value: 'Boarding learner',
              label: Text('Boarding learner'),
              icon: Icon(Icons.hotel_rounded),
            ),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    ),
  );
}

/// Status pill for guardian consent: Required, Pending guardian action,
/// Captured, Expired, Withdrawn or Needs review.
class _ConsentStatusChip extends StatelessWidget {
  final String? status;
  const _ConsentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    late final Color color;
    late final String label;
    switch (status) {
      case 'captured':
        color = Colors.green;
        label = 'Captured';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending guardian action';
        break;
      case 'expired':
        color = scheme.error;
        label = 'Expired';
        break;
      case 'withdrawn':
        color = scheme.error;
        label = 'Withdrawn';
        break;
      case 'needs_review':
        color = Colors.orange;
        label = 'Needs review';
        break;
      default:
        color = scheme.primary;
        label = 'Consent required';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'captured' ? Icons.check_circle : Icons.info_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _AwardSelection {
  final ScholarshipAwardType type;
  final bool isPercentage;
  final double amount;
  final String reason;
  const _AwardSelection({
    required this.type,
    required this.isPercentage,
    required this.amount,
    required this.reason,
  });
}

/// Approved award programmes a school can offer. Values/eligibility here
/// mirror the [ScholarshipAwardType] categories the backend already
/// recognizes (`scholarship_award.dart`) - staff pick from this fixed,
/// tenant-approved set rather than typing an arbitrary reduction.
class _AwardSelectorSheet extends StatefulWidget {
  const _AwardSelectorSheet();
  @override
  State<_AwardSelectorSheet> createState() => _AwardSelectorSheetState();
}

class _AwardSelectorSheetState extends State<_AwardSelectorSheet> {
  ScholarshipAwardType? _selected;
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  static const _programmes =
      <
        ScholarshipAwardType,
        ({
          String title,
          String eligibility,
          bool isPercentage,
          bool requiresApproval,
        })
      >{
        ScholarshipAwardType.full: (
          title: 'Full scholarship',
          eligibility: 'Covers 100% of billed fees for approved cases.',
          isPercentage: true,
          requiresApproval: true,
        ),
        ScholarshipAwardType.partial: (
          title: 'Partial scholarship',
          eligibility: 'Approved partial fee reduction.',
          isPercentage: true,
          requiresApproval: true,
        ),
        ScholarshipAwardType.scholarship: (
          title: 'Scholarship award',
          eligibility: 'Merit or need-based award approved by the school.',
          isPercentage: true,
          requiresApproval: true,
        ),
        ScholarshipAwardType.staffChildDiscount: (
          title: 'Staff child discount',
          eligibility: 'Children of employed school staff.',
          isPercentage: true,
          requiresApproval: false,
        ),
        ScholarshipAwardType.siblingDiscount: (
          title: 'Sibling discount',
          eligibility: 'Households with multiple enrolled siblings.',
          isPercentage: true,
          requiresApproval: false,
        ),
        ScholarshipAwardType.custom: (
          title: 'Other approved discount',
          eligibility:
              'Any other school-approved reduction. Requires a reason.',
          isPercentage: false,
          requiresApproval: true,
        ),
      };

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final programme = selected == null ? null : _programmes[selected];
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select approved award',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Only tenant-approved award programmes are available here.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (final entry in _programmes.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _selected == entry.key
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _selected == entry.key
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onTap: () => setState(() => _selected = entry.key),
                title: Text(entry.value.title),
                subtitle: Text(entry.value.eligibility),
              ),
            if (programme != null) ...[
              const Divider(height: 24),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: programme.isPercentage
                      ? 'Discount (%)'
                      : 'Discount (UGX)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
              const SizedBox(height: 10),
              if (programme.requiresApproval)
                const _Notice(
                  'This award type requires finance approval. It will show '
                  'as "Pending approval" until approved.',
                ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: selected == null
                        ? null
                        : () {
                            final amount = double.tryParse(
                              _amountController.text.trim(),
                            );
                            if (amount == null) return;
                            Navigator.pop(
                              context,
                              _AwardSelection(
                                type: selected,
                                isPercentage: programme!.isPercentage,
                                amount: amount,
                                reason: _reasonController.text.trim(),
                              ),
                            );
                          },
                    child: const Text('Assign award'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice(this.text);
  @override
  Widget build(BuildContext c) {
    final blue = Colors.lightBlue.shade200;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withValues(alpha: 0.08),
        border: Border.all(color: blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 22, color: blue),
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
}

/// Shown while a dropdown's backing list is still streaming in, so the
/// step doesn't render an empty/misleading dropdown momentarily.
class _FieldLoadingPlaceholder extends StatelessWidget {
  final String label;
  const _FieldLoadingPlaceholder({required this.label});
  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(labelText: label),
    child: Row(
      children: const [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Loading…'),
      ],
    ),
  );
}

/// Empty-state notice for a loaded-but-empty structure list (e.g. no
/// education levels/classes configured), with an optional deep link into
/// Structure setup when the current user has permission to act on it.
class _EmptyConfigNotice extends StatelessWidget {
  final String message;
  final bool canOpenSetup;
  final VoidCallback onOpenSetup;
  const _EmptyConfigNotice({
    required this.message,
    required this.canOpenSetup,
    required this.onOpenSetup,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Notice(message),
      if (canOpenSetup) ...[
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onOpenSetup,
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Open school structure setup'),
        ),
      ],
    ],
  );
}

enum _ReviewStatus { complete, pending, blocked }

class _ChecklistItem {
  final int step;
  final String text;
  const _ChecklistItem({required this.step, required this.text});
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String summary;
  final _ReviewStatus status;
  final String? statusLabel;
  final VoidCallback onEdit;
  const _ReviewRow({
    required this.icon,
    required this.title,
    required this.summary,
    required this.status,
    required this.onEdit,
    this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (color, label, chipIcon) = switch (status) {
      _ReviewStatus.complete => (
        Colors.green.shade600,
        statusLabel ?? 'Complete',
        Icons.check_circle,
      ),
      _ReviewStatus.pending => (
        Colors.amber.shade700,
        statusLabel ?? 'Pending',
        Icons.schedule,
      ),
      _ReviewStatus.blocked => (
        scheme.error,
        statusLabel ?? 'Incomplete',
        Icons.error_outline,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                label: '$title status: $label',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chipIcon, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.chevron_right, size: 16),
                iconAlignment: IconAlignment.end,
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadinessLine extends StatelessWidget {
  final bool ok;
  final bool pending;
  final String title;
  final String detail;
  const _ReadinessLine({
    required this.ok,
    required this.title,
    required this.detail,
    this.pending = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = ok
        ? Colors.green.shade600
        : pending
        ? Colors.amber.shade700
        : scheme.error;
    final icon = ok
        ? Icons.check_circle
        : pending
        ? Icons.schedule
        : Icons.error_outline;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                detail,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
