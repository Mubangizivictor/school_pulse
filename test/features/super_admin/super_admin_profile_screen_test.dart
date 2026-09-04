// Proves SuperAdminProfileScreen mirrors the parent/staff EditProfileScreen
// avatar-upload + form pattern but writes only to users/{uid} (no
// school_contacts side effect, since the platform owner isn't a school
// contact), guards unsaved edits, validates phone format, and surfaces
// upload/save failures via a clean message rather than a raw exception.
// The real screen depends on AuthBloc/FirebaseAuth/FirebaseStorage/
// FirebaseFirestore and sl<AuthRepository>(), which this fast widget-test
// layer doesn't set up, so this verifies composition at the source level -
// the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_profile_screen.dart',
    ).readAsStringSync();
  });

  test('not-signed-in state shows an explicit message rather than crashing on a null user', () {
    expect(source.contains('if (authState is! AuthAuthenticated) {'), isTrue);
    expect(source.contains("Text('Not signed in')"), isTrue);
  });

  test('unsaved edits are guarded before navigating away', () {
    expect(source.contains('SuperAdminUnsavedChangesGuard('), isTrue);
    expect(
      source.contains('hasUnsavedChanges: _dirty && !_saving && !_uploadingPhoto'),
      isTrue,
    );
  });

  test('email field is shown but disabled - identity is not editable here', () {
    expect(source.contains("label: 'Email Address'"), isTrue);
    expect(source.contains('enabled: false'), isTrue);
  });

  test('phone validation accepts empty (optional) but rejects too-short/too-long digit counts', () {
    expect(source.contains('if (phone.isEmpty) return null;'), isTrue);
    expect(
      source.contains('if (digits.length < 7 || digits.length > 15) {'),
      isTrue,
    );
  });

  test('save writes only to users/{uid} via AuthRepository.updateProfile, not a school_contacts side effect', () {
    expect(source.contains('sl<AuthRepository>().updateProfile('), isTrue);
    expect(source.contains("collection('school_contacts')"), isFalse);
  });

  test('save failure shows the repository failure message, success refreshes AuthBloc and pops', () {
    expect(source.contains('SnackBar(content: Text(failure.message))'), isTrue);
    expect(source.contains('context.read<AuthBloc>().add(AuthCheckRequested());'), isTrue);
    expect(source.contains('Navigator.pop(context);'), isTrue);
  });

  test('photo upload goes through Firebase Storage then writes users/{uid}.photoUrl', () {
    expect(
      source.contains("FirebaseStorage.instance.ref(\n        'profile_photos/\$uid/profile.jpg',"),
      isTrue,
    );
    // set(merge:true), not update(): the owner's users/{uid} doc may not
    // exist yet, and update() would throw not-found.
    expect(
      source.contains("FirebaseFirestore.instance.collection('users').doc(uid).set("),
      isTrue,
    );
    expect(source.contains('SetOptions(merge: true)'), isTrue);
  });

  test('the cropper is skipped on web (its native UI is a no-op there)', () {
    expect(source.contains('if (kIsWeb) {'), isTrue);
    expect(source.contains('bytes = await image.readAsBytes();'), isTrue);
    // Mobile still crops.
    expect(source.contains('ImageCropper().cropImage('), isTrue);
  });

  test('photo upload failure surfaces the FirebaseException code, not a raw toString', () {
    expect(source.contains('_showPhotoError('), isTrue);
    expect(source.contains('(\${e.code})'), isTrue);
  });
}
