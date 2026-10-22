import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

/// Thrown for any non-2xx response from the public_functions onRequest
/// endpoints, carrying the backend's `error` code and `message` verbatim
/// (see public_functions/index.js, email_verification.js, payments.js).
class RegistrationApiException implements Exception {
  final int status;
  final String code;
  final String message;
  RegistrationApiException(this.status, this.code, this.message);

  @override
  String toString() => message;
}

/// Wraps Firebase Auth + the public_functions onRequest/onCall endpoints
/// that back the public school-registration wizard. Mirrors
/// web_marketing/js/registration-auth.js and register-submit.js exactly —
/// same project, same endpoints, same payload shapes — so the Flutter
/// wizard and the marketing site submit to (and are reviewed by) the same
/// backend without any new Cloud Functions or Firestore rules.
class RegistrationService {
  RegistrationService._();
  static final RegistrationService instance = RegistrationService._();

  // Matches main.dart's opt-in emulator wiring, so a
  // --dart-define=USE_FIREBASE_EMULATOR=true run sends these HTTP calls to the
  // Functions emulator along with its emulator-issued ID token.
  static const _functionsBase = bool.fromEnvironment('USE_FIREBASE_EMULATOR')
      ? 'http://127.0.0.1:5001/school-pulse-3d95b/europe-west1'
      : 'https://europe-west1-school-pulse-3d95b.cloudfunctions.net';

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  User? get currentUser => _auth.currentUser;

  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed != null && refreshed.emailVerified) {
      // Force-refresh the ID token so the claim it carries is fresh by the
      // time submitSchoolApplication is called, matching register-submit.js.
      await refreshed.getIdToken(true);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> _call(
    String name, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw RegistrationApiException(
        401,
        'not_signed_in',
        'Please sign in first.',
      );
    }
    final token = await user.getIdToken();
    final uri = Uri.parse('$_functionsBase/$name');
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      if (body != null) 'Content-Type': 'application/json',
    };
    final res = method == 'GET'
        ? await http.get(uri, headers: headers)
        : await http.post(uri, headers: headers, body: jsonEncode(body));
    Map<String, dynamic> data = {};
    try {
      data = res.body.isEmpty
          ? {}
          : jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      // Non-JSON body (e.g. an upstream 502) — fall through with empty data
      // so callers still see the HTTP status via RegistrationApiException.
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw RegistrationApiException(
        res.statusCode,
        (data['error'] as String?) ?? 'unknown_error',
        (data['message'] as String?) ??
            'Something went wrong. Please try again.',
      );
    }
    return data;
  }

  Future<void> requestEmailVerification() {
    return _call('requestEmailVerification', method: 'POST');
  }

  /// checkPortalSlug is an onCall function (cloud_functions SDK), not an
  /// onRequest endpoint — matches public_functions/portal_domains.js exactly.
  Future<({bool available, String? reason})> checkSlugAvailability(
    String slug,
  ) async {
    final callable = _functions.httpsCallable('checkPortalSlug');
    final result = await callable.call({'slug': slug});
    final data = Map<String, dynamic>.from(result.data as Map);
    return (
      available: data['available'] == true,
      reason: data['reason'] as String?,
    );
  }

  Future<Map<String, dynamic>> submitSchoolApplication(
    Map<String, dynamic> body,
  ) {
    return _call('submitSchoolApplication', method: 'POST', body: body);
  }

  Future<Map<String, dynamic>> getSchoolApplicationStatus() {
    return _call('getSchoolApplicationStatus');
  }

  Future<Map<String, dynamic>> getManualPaymentContext() {
    return _call('getManualPaymentContext');
  }

  Future<String> uploadPaymentProof(File file, String fileName) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw RegistrationApiException(
        401,
        'not_signed_in',
        'Please sign in first.',
      );
    }
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    final path =
        'payment_proofs/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    return path;
  }

  Future<Map<String, dynamic>> submitManualPayment(Map<String, dynamic> body) {
    return _call('submitManualPayment', method: 'POST', body: body);
  }
}
