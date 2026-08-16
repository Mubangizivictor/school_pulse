// Structural test mirroring router_owner_staff_gate_test.dart's approach:
// the Integrations Center route's redirect callback depends on
// BuildContext-scoped AuthBloc state that this fast unit-test suite has no
// lightweight way to fake end-to-end, so this proves the router source
// itself contains a permission gate restricting /staff/admin/integrations
// to School Admin/Head Teacher/Director, denying ordinary staff.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/app/router.dart').readAsStringSync();
  });

  test(
    'integrations route is guarded by an allowed-roles redirect, not left open',
    () {
      final routeIndex = source.indexOf("path: 'integrations',");
      expect(routeIndex, isNot(-1));

      final redirectIndex = source.indexOf(
        'redirect: (context, state) {',
        routeIndex,
      );
      expect(
        redirectIndex,
        isNot(-1),
        reason: 'the integrations route must declare its own redirect guard',
      );
      expect(
        redirectIndex - routeIndex < 200,
        isTrue,
        reason: 'the redirect guard must belong to the integrations route itself',
      );

      final windowEnd = (redirectIndex + 1000).clamp(0, source.length);
      final window = source.substring(redirectIndex, windowEnd);

      expect(
        window.contains('UserRole.schoolAdmin'),
        isTrue,
        reason: 'schoolAdmin must be an allowed role',
      );
      expect(window.contains('UserRole.headTeacher'), isTrue);
      expect(window.contains('UserRole.director'), isTrue);
      expect(
        window.contains('UserRoleRouting.dashboardPath'),
        isTrue,
        reason: 'a denied role must be redirected away, not merely observed',
      );
    },
  );
}
