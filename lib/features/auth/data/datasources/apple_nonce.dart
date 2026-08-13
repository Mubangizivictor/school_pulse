import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates the raw/hashed nonce pair required by Sign in with Apple's
/// replay-protection contract: the SHA-256 hash goes to Apple as the
/// `nonce` authorization request parameter, while the raw value is later
/// handed to `OAuthProvider('apple.com').credential` so Firebase can verify
/// the identity token was minted for this exact request. Never logged, never
/// reused across requests - a fresh pair is generated per sign-in attempt.
class AppleNonce {
  final String raw;
  final String hashed;

  const AppleNonce._(this.raw, this.hashed);

  factory AppleNonce.generate() {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    final raw = List.generate(
      32,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
    final hashed = sha256.convert(utf8.encode(raw)).toString();
    return AppleNonce._(raw, hashed);
  }
}
