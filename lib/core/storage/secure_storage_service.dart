import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/entities/auth_snapshot.dart';
import 'web_session_storage_stub.dart'
    if (dart.library.html) 'web_session_storage_web.dart';

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
    if (kIsWeb) {
      await writeWebSession(_sessionKey, jsonEncode(snapshot.toJson()));
      return;
    }

    try {
      await _storage.write(
        key: _sessionKey,
        value: jsonEncode(snapshot.toJson()),
      ).timeout(const Duration(seconds: 2));
    } catch (_) {
      // Secure storage can be unavailable on Flutter Web / some desktop targets.
      // In that case we fall back to non-persistent sessions.
    }
  }

  Future<AuthSnapshot?> readSession() async {
    if (kIsWeb) {
      final raw = await readWebSession(_sessionKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }

      return AuthSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }

    try {
      final raw = await _storage
          .read(key: _sessionKey)
          .timeout(const Duration(seconds: 2));
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
    if (kIsWeb) {
      await clearWebSession(_sessionKey);
      return;
    }

    try {
      await _storage.delete(key: _sessionKey).timeout(
            const Duration(seconds: 2),
          );
    } catch (_) {}
  }
}
