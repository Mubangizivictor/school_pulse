import 'dart:convert';
import 'dart:math';

/// The printable student-card QR envelope.  It deliberately contains only a
/// random credential reference: no student ID, document path, name, or other
/// personal data is encoded in the camera-readable value.
class QrCredentialCodec {
  static const _prefix = 'SPQR1';
  static final _tokenPattern = RegExp(r'^[A-Za-z0-9_-]{40,128}$');

  const QrCredentialCodec();

  String issuePayload() => '$_prefix.${_newToken()}';

  /// Returns the opaque credential reference, or null for arbitrary QR data
  /// and for versions this app does not understand.
  String? parse(String rawPayload) {
    final parts = rawPayload.trim().split('.');
    if (parts.length != 2 || parts.first != _prefix) return null;
    return _tokenPattern.hasMatch(parts.last) ? parts.last : null;
  }

  String _newToken() {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
