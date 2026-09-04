import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/responsive.dart';

void main() {
  group('parent access responsive breakpoints', () {
    test('390px (phone reference width) is phone tier', () {
      expect(isParentAccessPhone(390), true);
      expect(isParentAccessTablet(390), false);
      expect(isParentAccessWeb(390), false);
    });

    test('768px (tablet reference width) is tablet tier', () {
      expect(isParentAccessPhone(768), false);
      expect(isParentAccessTablet(768), true);
      expect(isParentAccessWeb(768), false);
    });

    test('1440px (desktop reference width) is web tier', () {
      expect(isParentAccessPhone(1440), false);
      expect(isParentAccessTablet(1440), false);
      expect(isParentAccessWeb(1440), true);
    });

    test('tiers are mutually exclusive and exhaustive at the boundaries', () {
      for (final width in [0.0, 759.9, 760.0, 1023.9, 1024.0, 3000.0]) {
        final tiers = [
          isParentAccessPhone(width),
          isParentAccessTablet(width),
          isParentAccessWeb(width),
        ];
        expect(tiers.where((t) => t).length, 1, reason: 'width=$width');
      }
    });
  });
}
