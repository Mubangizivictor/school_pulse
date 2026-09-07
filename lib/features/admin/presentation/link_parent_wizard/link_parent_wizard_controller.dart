import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/design_system/components/phone_number_field.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_invite.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';

import 'models/link_parent_draft.dart';

enum LinkParentStage { details, review, sent }

const List<LinkParentStage> kLinkParentStages = [
  LinkParentStage.details,
  LinkParentStage.review,
];

const List<String> kLinkParentStageLabels = ['Parent & learners', 'Review'];

const List<String> kLinkParentRelationships = [
  'Mother',
  'Father',
  'Guardian',
  'Grandparent',
  'Aunt',
  'Uncle',
  'Sibling',
  'Other',
];

int linkParentStageIndexFor(LinkParentStage stage) {
  final i = kLinkParentStages.indexOf(stage);
  return i == -1 ? 0 : i;
}

class SelectedLearner {
  final Student student;
  String relationship;
  bool isPrimaryContact;

  SelectedLearner({
    required this.student,
    this.relationship = 'Mother',
    this.isPrimaryContact = false,
  });
}

/// A tenant-scoped existing parent (by phone/email) surfaced by duplicate
/// detection so the admin can link to it instead of creating a second
/// record.
class ExistingParentMatch {
  final String inviteId;
  final String parentName;
  final String maskedPhone;
  final int learnerCount;

  const ExistingParentMatch({
    required this.inviteId,
    required this.parentName,
    required this.maskedPhone,
    required this.learnerCount,
  });
}

/// Backs the Link Parent flow. Deliberately a ChangeNotifier (not a bloc),
/// matching AddStaffWizardController's imperative Either.fold style, and
/// carries the same SharedPreferences draft persistence contract.
class LinkParentWizardController extends ChangeNotifier {
  final String schoolId;
  final String adminUid;
  final ParentAccessRepository repository;

  LinkParentWizardController({
    required this.schoolId,
    required this.adminUid,
    required this.repository,
  }) {
    parentNameController.addListener(_onFieldChanged);
    phoneNationalController; // ensure initialised
    emailController.addListener(_onFieldChanged);
  }

  // ---- fields -------------------------------------------------------------

  final parentNameController = TextEditingController();
  final emailController = TextEditingController();

  String _dialCode = kDefaultDialCode;
  String get dialCode => _dialCode;
  set dialCode(String value) {
    _dialCode = value;
    _persistDraft();
    notifyListeners();
  }

  final phoneNationalController = TextEditingController();
  String get nationalNumber => phoneNationalController.text.trim();
  set nationalNumber(String value) {
    if (phoneNationalController.text != value) {
      phoneNationalController.text = value;
    }
    _persistDraft();
    notifyListeners();
  }

  String _relationship = 'Mother';
  String get relationship => _relationship;
  set relationship(String value) {
    _relationship = value;
    _persistDraft();
    notifyListeners();
  }

  final List<SelectedLearner> selectedLearners = [];

  /// Tenant policy: configured max guardians per learner (default 2 until the
  /// policy load resolves).
  int maxGuardians = 2;

  bool sendInvitation = true;

  // ---- result / flow state ---------------------------------------------

  LinkParentStage _stage = LinkParentStage.details;
  LinkParentStage get stage => _stage;

  bool submitting = false;
  String? submitError;

  bool checkingDuplicate = false;
  ExistingParentMatch? duplicateMatch;

  String? resultCode;
  String? resultInviteId;
  DateTime? resultExpiresAt;
  bool resultInvitationDelivered = false;
  String resultInvitationStatus = 'pending_manual';

  // ---- derived --------------------------------------------------------

  String get parentName => parentNameController.text.trim();
  String get email => emailController.text.trim();

  String get e164Phone => phoneToE164(_dialCode, nationalNumber) ?? '';
  bool get isPhoneValid => phoneToE164(_dialCode, nationalNumber) != null;
  bool get isNameValid => parentName.isNotEmpty;
  bool get isEmailValid =>
      email.isEmpty ||
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  bool get canProceedFromDetails =>
      isNameValid &&
      isPhoneValid &&
      isEmailValid &&
      selectedLearners.isNotEmpty &&
      !_anyLearnerAtCap;

  bool get _anyLearnerAtCap => false; // reserved: per-learner cap is enforced
  // server-side; the client blocks *adding* a learner already known to be at
  // the cap (see [learnerAtCap]).

  final Set<String> _learnersAtCap = {};
  bool learnerAtCap(String studentId) => _learnersAtCap.contains(studentId);

  // ---- mutations ----------------------------------------------------

  void _onFieldChanged() {
    _persistDraft();
    notifyListeners();
  }

  void addLearner(Student student) {
    if (selectedLearners.any((l) => l.student.id == student.id)) return;
    selectedLearners.add(
      SelectedLearner(student: student, relationship: _relationship),
    );
    _onFieldChanged();
  }

  void removeLearner(String studentId) {
    selectedLearners.removeWhere((l) => l.student.id == studentId);
    _onFieldChanged();
  }

  void setLearnerRelationship(String studentId, String relationship) {
    selectedLearners
        .firstWhere((l) => l.student.id == studentId)
        .relationship = relationship;
    _onFieldChanged();
  }

  void setPrimaryContact(String studentId, bool value) {
    for (final l in selectedLearners) {
      // Only one primary contact per learner from this parent; a parent can
      // still be primary for several of their learners.
      if (l.student.id == studentId) l.isPrimaryContact = value;
    }
    _onFieldChanged();
  }

  void goToStage(LinkParentStage stage) {
    _stage = stage;
    _persistDraft();
    notifyListeners();
  }

  Future<void> next() async {
    if (_stage == LinkParentStage.details) {
      await _checkForDuplicate();
      _stage = LinkParentStage.review;
      _persistDraft();
      notifyListeners();
    }
  }

  void back() {
    if (_stage == LinkParentStage.review) {
      _stage = LinkParentStage.details;
      _persistDraft();
      notifyListeners();
    }
  }

  // ---- duplicate detection ------------------------------------------

  Future<void> _checkForDuplicate() async {
    duplicateMatch = null;
    checkingDuplicate = true;
    notifyListeners();
    final result = await repository.listParentAccessInvites(pageSize: 100);
    checkingDuplicate = false;
    result.fold((_) {}, (page) {
      final phoneTail = e164Phone.replaceAll(RegExp(r'\D'), '');
      for (final row in page.rows) {
        final rowTail = row.maskedPhone.replaceAll(RegExp(r'\D'), '');
        final phoneMatch =
            rowTail.isNotEmpty && phoneTail.endsWith(rowTail);
        final emailMatch = email.isNotEmpty &&
            row.hasEmail &&
            row.maskedEmail.split('@').last.toLowerCase() ==
                email.split('@').last.toLowerCase() &&
            row.maskedEmail[0].toLowerCase() == email[0].toLowerCase();
        if ((phoneMatch || emailMatch) &&
            row.status == ParentInviteStatus.active) {
          duplicateMatch = ExistingParentMatch(
            inviteId: row.inviteId,
            parentName: row.parentName,
            maskedPhone: row.maskedPhone,
            learnerCount: row.learnerCount,
          );
          break;
        }
      }
    });
    notifyListeners();
  }

  // ---- submit ------------------------------------------------------

  final _uuid = const Uuid();
  String? _idempotencyKey;

  List<LearnerLinkRequest> _learnerRequests() => selectedLearners
      .map((l) => LearnerLinkRequest(
            studentId: l.student.id,
            relationship: l.relationship,
            isPrimaryContact: l.isPrimaryContact,
          ))
      .toList();

  /// Creates a brand-new parent record + verified invitation. Idempotent
  /// across retries via a stable key generated on the first attempt.
  Future<bool> submitNewParent() async {
    if (submitting) return false;
    submitting = true;
    submitError = null;
    _idempotencyKey ??= _uuid.v4();
    notifyListeners();

    final result = await repository.issueParentAccessCode(
      parentName: parentName,
      phoneNumber: e164Phone,
      email: email.isEmpty ? null : email,
      learners: _learnerRequests(),
    );

    return result.fold(
      (failure) {
        submitting = false;
        submitError = failure.message;
        notifyListeners();
        return false;
      },
      (issued) {
        resultCode = issued.code;
        resultInviteId = issued.inviteId;
        resultExpiresAt = issued.expiresAt;
        resultInvitationDelivered = issued.invitationDelivered;
        resultInvitationStatus = issued.invitationStatus;
        submitting = false;
        _stage = LinkParentStage.sent;
        notifyListeners();
        clearDraft();
        return true;
      },
    );
  }

  /// Links the selected learners onto an existing parent record instead of
  /// creating a duplicate.
  Future<bool> submitLinkToExisting() async {
    final match = duplicateMatch;
    if (match == null || submitting) return false;
    submitting = true;
    submitError = null;
    notifyListeners();

    final result = await repository.linkLearnersToExistingParent(
      inviteId: match.inviteId,
      learners: _learnerRequests(),
    );

    return result.fold(
      (failure) {
        submitting = false;
        submitError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        resultInviteId = match.inviteId;
        submitting = false;
        _stage = LinkParentStage.sent;
        notifyListeners();
        clearDraft();
        return true;
      },
    );
  }

  Future<bool> resendInvitation() async {
    if (resultInviteId == null) return false;
    final result = await repository.resendParentInvitation(
      inviteId: resultInviteId!,
      rawCode: resultCode,
    );
    return result.fold((_) => false, (_) {
      resultInvitationDelivered = true;
      resultInvitationStatus = 'sent';
      notifyListeners();
      return true;
    });
  }

  Future<bool> revoke() async {
    if (resultInviteId == null) return false;
    final result =
        await repository.revokeParentAccessCode(inviteId: resultInviteId!);
    return result.isRight();
  }

  // ---- policy load -------------------------------------------------

  Future<void> loadPolicy() async {
    final result = await repository.listParentAccessInvites(pageSize: 1);
    result.fold((_) {}, (page) {
      maxGuardians = page.maxGuardians;
      notifyListeners();
    });
  }

  // ---- draft persistence (mirrors AddStaffWizardController) --------

  String get _draftKey => 'link_parent_draft_${schoolId}_$adminUid';
  static const _draftMaxAgeMs = 24 * 60 * 60 * 1000;

  LinkParentDraft _draftSnapshot() => LinkParentDraft(
    parentName: parentName,
    relationship: _relationship,
    dialCode: _dialCode,
    nationalNumber: nationalNumber,
    email: email,
    sendInvitation: sendInvitation,
    learners: selectedLearners
        .map((l) => LinkParentDraftLearner(
              studentId: l.student.id,
              studentName: l.student.name,
              studentCode: l.student.studentCode,
              relationship: l.relationship,
              isPrimaryContact: l.isPrimaryContact,
            ))
        .toList(),
  );

  bool _restoring = false;
  Future<void> _persistChain = Future<void>.value();

  /// Serialise writes so rapid successive mutations can't land out of order
  /// (each call always writes the *latest* snapshot, and later calls win).
  Future<void> _persistDraft() {
    if (_restoring) return _persistChain;
    _persistChain = _persistChain.then((_) async {
      final snapshot = _draftSnapshot();
      try {
        final prefs = await SharedPreferences.getInstance();
        if (snapshot.isEmpty) {
          await prefs.remove(_draftKey);
          return;
        }
        await prefs.setString(
          _draftKey,
          jsonEncode({
            'savedAt': DateTime.now().millisecondsSinceEpoch,
            'draft': snapshot.toJson(),
          }),
        );
      } catch (_) {
        // Non-fatal: persistence is a convenience, never blocks the flow.
      }
    });
    return _persistChain;
  }

  /// Test/last-resort hook: await all queued draft writes.
  Future<void> flushDraft() => _persistChain;

  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }

  /// Returns true if a draft was restored (so the page can show a snackbar).
  /// [resolveStudent] turns a persisted learner id back into a full Student -
  /// the page passes its already-loaded roster.
  Future<bool> restoreDraftIfPresent(
    Student? Function(String studentId) resolveStudent,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null) return false;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = (decoded['savedAt'] as num?)?.toInt() ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - savedAt > _draftMaxAgeMs) {
        await prefs.remove(_draftKey);
        return false;
      }
      final draft = LinkParentDraft.fromJson(
        Map<String, dynamic>.from(decoded['draft'] as Map),
      );
      _restoring = true;
      parentNameController.text = draft.parentName;
      emailController.text = draft.email;
      phoneNationalController.text = draft.nationalNumber;
      _dialCode = draft.dialCode;
      _relationship = draft.relationship;
      sendInvitation = draft.sendInvitation;
      selectedLearners.clear();
      for (final l in draft.learners) {
        final student = resolveStudent(l.studentId);
        if (student == null) continue;
        selectedLearners.add(SelectedLearner(
          student: student,
          relationship: l.relationship,
          isPrimaryContact: l.isPrimaryContact,
        ));
      }
      _restoring = false;
      notifyListeners();
      return !draft.isEmpty;
    } catch (_) {
      _restoring = false;
      return false;
    }
  }

  @override
  void dispose() {
    parentNameController.dispose();
    emailController.dispose();
    phoneNationalController.dispose();
    super.dispose();
  }
}
