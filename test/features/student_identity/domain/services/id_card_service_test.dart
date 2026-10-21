import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/student_identity/domain/services/id_card_service.dart';

void main() {
  late IdCardService service;

  setUp(() => service = IdCardService());

  test('generateIdCardPdf produces a single-page PDF', () async {
    final pdfData = await service.generateIdCardPdf(
      schoolName: 'School Pulse Academy',
      studentName: 'Jane Doe',
      admissionNumber: 'SP-2026-0001',
      studentId: 'MH-2026-000001',
      className: 'Primary 4',
      stream: 'Blue',
      uniqueSystemId: 'SP-STUDENT-abc',
      qrCodeData: 'SP-STUDENT-abc',
    );

    expect(pdfData, isNotEmpty);
    expect(String.fromCharCodes(pdfData.take(4)), '%PDF');
  });

  test(
    'generateBatchIdCardsPdf produces one PDF covering every entry',
    () async {
      final entries = List.generate(
        3,
        (i) => IdCardBatchEntry(
          studentName: 'Student $i',
          admissionNumber: 'SP-2026-000$i',
          studentId: 'MH-2026-00000$i',
          className: 'Primary 4',
          stream: 'Blue',
          uniqueSystemId: 'SP-STUDENT-$i',
          qrCodeData: 'SP-STUDENT-$i',
        ),
      );

      final singleCard = await service.generateIdCardPdf(
        schoolName: 'School Pulse Academy',
        studentName: entries.first.studentName,
        admissionNumber: entries.first.admissionNumber,
        studentId: entries.first.studentId,
        className: entries.first.className,
        stream: entries.first.stream,
        uniqueSystemId: entries.first.uniqueSystemId,
        qrCodeData: entries.first.qrCodeData,
      );

      final batchPdf = await service.generateBatchIdCardsPdf(
        schoolName: 'School Pulse Academy',
        entries: entries,
      );

      expect(batchPdf, isNotEmpty);
      expect(String.fromCharCodes(batchPdf.take(4)), '%PDF');
      // Every entry contributes a front + back page. Shared fonts/images make
      // byte size a poor proxy, so count `/Type /Page` objects instead.
      int pageCount(List<int> pdf) => RegExp(
        r'/Type\s*/Page(?![s\w])',
      ).allMatches(String.fromCharCodes(pdf)).length;
      expect(pageCount(singleCard), greaterThan(0));
      expect(pageCount(batchPdf), entries.length * pageCount(singleCard));
    },
  );

  test(
    'generateBatchIdCardsPdf with an empty list still returns a valid (empty-page) PDF',
    () async {
      final batchPdf = await service.generateBatchIdCardsPdf(
        schoolName: 'School Pulse Academy',
        entries: const [],
      );

      expect(batchPdf, isNotEmpty);
      expect(String.fromCharCodes(batchPdf.take(4)), '%PDF');
    },
  );
}
