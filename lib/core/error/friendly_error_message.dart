import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Turns a caught exception into a message safe to show directly to a user
/// in a SnackBar/dialog - never the raw `Exception.toString()`, which for a
/// Dart [StateError] reads as "Bad state: ..." and for a Firebase exception
/// includes an internal `[firebase_functions/not-found]`-style code prefix.
///
/// [FirebaseFunctionsException]/[FirebaseException]/[FirebaseAuthException]
/// all carry a clean, already-human-written `.message` (the exact string a
/// Cloud Function passed to `HttpsError(code, message)`) - use that.
/// Anything else falls back to a generic message rather than leaking
/// implementation detail (a stack-trace-shaped string, a package name, a
/// raw error code) into the UI.
String friendlyErrorMessage(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is FirebaseFunctionsException) return error.message ?? fallback;
  if (error is FirebaseAuthException) return error.message ?? fallback;
  if (error is FirebaseException) return error.message ?? fallback;
  return fallback;
}
