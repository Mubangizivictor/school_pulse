import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/domain/policies/class_resource_policy.dart';

const _oneMb = 1024 * 1024;

ClassResource _resource({
  ClassResourceOrigin origin = ClassResourceOrigin.ownUpload,
  String uploadedBy = 'teacher1',
  String classId = 'p7',
  String? sourceResourceId,
}) {
  return ClassResource(
    id: 'r1',
    schoolId: 'school1',
    classId: classId,
    academicYearId: '2026',
    name: 'Fractions worksheet.pdf',
    kind: ClassResourceKind.document,
    origin: origin,
    sourceResourceId: sourceResourceId,
    uploadedByUserId: uploadedBy,
    uploadedAt: DateTime(2026, 6, 1),
  );
}

void main() {
  group('what may be uploaded', () {
    ResourceDecision upload(String name, {int size = _oneMb}) {
      return ClassResourcePolicy.canUpload(
        fileName: name,
        sizeBytes: size,
        currentUsageBytes: 0,
        quotaBytes: 1000 * _oneMb,
      );
    }

    test('documents, images, audio and video are accepted', () {
      for (final name in [
        'worksheet.pdf',
        'notes.docx',
        'marks.xlsx',
        'slides.pptx',
        'diagram.png',
        'recording.m4a',
        'lesson.mp4',
      ]) {
        expect(upload(name).isAllowed, isTrue, reason: name);
      }
    });

    test('an executable is refused', () {
      expect(upload('trojan.exe').refusal, ResourceRefusal.unsafeFileType);
      expect(upload('script.sh').refusal, ResourceRefusal.unsafeFileType);
      expect(upload('installer.dmg').refusal, ResourceRefusal.unsafeFileType);
    });

    test('anything unrecognised is refused rather than allowed', () {
      // The allow-list is the point: the dangerous-extension list is
      // open-ended, so unknown means no.
      expect(upload('payload.xyz').refusal, ResourceRefusal.unsafeFileType);
    });

    test('a file with no extension is refused', () {
      expect(upload('README').refusal, ResourceRefusal.unsafeFileType);
    });

    test('a double extension is judged on the last one', () {
      // "worksheet.pdf.exe" is an executable, whatever it looks like.
      expect(
        upload('worksheet.pdf.exe').refusal,
        ResourceRefusal.unsafeFileType,
      );
    });

    test('an oversized document is refused', () {
      expect(
        upload('huge.pdf', size: 30 * _oneMb).refusal,
        ResourceRefusal.fileTooLarge,
      );
    });

    test('video gets more room than a worksheet', () {
      // A lesson recording is legitimately larger.
      expect(upload('lesson.mp4', size: 100 * _oneMb).isAllowed, isTrue);
      expect(
        upload('lesson.mp4', size: 300 * _oneMb).refusal,
        ResourceRefusal.fileTooLarge,
      );
    });

    test('an upload that would exhaust the school quota is refused', () {
      final decision = ClassResourcePolicy.canUpload(
        fileName: 'worksheet.pdf',
        sizeBytes: 5 * _oneMb,
        currentUsageBytes: 98 * _oneMb,
        quotaBytes: 100 * _oneMb,
      );

      expect(decision.refusal, ResourceRefusal.storageQuotaExceeded);
    });
  });

  group('links', () {
    test('need a name', () {
      expect(
        ClassResourcePolicy.canAddLink(name: 'x', url: 'https://example.org')
            .refusal,
        ResourceRefusal.nameRequired,
      );
    });

    test('must be http or https', () {
      // A link is the obvious way round an upload guard.
      for (final url in ['file:///etc/passwd', 'javascript:alert(1)', 'not a url']) {
        expect(
          ClassResourcePolicy.canAddLink(name: 'Reference', url: url).refusal,
          ResourceRefusal.invalidLink,
          reason: url,
        );
      }
    });

    test('a normal web address is accepted', () {
      expect(
        ClassResourcePolicy.canAddLink(
          name: 'Khan Academy fractions',
          url: 'https://khanacademy.org/fractions',
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('deleting', () {
    test('the uploader may delete their own file, and it goes', () {
      final outcome = ClassResourcePolicy.canDelete(
        resource: _resource(),
        userId: 'teacher1',
        classId: 'p7',
      );

      expect(outcome.isAllowed, isTrue);
      expect(outcome.removesStoredFile, isTrue);
    });

    test('detaching an attached resource leaves the original alone', () {
      // Tidying one class's folder must not delete the library's copy.
      final outcome = ClassResourcePolicy.canDelete(
        resource: _resource(
          origin: ClassResourceOrigin.attached,
          sourceResourceId: 'libraryCopy',
          uploadedBy: 'librarian',
        ),
        userId: 'teacher1',
        classId: 'p7',
      );

      expect(outcome.isAllowed, isTrue);
      expect(outcome.removesStoredFile, isFalse);
    });

    test('another teacher\'s upload cannot be deleted', () {
      final outcome = ClassResourcePolicy.canDelete(
        resource: _resource(uploadedBy: 'anotherTeacher'),
        userId: 'teacher1',
        classId: 'p7',
      );

      expect(outcome.decision.refusal, ResourceRefusal.notOwner);
      expect(outcome.removesStoredFile, isFalse);
    });

    test('a resource in another class is refused outright', () {
      final outcome = ClassResourcePolicy.canDelete(
        resource: _resource(classId: 'p6'),
        userId: 'teacher1',
        classId: 'p7',
      );

      expect(outcome.decision.refusal, ResourceRefusal.notInThisClass);
    });
  });

  group('kind resolution', () {
    test('maps extensions to kinds', () {
      expect(
        ClassResourceKind.fromExtension('pdf'),
        ClassResourceKind.document,
      );
      expect(ClassResourceKind.fromExtension('.PNG'), ClassResourceKind.image);
      expect(ClassResourceKind.fromExtension('mp4'), ClassResourceKind.video);
    });

    test('falls to other for anything unknown', () {
      expect(ClassResourceKind.fromExtension('bin'), ClassResourceKind.other);
    });
  });

  group('audience', () {
    test('every option stays inside the class', () {
      // There is no school-wide or all-classes option to pick.
      expect(ClassResourceAudience.values.map((a) => a.label), [
        'Only me',
        'My class',
        'Class and guardians',
      ]);
    });
  });
}
