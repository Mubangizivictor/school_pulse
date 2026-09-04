import 'package:flutter/material.dart';

import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';

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

class SelectedLearner {
  final Student student;
  String relationship;

  SelectedLearner({required this.student, this.relationship = 'Mother'});
}

class LinkParentWizardController extends ChangeNotifier {
  final String schoolId;
  final ParentAccessRepository repository;

  LinkParentWizardController({
    required this.schoolId,
    required this.repository,
  }) {
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

    final result = await repository.issueParentAccessCode(
      parentName: parentName,
      phoneNumber: e164Phone,
      learners: selectedLearners
          .map(
            (l) => LearnerLinkRequest(
              studentId: l.student.id,
              relationship: l.relationship,
            ),
          )
          .toList(),
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
        submitting = false;
        _stage = LinkParentStage.code;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> revoke() async {
    if (resultInviteId == null) return false;
    final result = await repository.revokeParentAccessCode(
      inviteId: resultInviteId!,
    );
    return result.isRight();
  }

  @override
  void dispose() {
    parentNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
