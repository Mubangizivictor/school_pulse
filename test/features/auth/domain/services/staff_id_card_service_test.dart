import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/auth/domain/services/staff_id_card_service.dart';

void main() {
  test('generateStaffIdCardPdf produces non-empty PDF bytes', () async {
    final service = StaffIdCardService();

    final pdfData = await service.generateStaffIdCardPdf(
      schoolName: 'School Pulse Academy',
      staffName: 'John Teacher',
      staffCode: 'SP-STAFF-001',
      roleLabel: 'Class Teacher',
    );

    expect(pdfData, isNotEmpty);
    // %PDF header confirms this is a real PDF document, not junk bytes.
    expect(String.fromCharCodes(pdfData.take(4)), '%PDF');
  });
}
