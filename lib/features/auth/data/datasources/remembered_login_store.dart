import 'package:shared_preferences/shared_preferences.dart';

/// Persists non-sensitive login identifiers (never passwords/PINs) so a
/// returning user isn't forced to retype them when the Remember Me toggle is
/// on. Actual session persistence comes from Firebase Auth itself; this only
/// smooths over the rare case a user does land back on a login screen.
class RememberedLoginStore {
  static const _staffEmailKey = 'remembered_staff_email';
  static const _parentCodeKey = 'remembered_parent_code';
  static const _parentPhoneKey = 'remembered_parent_phone';

  Future<String?> getStaffEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_staffEmailKey);
  }

  Future<void> setStaffEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await prefs.remove(_staffEmailKey);
    } else {
      await prefs.setString(_staffEmailKey, email);
    }
  }

  Future<({String code, String phone})?> getParentIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_parentCodeKey);
    final phone = prefs.getString(_parentPhoneKey);
    if (code == null || phone == null) return null;
    return (code: code, phone: phone);
  }

  Future<void> setParentIdentity({String? code, String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null || phone == null) {
      await prefs.remove(_parentCodeKey);
      await prefs.remove(_parentPhoneKey);
    } else {
      await prefs.setString(_parentCodeKey, code);
      await prefs.setString(_parentPhoneKey, phone);
    }
  }
}
