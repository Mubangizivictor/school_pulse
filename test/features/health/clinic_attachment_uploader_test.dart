import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/health/data/clinic_attachment_uploader.dart';

void main() {
  late File tempFile;
  late List<({String path, String contentType})> puts;
  late ClinicAttachmentUploader uploader;
  bool throwOnPut = false;

  setUp(() {
    puts = [];
    throwOnPut = false;
    tempFile = File(
      '${Directory.systemTemp.path}/clinic_att_${DateTime.now().microsecondsSinceEpoch}.png',
    )..writeAsBytesSync([1, 2, 3]);
    uploader = ClinicAttachmentUploader(
      put: (objectPath, file, contentType) async {
        if (throwOnPut) throw Exception('network');
        puts.add((path: objectPath, contentType: contentType));
      },
    );
  });

  tearDown(() {
    if (tempFile.existsSync()) tempFile.deleteSync();
  });

  group('isAllowed', () {
    test('accepts image and pdf under 10MB', () {
      expect(uploader.isAllowed(fileName: 'x.png', sizeBytes: 1024), isTrue);
      expect(uploader.isAllowed(fileName: 'scan.PDF', sizeBytes: 1024), isTrue);
      expect(
        uploader.isAllowed(fileName: 'p.jpeg', sizeBytes: 9 * 1024 * 1024),
        isTrue,
      );
    });

    test(
      'rejects office docs, extensionless names, empty and oversized files',
      () {
        expect(
          uploader.isAllowed(fileName: 'notes.docx', sizeBytes: 1024),
          isFalse,
        );
        expect(uploader.isAllowed(fileName: 'noext', sizeBytes: 1024), isFalse);
        expect(uploader.isAllowed(fileName: 'x.png', sizeBytes: 0), isFalse);
        expect(
          uploader.isAllowed(fileName: 'x.png', sizeBytes: 11 * 1024 * 1024),
          isFalse,
        );
      },
    );
  });

  test(
    'uploads valid files to the tenant clinic path with the right content type',
    () async {
      final result = await uploader.uploadForVisit(
        schoolId: 'school-1',
        visitId: 'visit-1',
        files: [
          (fileName: 'injury.png', sizeBytes: 3, file: tempFile),
          (fileName: 'referral.PDF', sizeBytes: 3, file: tempFile),
        ],
      );

      expect(result.failed, isEmpty);
      expect(result.paths, hasLength(2));
      expect(puts, hasLength(2));
      expect(
        puts[0].path,
        startsWith('schools/school-1/clinic_visits/visit-1/attachments/'),
      );
      expect(puts[0].path, endsWith('.png'));
      expect(puts[0].contentType, 'image/png');
      expect(puts[1].path, endsWith('.pdf'));
      expect(puts[1].contentType, 'application/pdf');
    },
  );

  test('a disallowed file is reported as failed and never uploaded', () async {
    final result = await uploader.uploadForVisit(
      schoolId: 'school-1',
      visitId: 'visit-1',
      files: [(fileName: 'sheet.xlsx', sizeBytes: 10, file: tempFile)],
    );

    expect(result.paths, isEmpty);
    expect(result.failed, ['sheet.xlsx']);
    expect(puts, isEmpty);
  });

  test('one bad file does not stop the others', () async {
    final result = await uploader.uploadForVisit(
      schoolId: 'school-1',
      visitId: 'visit-1',
      files: [
        (fileName: 'bad.docx', sizeBytes: 10, file: tempFile),
        (fileName: 'good.png', sizeBytes: 3, file: tempFile),
      ],
    );

    expect(result.failed, ['bad.docx']);
    expect(result.paths, hasLength(1));
  });

  test(
    'an upload exception is caught and the file is reported as failed',
    () async {
      throwOnPut = true;
      final result = await uploader.uploadForVisit(
        schoolId: 'school-1',
        visitId: 'visit-1',
        files: [(fileName: 'ok.png', sizeBytes: 3, file: tempFile)],
      );
      expect(result.paths, isEmpty);
      expect(result.failed, ['ok.png']);
    },
  );
}
