// Fee Plan Builder Phase 1 coverage: the client-side draft validator must
// reject decimal amounts outright (money is integer UGX everywhere per the
// backend's own `asMoney` validator in functions/student_fee_billing.js)
// and must block publishing over an already-published overlapping selector
// as a UX nicety on top of the server's own uniqueness guarantee.
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/finance/presentation/screens/fee_plan_builder/fee_plan_editor_dialog.dart';

void main() {
  group('validateFeePlanDraft', () {
    test('accepts a valid whole-number-UGX draft', () {
      final error = validateFeePlanDraft(
        name: 'Term 1 Fees',
        academicYearId: 'year-1',
        termId: 'term-1',
        classId: 'class-1',
        lineNames: ['Tuition'],
        lineAmountTexts: ['500000'],
        hasOverlap: false,
      );
      expect(error, isNull);
    });

    test('rejects a decimal amount rather than rounding it', () {
      final error = validateFeePlanDraft(
        name: 'Term 1 Fees',
        academicYearId: 'year-1',
        termId: 'term-1',
        classId: 'class-1',
        lineNames: ['Tuition'],
        lineAmountTexts: ['12000.50'],
        hasOverlap: false,
      );
      expect(error, contains('whole number'));
    });

    test('rejects a negative amount', () {
      final error = validateFeePlanDraft(
        name: 'Term 1 Fees',
        academicYearId: 'year-1',
        termId: 'term-1',
        classId: 'class-1',
        lineNames: ['Tuition'],
        lineAmountTexts: ['-1000'],
        hasOverlap: false,
      );
      expect(error, isNotNull);
    });

    test('rejects a non-numeric amount', () {
      final error = validateFeePlanDraft(
        name: 'Term 1 Fees',
        academicYearId: 'year-1',
        termId: 'term-1',
        classId: 'class-1',
        lineNames: ['Tuition'],
        lineAmountTexts: ['abc'],
        hasOverlap: false,
      );
      expect(error, isNotNull);
    });

    test('requires a plan name, year, term and class before anything else', () {
      expect(
        validateFeePlanDraft(
          name: '',
          academicYearId: 'year-1',
          termId: 'term-1',
          classId: 'class-1',
          lineNames: ['Tuition'],
          lineAmountTexts: ['500000'],
          hasOverlap: false,
        ),
        'Enter a plan name.',
      );
      expect(
        validateFeePlanDraft(
          name: 'Plan',
          academicYearId: null,
          termId: 'term-1',
          classId: 'class-1',
          lineNames: ['Tuition'],
          lineAmountTexts: ['500000'],
          hasOverlap: false,
        ),
        'Select an academic year.',
      );
    });

    test('rejects an overlapping selector even when every line is valid', () {
      final error = validateFeePlanDraft(
        name: 'Term 1 Fees',
        academicYearId: 'year-1',
        termId: 'term-1',
        classId: 'class-1',
        lineNames: ['Tuition'],
        lineAmountTexts: ['500000'],
        hasOverlap: true,
      );
      expect(error, contains('already exists'));
    });

    test('requires at least one fee line', () {
      final error = validateFeePlanDraft(
        name: 'Term 1 Fees',
        academicYearId: 'year-1',
        termId: 'term-1',
        classId: 'class-1',
        lineNames: const [],
        lineAmountTexts: const [],
        hasOverlap: false,
      );
      expect(error, 'Add at least one fee line.');
    });
  });
}
