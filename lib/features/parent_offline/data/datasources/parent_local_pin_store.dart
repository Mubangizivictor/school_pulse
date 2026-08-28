import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local device gate for reopening the mobile Parent Portal offline. This is
/// deliberately NOT the same PIN as the server-authenticated login PIN
/// (`completeParentPinSetup`) - it is a device-local re-entry check set up
/// once, during online first setup, and verified entirely on-device
/// afterwards so a parent can reopen the app in airplane mode. Only a
/// salted hash is ever persisted, never the PIN itself, and never in logs.
///
/// Scoped per parentId (keyed storage entries) so a device shared across
/// sessions (tenant switch, user switch) cannot let one parent's PIN unlock
/// another parent's cached data - callers must also secure-clear the entry
/// for the previous parentId on logout/switch.
class ParentLocalPinStore {
  final FlutterSecureStorage _storage;

  ParentLocalPinStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  String _hashKey(String parentId) => 'parent_offline_pin_hash_$parentId';
  String _saltKey(String parentId) => 'parent_offline_pin_salt_$parentId';

  Future<void> setPin({required String parentId, required String pin}) async {
    if (kIsWeb) return;
    final salt = _generateSalt();
    final hash = _hash(pin, salt);
    await _storage.write(key: _saltKey(parentId), value: salt);
    await _storage.write(key: _hashKey(parentId), value: hash);
  }

  Future<bool> hasPin(String parentId) async {
    if (kIsWeb) return false;
    final hash = await _storage.read(key: _hashKey(parentId));
    return hash != null;
  }

  Future<bool> verifyPin({
    required String parentId,
    required String pin,
  }) async {
    if (kIsWeb) return false;
    final salt = await _storage.read(key: _saltKey(parentId));
    final storedHash = await _storage.read(key: _hashKey(parentId));
    if (salt == null || storedHash == null) return false;
    return _hash(pin, salt) == storedHash;
  }

  Future<void> clear(String parentId) async {
    await _storage.delete(key: _hashKey(parentId));
    await _storage.delete(key: _saltKey(parentId));
  }

  String _generateSalt() {
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    return sha256.convert(utf8.encode(random)).toString().substring(0, 16);
  }

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();
}
