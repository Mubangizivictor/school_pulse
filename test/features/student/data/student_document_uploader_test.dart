import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/student/data/student_document_uploader.dart';

void main() {
  late List<({String path, String contentType})> puts;
  late StudentDocumentUploader uploader;
  bool throwOnPut = false;

  setUp(() {
    puts = [];
    throwOnPut = false;
    uploader = StudentDocumentUploader(
      put: (objectPath, bytes, contentType) async {
        if (throwOnPut) throw Exception('network');
        puts.add((path: objectPath, contentType: contentType));
      },
    );
  });

  group('validate', () {
    test(
      'accepts a file matching the requirement\'s allowed types and size',
      () {
        final result = uploader.validate(
          fileName: 'birth_cert.pdf',
          sizeBytes: 1024,
          allowedTypes: ['pdf', 'jpg'],
          maxSizeMb: 5,
        );
        expect(result.allowed, isTrue);
      },
    );

    test('rejects a type not in the requirement\'s allowlist', () {
      final result = uploader.validate(
        fileName: 'birth_cert.docx',
        sizeBytes: 1024,
        allowedTypes: ['pdf', 'jpg'],
        maxSizeMb: 5,
      );
      expect(result.allowed, isFalse);
      expect(result.reason, contains('PDF'));
    });

    test('rejects a file over the requirement\'s max size', () {
      final result = uploader.validate(
        fileName: 'scan.pdf',
        sizeBytes: 6 * 1024 * 1024,
        allowedTypes: ['pdf'],
        maxSizeMb: 5,
      );
      expect(result.allowed, isFalse);
      expect(result.reason, contains('5 MB'));
    });

    test('rejects an empty file', () {
      final result = uploader.validate(fileName: 'x.pdf', sizeBytes: 0);
      expect(result.allowed, isFalse);
    });

    test('rejects an extensionless file name', () {
      final result = uploader.validate(fileName: 'noext', sizeBytes: 10);
      expect(result.allowed, isFalse);
    });

    test(
      'falls back to a safe default allowlist/size when the requirement has none',
      () {
        final ok = uploader.validate(fileName: 'a.png', sizeBytes: 1024);
        final tooBig = uploader.validate(
          fileName: 'a.png',
          sizeBytes:
              (StudentDocumentUploader.defaultMaxSizeMb + 1) * 1024 * 1024,
        );
        expect(ok.allowed, isTrue);
        expect(tooBig.allowed, isFalse);
      },
    );
  });

  test(
    'uploads to the tenant-scoped draft-first student documents path',
    () async {
      final path = await uploader.upload(
        schoolId: 'school-1',
        studentId: 'draft-student-1',
        docId: 'doc-1',
        fileName: 'birth_cert.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(path, 'schools/school-1/students/draft-student-1/documents/doc-1');
      expect(puts, hasLength(1));
      expect(puts.single.contentType, 'application/pdf');
    },
  );

  test('propagates an upload failure so the caller can offer retry', () async {
    throwOnPut = true;
    expect(
      () => uploader.upload(
        schoolId: 'school-1',
        studentId: 'draft-student-1',
        docId: 'doc-1',
        fileName: 'a.png',
        bytes: Uint8List.fromList([1]),
      ),
      throwsException,
    );
  });
}
