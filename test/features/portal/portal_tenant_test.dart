import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/portal/domain/portal_tenant.dart';

void main() {
  test('portal tenant maps only public branding', () {
    final tenant = PortalTenant.fromMap('greenhill.schoolpulseapp.com', {
      'schoolId': 'schoolA',
      'slug': 'greenhill',
      'schoolName': 'Greenhill',
      'primaryColor': '#123456',
    });
    expect(tenant.schoolId, 'schoolA');
    expect(tenant.branding.schoolName, 'Greenhill');
  });
}
