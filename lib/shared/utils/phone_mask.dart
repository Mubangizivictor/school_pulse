/// Masks an E.164 (or any) phone number to the same `***1234` (last-4-digits)
/// format the server's `maskPhoneNumber()` helper in functions/index.js
/// produces, so a client-side join (e.g. Parents-tab rows sourced from a
/// joined `users` doc) never displays a raw phone number.
String maskPhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return '***';
  return '***${digits.substring(digits.length - 4)}';
}
