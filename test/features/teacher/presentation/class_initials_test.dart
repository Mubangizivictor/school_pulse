import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/class_label.dart';

void main() {
  group('class tile token', () {
    test('keeps sibling classes distinguishable', () {
      // The defect real data exposed: taking the first word rendered every
      // Primary class as an identical "Primary" tile, so a teacher could not
      // tell their two classes apart in the list.
      expect(classInitials('Primary 3'), 'P3');
      expect(classInitials('Primary 4'), 'P4');
      expect(classInitials('Primary 3') == classInitials('Primary 4'), isFalse);
    });

    test('keeps the stream letter when the class has one', () {
      expect(classInitials('Grade 10A'), 'G10A');
    });

    test('handles a three-word class name', () {
      expect(classInitials('Senior 1 East'), 'SE1');
    });

    test('leaves an already-short name alone', () {
      expect(classInitials('S1'), 'S1');
      expect(classInitials('P7'), 'P7');
    });

    test('truncates something unreasonably long rather than overflowing', () {
      expect(classInitials('Foundation').length, lessThanOrEqualTo(5));
      expect(classInitials('Lower Kindergarten Blue Group').length,
          lessThanOrEqualTo(5));
    });

    test('falls back when there is no class name', () {
      expect(classInitials('', fallback: 'Class Teacher'), 'Class Teacher');
      expect(classInitials('   ', fallback: 'Staff'), 'Staff');
    });
  });
}
