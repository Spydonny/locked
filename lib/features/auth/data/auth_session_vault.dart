import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../domain/entities/auth_snapshot.dart';
import '../domain/entities/auth_tokens.dart';
import '../domain/entities/auth_user.dart';

class AuthSessionVault {
  AuthSessionVault(this._storage);

  final SecureStorageService _storage;
  final StreamController<AuthSnapshot> _controller =
      StreamController<AuthSnapshot>.broadcast();

  AuthSnapshot _snapshot = AuthSnapshot.empty();

  AuthSnapshot get snapshot => _snapshot;
  Stream<AuthSnapshot> get changes => _controller.stream;

  Future<AuthSnapshot> hydrate() async {
    AuthSnapshot? stored;
    try {
      stored = await _storage.readSession();
    } catch (error) {
      debugPrint('[AuthSessionVault] hydrate failed: $error');
      stored = null;
    }

    _snapshot = stored?.copyWith(hydrated: true) ?? const AuthSnapshot(hydrated: true);
    _controller.add(_snapshot);
    return _snapshot;
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    _snapshot = _snapshot.copyWith(
      hydrated: true,
      tokens: tokens,
    );
    await _persist();
  }

  Future<void> saveUser(AuthUser user) async {
    _snapshot = _snapshot.copyWith(
      hydrated: true,
      user: user,
    );
    await _persist();
  }

  Future<void> clear() async {
    _snapshot = const AuthSnapshot(hydrated: true);
    await _storage.clear();
    _controller.add(_snapshot);
  }

  Future<void> _persist() async {
    await _storage.writeSession(_snapshot);
    _controller.add(_snapshot);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
