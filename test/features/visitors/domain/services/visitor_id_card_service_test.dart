import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/visitors/domain/services/visitor_id_card_service.dart';

void main() {
  test('generateVisitorIdCardPdf produces non-empty PDF bytes', () async {
    final service = VisitorIdCardService();

    final pdfData = await service.generateVisitorIdCardPdf(
      schoolName: 'School Pulse Academy',
      visitorName: 'Jane Guest',
      badgeNumber: 'V-0001',
      host: 'Mr. Lubega',
      purpose: 'Parent meeting',
      arrivalTime: DateTime(2026, 1, 1, 9),
    );

    expect(pdfData, isNotEmpty);
    expect(String.fromCharCodes(pdfData.take(4)), '%PDF');
  });
}
