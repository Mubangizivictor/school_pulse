import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/data_management/domain/data_operation_models.dart';

void main() {
  group('supportedImportTemplates', () {
    test(
      'uses versioned templates with required fields and duplicate keys',
      () {
        expect(supportedImportTemplates, isNotEmpty);
        for (final template in supportedImportTemplates) {
          expect(template.templateVersion, isNotEmpty);
          expect(template.requiredColumns, isNotEmpty);
          expect(template.duplicateKeys, isNotEmpty);
        }
      },
    );

    test('student import does not accept an unstructured anonymous row', () {
      final student = supportedImportTemplates.singleWhere(
        (template) => template.moduleKey == 'students',
      );
      expect(
        student.requiredColumns,
        containsAll(['admissionNumber', 'academicUnit']),
      );
      expect(student.duplicateKeys, contains('admissionNumber'));
    });
  });
}
