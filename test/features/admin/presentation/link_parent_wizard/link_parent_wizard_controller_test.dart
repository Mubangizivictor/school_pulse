import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/data/models/parent_access_invite_model.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_invite.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/features/admin/presentation/link_parent_wizard/link_parent_wizard_controller.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';

class _MockRepo extends Mock implements ParentAccessRepository {}

Student _student(String id, {String name = 'Akol Kevin', String code = 'ADM0014'}) {
  return Student(
    id: id,
    schoolId: 'schoolA',
    name: name,
    studentCode: code,
    admissionNumber: code,
    dateOfBirth: DateTime(2010),
    gender: Gender.male,
    classId: 'c1',
    academicYearId: 'y1',
    status: StudentStatus.active,
    level: EducationLevel.primary,
  );
}

ParentAccessInvitesPage _page({List<ParentAccessInvite> rows = const [], int maxGuardians = 2}) {
  return ParentAccessInvitesPage(
    rows: rows,
    nextCursor: null,
    pendingCount: 0,
    expiringSoonCount: 0,
    maxGuardians: maxGuardians,
  );
}

void main() {
  late _MockRepo repo;

  setUpAll(() {
    registerFallbackValue(const <LearnerLinkRequest>[]);
  });

  setUp(() {
    repo = _MockRepo();
    SharedPreferences.setMockInitialValues({});
    when(() => repo.listParentAccessInvites(pageSize: any(named: 'pageSize')))
        .thenAnswer((_) async => Right(_page()));
  });

  LinkParentWizardController build() => LinkParentWizardController(
        schoolId: 'schoolA',
        adminUid: 'admin1',
        repository: repo,
      );

  group('validation', () {
    test('canProceedFromDetails needs name, valid phone, >=1 learner', () {
      final c = build();
      expect(c.canProceedFromDetails, isFalse);

      c.parentNameController.text = 'Naluwagga Sarah';
      c.nationalNumber = '712345678';
      expect(c.canProceedFromDetails, isFalse, reason: 'no learner yet');

      c.addLearner(_student('s1'));
      expect(c.canProceedFromDetails, isTrue);
    });

    test('an invalid email blocks proceeding', () {
      final c = build()
        ..parentNameController.text = 'X'
        ..nationalNumber = '712345678'
        ..addLearner(_student('s1'));
      c.emailController.text = 'not-an-email';
      expect(c.isEmailValid, isFalse);
      expect(c.canProceedFromDetails, isFalse);
      c.emailController.text = 'a@b.com';
      expect(c.canProceedFromDetails, isTrue);
    });

    test('e164Phone composes the dial code and national number', () {
      final c = build()..nationalNumber = '712 345 678';
      expect(c.e164Phone, '+256712345678');
    });
  });

  group('per-learner primary contact + relationship', () {
    test('setPrimaryContact and setLearnerRelationship mutate the right row', () {
      final c = build()
        ..addLearner(_student('s1'))
        ..addLearner(_student('s2', name: 'Akol Natalie'));
      c.setPrimaryContact('s1', true);
      c.setLearnerRelationship('s2', 'Guardian');

      final s1 = c.selectedLearners.firstWhere((l) => l.student.id == 's1');
      final s2 = c.selectedLearners.firstWhere((l) => l.student.id == 's2');
      expect(s1.isPrimaryContact, isTrue);
      expect(s2.isPrimaryContact, isFalse);
      expect(s2.relationship, 'Guardian');
    });

    test('removeLearner drops it', () {
      final c = build()..addLearner(_student('s1'));
      c.removeLearner('s1');
      expect(c.selectedLearners, isEmpty);
    });
  });

  group('policy', () {
    test('loadPolicy pulls maxGuardians from the directory payload', () async {
      when(() => repo.listParentAccessInvites(pageSize: 1))
          .thenAnswer((_) async => Right(_page(maxGuardians: 4)));
      final c = build();
      await c.loadPolicy();
      expect(c.maxGuardians, 4);
    });
  });

  group('duplicate detection', () {
    test('next() surfaces an existing parent with a matching phone tail', () async {
      when(() => repo.listParentAccessInvites(pageSize: 100)).thenAnswer(
        (_) async => Right(_page(rows: [
          const ParentAccessInvite(
            inviteId: 'inv-existing',
            parentName: 'Naluwagga Sarah',
            maskedPhone: '***5678',
            learnerCount: 1,
            status: ParentInviteStatus.active,
          ),
        ])),
      );
      final c = build()
        ..parentNameController.text = 'Naluwagga Sarah'
        ..nationalNumber = '712345678'
        ..addLearner(_student('s9'));

      await c.next();
      expect(c.stage, LinkParentStage.review);
      expect(c.duplicateMatch, isNotNull);
      expect(c.duplicateMatch!.inviteId, 'inv-existing');
    });

    test('no match leaves duplicateMatch null', () async {
      final c = build()
        ..parentNameController.text = 'New Person'
        ..nationalNumber = '700000000'
        ..addLearner(_student('s9'));
      await c.next();
      expect(c.duplicateMatch, isNull);
    });
  });

  group('submit', () {
    setUp(() {
      when(() => repo.issueParentAccessCode(
            parentName: any(named: 'parentName'),
            phoneNumber: any(named: 'phoneNumber'),
            email: any(named: 'email'),
            learners: any(named: 'learners'),
          )).thenAnswer((_) async => Right(
            IssuedParentAccessCode(
              inviteId: 'inv-new',
              code: 'SP123456',
              expiresAt: DateTime.now().add(const Duration(days: 7)),
              invitationStatus: 'sent',
              invitationDelivered: true,
            ),
          ));
    });

    test('submitNewParent advances to sent and clears the draft', () async {
      final c = build()
        ..parentNameController.text = 'Naluwagga Sarah'
        ..nationalNumber = '712345678'
        ..emailController.text = 'sarah@example.com'
        ..addLearner(_student('s1'));

      final ok = await c.submitNewParent();
      expect(ok, isTrue);
      expect(c.stage, LinkParentStage.sent);
      expect(c.resultInviteId, 'inv-new');
      expect(c.resultInvitationDelivered, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('link_parent_draft_schoolA_admin1'), isNull);
    });

    test('a second submit while one is in flight is a no-op', () async {
      final c = build()
        ..parentNameController.text = 'X'
        ..nationalNumber = '712345678'
        ..addLearner(_student('s1'));
      c.submitting = true; // simulate in-flight
      expect(await c.submitNewParent(), isFalse);
    });

    test('submitLinkToExisting uses the duplicate match', () async {
      when(() => repo.linkLearnersToExistingParent(
            inviteId: any(named: 'inviteId'),
            learners: any(named: 'learners'),
          )).thenAnswer((_) async => const Right(null));

      when(() => repo.listParentAccessInvites(pageSize: 100)).thenAnswer(
        (_) async => Right(_page(rows: [
          const ParentAccessInvite(
            inviteId: 'inv-existing',
            parentName: 'Naluwagga Sarah',
            maskedPhone: '***5678',
            learnerCount: 1,
            status: ParentInviteStatus.active,
          ),
        ])),
      );

      final c = build()
        ..parentNameController.text = 'Naluwagga Sarah'
        ..nationalNumber = '712345678'
        ..addLearner(_student('s9'));
      await c.next();
      final ok = await c.submitLinkToExisting();
      expect(ok, isTrue);
      expect(c.stage, LinkParentStage.sent);
      verify(() => repo.linkLearnersToExistingParent(
            inviteId: 'inv-existing',
            learners: any(named: 'learners'),
          )).called(1);
    });

    test('a failed submit surfaces submitError and stays on review', () async {
      when(() => repo.issueParentAccessCode(
            parentName: any(named: 'parentName'),
            phoneNumber: any(named: 'phoneNumber'),
            email: any(named: 'email'),
            learners: any(named: 'learners'),
          )).thenAnswer(
        (_) async => const Left(ServerFailure('boom')),
      );
      final c = build()
        ..parentNameController.text = 'X'
        ..nationalNumber = '712345678'
        ..addLearner(_student('s1'));
      final ok = await c.submitNewParent();
      expect(ok, isFalse);
      expect(c.submitError, 'boom');
      expect(c.stage, LinkParentStage.details);
    });
  });

  group('draft persistence', () {
    test('a filled draft is written and restored, learners resolved via roster',
        () async {
      final c = build()
        ..parentNameController.text = 'Naluwagga Sarah'
        ..nationalNumber = '712345678'
        ..relationship = 'Mother';
      c.addLearner(_student('s1', name: 'Akol Kevin'));
      c.setPrimaryContact('s1', true);
      await c.flushDraft();

      final roster = [_student('s1', name: 'Akol Kevin')];
      final fresh = build();
      final restored = await fresh.restoreDraftIfPresent(
        (id) {
          final matches = roster.where((s) => s.id == id);
          return matches.isEmpty ? null : matches.first;
        },
      );
      expect(restored, isTrue);
      expect(fresh.parentName, 'Naluwagga Sarah');
      expect(fresh.nationalNumber, '712345678');
      expect(fresh.selectedLearners.single.student.id, 's1');
      expect(fresh.selectedLearners.single.isPrimaryContact, isTrue);
    });

    test('a stale (>24h) draft is dropped', () async {
      SharedPreferences.setMockInitialValues({
        'link_parent_draft_schoolA_admin1': _staleDraftJson(),
      });
      final c = build();
      final restored = await c.restoreDraftIfPresent((_) => null);
      expect(restored, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('link_parent_draft_schoolA_admin1'), isNull);
    });
  });
}

String _staleDraftJson() {
  final old = DateTime.now()
      .subtract(const Duration(hours: 30))
      .millisecondsSinceEpoch;
  return '{"savedAt":$old,"draft":{"parentName":"Old","nationalNumber":"700",'
      '"dialCode":"+256","email":"","relationship":"Mother","learners":[],'
      '"sendInvitation":true}}';
}

