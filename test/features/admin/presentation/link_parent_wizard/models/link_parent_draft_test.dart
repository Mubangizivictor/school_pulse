import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/presentation/link_parent_wizard/models/link_parent_draft.dart';

void main() {
  test('LinkParentDraft round-trips through JSON', () {
    const draft = LinkParentDraft(
      parentName: 'Naluwagga Sarah',
      relationship: 'Mother',
      dialCode: '+256',
      nationalNumber: '712345678',
      email: 'sarah@example.com',
      sendInvitation: false,
      learners: [
        LinkParentDraftLearner(
          studentId: 's1',
          studentName: 'Akol Kevin',
          studentCode: 'ADM0014',
          relationship: 'Son',
          isPrimaryContact: true,
        ),
        LinkParentDraftLearner(
          studentId: 's2',
          studentName: 'Akol Natalie',
          studentCode: 'ADM0032',
          relationship: 'Daughter',
          isPrimaryContact: false,
        ),
      ],
    );

    final restored = LinkParentDraft.fromJson(draft.toJson());
    expect(restored.parentName, 'Naluwagga Sarah');
    expect(restored.dialCode, '+256');
    expect(restored.nationalNumber, '712345678');
    expect(restored.email, 'sarah@example.com');
    expect(restored.sendInvitation, false);
    expect(restored.learners, hasLength(2));
    expect(restored.learners.first.isPrimaryContact, isTrue);
    expect(restored.learners.last.relationship, 'Daughter');
  });

  test('isEmpty is true only when nothing is filled', () {
    expect(const LinkParentDraft().isEmpty, isTrue);
    expect(const LinkParentDraft(parentName: 'X').isEmpty, isFalse);
    expect(
      const LinkParentDraft(learners: [
        LinkParentDraftLearner(
          studentId: 's1',
          studentName: 'n',
          studentCode: 'c',
          relationship: 'Son',
          isPrimaryContact: false,
        ),
      ]).isEmpty,
      isFalse,
    );
  });

  test('fromJson tolerates missing keys', () {
    final d = LinkParentDraft.fromJson(const {});
    expect(d.dialCode, '+256');
    expect(d.relationship, 'Mother');
    expect(d.learners, isEmpty);
  });
}
