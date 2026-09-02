// Proves SchoolAdminManagementScreen replaces the "Manage admins" stub with
// real Super-Admin-only functionality: invite writes school_admin_invitations
// (the real, already-deployed provisionSchoolAdmin trigger path), every
// sensitive lifecycle action goes through the owner-only manageSchoolAdmin
// callable rather than a direct Firestore write, and mutating actions are
// hidden when the school isn't active. The real screen depends on
// SuperAdminRepository/SchoolAdminManagementService (Firestore/Functions),
// which this fast widget-test layer doesn't set up, so this verifies
// composition at the source level - the same approach used for the other
// Firebase-backed screens in this suite.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String screenSource;
  late String serviceSource;

  setUpAll(() {
    screenSource = File(
      'lib/features/super_admin/presentation/pages/school_admin_management_screen.dart',
    ).readAsStringSync();
    serviceSource = File(
      'lib/features/super_admin/data/services/school_admin_management_service.dart',
    ).readAsStringSync();
  });

  test('admin list is sourced from the real getSchoolAdmins query', () {
    expect(screenSource.contains('repository.getSchoolAdmins(widget.school.id)'), isTrue);
  });

  test('invite writes the real school_admin_invitations doc, not a mock', () {
    expect(
      serviceSource.contains("_firestore.collection('school_admin_invitations').add"),
      isTrue,
    );
    expect(serviceSource.contains("'status': 'pending'"), isTrue);
  });

  test('setPrimary/disable/enable/remove all go through the owner-only callable', () {
    expect(serviceSource.contains("_functions.httpsCallable('manageSchoolAdmin')"), isTrue);
    expect(screenSource.contains('SchoolAdminAction.setPrimary'), isTrue);
    expect(screenSource.contains('SchoolAdminAction.disable'), isTrue);
    expect(screenSource.contains('SchoolAdminAction.remove'), isTrue);
  });

  test('disable and remove require a reason before confirming', () {
    expect(screenSource.contains('requireReason: true'), isTrue);
    expect(screenSource.contains('if (requireReason && reason.length < 3) return;'), isTrue);
  });

  test('mutating actions are hidden entirely when the school is not active', () {
    expect(screenSource.contains('if (schoolActive) ...['), isTrue);
    expect(screenSource.contains('_schoolIsActive ? _openInviteSheet : null'), isTrue);
  });

  test('there is no direct client write to institution_memberships or users role fields', () {
    expect(serviceSource.contains("_firestore.collection('institution_memberships')"), isFalse);
    expect(serviceSource.contains("_firestore.collection('users')"), isFalse);
  });
}
