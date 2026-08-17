import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/verification/domain/services/qr_credential_codec.dart';

void main() {
  const codec = QrCredentialCodec();

  test('issues opaque versioned credentials with no student data', () {
    final first = codec.issuePayload();
    final second = codec.issuePayload();

    expect(first, startsWith('SPQR1.'));
    expect(second, startsWith('SPQR1.'));
    expect(first, isNot(equals(second)));
    expect(first, isNot(contains('student')));
    expect(codec.parse(first), isNotNull);
  });

  test('rejects arbitrary, malformed, and unsupported QR payloads', () {
    expect(codec.parse('https://example.com'), isNull);
    expect(codec.parse('SPQR2.anything'), isNull);
    expect(codec.parse('SPQR1.short'), isNull);
  });
}
