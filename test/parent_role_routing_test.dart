import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/user_roles.dart';

void main() {
  test('retained parent sessions resolve to the registered home route', () {
    expect(UserRoleRouting.dashboardPath(UserRole.parent), '/parent/home');
  });
}
