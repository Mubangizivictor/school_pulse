import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'package:school_pulse/features/student/domain/entities/student.dart';

/// The three visible wizard stages: pick parent + learners, review, then the
/// generated-code reveal (a fourth, unlabeled state reached only on success).
enum LinkParentStage { details, review, code }

const List<LinkParentStage> kLinkParentStages = [
  LinkParentStage.details,
  LinkParentStage.review,
];

const List<String> kLinkParentStageLabels = ['Parent & learners', 'Review'];

int linkParentStageIndexFor(LinkParentStage stage) {
  final i = kLinkParentStages.indexOf(stage);
  return i == -1 ? 0 : i;
}

/// One learner selected in the wizard, with its own per-learner relationship
/// label (a mother may be "Mother" to one child and "Guardian" to another).
class SelectedLearner {
  final Student student;
  String relationship;

  SelectedLearner({required this.student, this.relationship = 'Mother'});
}

/// Holds the Link Parent to Learners wizard's accumulating draft, current
/// stage, and the submit() call that creates the parent access code invite
/// via the `createParentAccessCode` callable. A plain ChangeNotifier to match
/// the Add Staff wizard's controller convention.
class LinkParentWizardController extends ChangeNotifier {
  final String schoolId;

  LinkParentWizardController({required this.schoolId}) {
    parentNameController.addListener(notifyListeners);
    phoneController.addListener(notifyListeners);
  }

  LinkParentStage _stage = LinkParentStage.details;
  LinkParentStage get stage => _stage;

  final parentNameController = TextEditingController();
  final phoneController = TextEditingController();

  String _countryCode = '+256';
  String get countryCode => _countryCode;
  set countryCode(String value) {
    _countryCode = value;
    notifyListeners();
  }

  final List<SelectedLearner> selectedLearners = [];

  bool submitting = false;
  String? submitError;

  String? resultCode;
  String? resultInviteId;
  DateTime? resultExpiresAt;

  String get parentName => parentNameController.text.trim();
  String get rawPhone => phoneController.text.trim();

  /// E.164 phone built from the selected country code and the digits typed
  /// into the phone field (matches the createParentAccessCode contract,
  /// which requires `^\+\d{8,15}$` with no spaces).
  String get e164Phone {
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    return '$countryCode$digits';
  }

  bool get isPhoneValid => RegExp(r'^\+\d{8,15}$').hasMatch(e164Phone);
  bool get isNameValid => parentName.isNotEmpty;
  bool get canProceedFromDetails =>
      isNameValid && isPhoneValid && selectedLearners.isNotEmpty;

  void addLearner(Student student) {
    if (selectedLearners.any((l) => l.student.id == student.id)) return;
    selectedLearners.add(SelectedLearner(student: student));
    notifyListeners();
  }

  void removeLearner(String studentId) {
    selectedLearners.removeWhere((l) => l.student.id == studentId);
    notifyListeners();
  }

  void setRelationship(String studentId, String relationship) {
    final learner = selectedLearners.firstWhere(
      (l) => l.student.id == studentId,
    );
    learner.relationship = relationship;
    notifyListeners();
  }

  void goToStage(LinkParentStage stage) {
    _stage = stage;
    notifyListeners();
  }

  void next() {
    if (_stage == LinkParentStage.details) {
      _stage = LinkParentStage.review;
    } else if (_stage == LinkParentStage.review) {
      _stage = LinkParentStage.code;
    }
    notifyListeners();
  }

  void back() {
    if (_stage == LinkParentStage.review) {
      _stage = LinkParentStage.details;
      notifyListeners();
    }
  }

  Future<bool> submit() async {
    submitting = true;
    submitError = null;
    notifyListeners();
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('createParentAccessCode')
          .call({
            'parentName': parentName,
            'phoneNumber': e164Phone,
            'learners': selectedLearners
                .map(
                  (l) => {
                    'studentId': l.student.id,
                    'relationship': l.relationship,
                  },
                )
                .toList(),
          });
      final data = Map<String, dynamic>.from(result.data as Map);
      resultCode = data['code'] as String?;
      resultInviteId = data['inviteId'] as String?;
      final expiresAtMs = data['expiresAt'];
      resultExpiresAt = expiresAtMs is int
          ? DateTime.fromMillisecondsSinceEpoch(expiresAtMs)
          : null;
      submitting = false;
      _stage = LinkParentStage.code;
      notifyListeners();
      return true;
    } on FirebaseFunctionsException catch (error) {
      submitting = false;
      submitError = _friendlyError(error);
      notifyListeners();
      return false;
    } catch (_) {
      submitting = false;
      submitError = 'Could not create the parent access code. Try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> revoke() async {
    if (resultInviteId == null) return false;
    try {
      await FirebaseFunctions.instance
          .httpsCallable('revokeParentAccessCode')
          .call({'inviteId': resultInviteId});
      return true;
    } on FirebaseFunctionsException {
      return false;
    }
  }

  String _friendlyError(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'failed-precondition':
        return 'A learner can have a maximum of two parents.';
      case 'already-exists':
        return 'This parent is already linked to one of the selected learners.';
      case 'permission-denied':
        return 'One or more learners are unavailable, or you do not have permission to issue codes.';
      case 'invalid-argument':
        return error.message ??
            'Enter the parent details and select at least one learner.';
      default:
        return error.message ??
            'Could not create the parent access code. Try again.';
    }
  }

  @override
  void dispose() {
    parentNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
