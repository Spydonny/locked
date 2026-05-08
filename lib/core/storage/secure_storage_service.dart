import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/entities/auth_snapshot.dart';

class SecureStorageService {
  SecureStorageService({
    FlutterSecureStorage? storage,
  }) : _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(encryptedSharedPreferences: true),
           );

  static const _sessionKey = 'locked.auth.session';

  final FlutterSecureStorage _storage;

  Future<void> writeSession(AuthSnapshot snapshot) async {
    try {
      await _storage.write(
        key: _sessionKey,
        value: jsonEncode(snapshot.toJson()),
      );
    } catch (_) {
      // Secure storage can be unavailable on Flutter Web / some desktop targets.
      // In that case we fall back to non-persistent sessions.
    }
  }

  Future<AuthSnapshot?> readSession() async {
    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }

      return AuthSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {}
  }
}
