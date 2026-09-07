/// Serialisable snapshot of the Link Parent flow, persisted to
/// SharedPreferences so an interrupted admin can resume. Mirrors
/// AddStaffDraft's shape (a plain JSON map, dropped after 24h or on a
/// successful submit).
class LinkParentDraftLearner {
  final String studentId;
  final String studentName;
  final String studentCode;
  final String relationship;
  final bool isPrimaryContact;

  const LinkParentDraftLearner({
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.relationship,
    required this.isPrimaryContact,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentName': studentName,
    'studentCode': studentCode,
    'relationship': relationship,
    'isPrimaryContact': isPrimaryContact,
  };

  factory LinkParentDraftLearner.fromJson(Map<String, dynamic> json) =>
      LinkParentDraftLearner(
        studentId: json['studentId'] as String? ?? '',
        studentName: json['studentName'] as String? ?? '',
        studentCode: json['studentCode'] as String? ?? '',
        relationship: json['relationship'] as String? ?? 'Mother',
        isPrimaryContact: json['isPrimaryContact'] as bool? ?? false,
      );
}

class LinkParentDraft {
  final String parentName;
  final String relationship;
  final String dialCode;
  final String nationalNumber;
  final String email;
  final List<LinkParentDraftLearner> learners;
  final bool sendInvitation;

  const LinkParentDraft({
    this.parentName = '',
    this.relationship = 'Mother',
    this.dialCode = '+256',
    this.nationalNumber = '',
    this.email = '',
    this.learners = const [],
    this.sendInvitation = true,
  });

  bool get isEmpty =>
      parentName.isEmpty &&
      nationalNumber.isEmpty &&
      email.isEmpty &&
      learners.isEmpty;

  Map<String, dynamic> toJson() => {
    'parentName': parentName,
    'relationship': relationship,
    'dialCode': dialCode,
    'nationalNumber': nationalNumber,
    'email': email,
    'learners': learners.map((l) => l.toJson()).toList(),
    'sendInvitation': sendInvitation,
  };

  factory LinkParentDraft.fromJson(Map<String, dynamic> json) => LinkParentDraft(
    parentName: json['parentName'] as String? ?? '',
    relationship: json['relationship'] as String? ?? 'Mother',
    dialCode: json['dialCode'] as String? ?? '+256',
    nationalNumber: json['nationalNumber'] as String? ?? '',
    email: json['email'] as String? ?? '',
    learners: ((json['learners'] as List?) ?? const [])
        .map((e) =>
            LinkParentDraftLearner.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    sendInvitation: json['sendInvitation'] as bool? ?? true,
  );
}
