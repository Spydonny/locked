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
    debugPrint('[AuthSessionVault] hydrate(): readSession start');
    AuthSnapshot? stored;
    try {
      stored = await _storage.readSession().timeout(const Duration(seconds: 3));
      debugPrint(
        '[AuthSessionVault] hydrate(): readSession done hasStored=${stored != null}',
      );
    } on TimeoutException catch (error) {
      debugPrint('[AuthSessionVault] hydrate(): readSession timeout $error');
      stored = null;
    } catch (error) {
      debugPrint('[AuthSessionVault] hydrate failed: $error');
      stored = null;
    }

    _snapshot =
        stored?.copyWith(hydrated: true) ?? const AuthSnapshot(hydrated: true);
    debugPrint(
      '[AuthSessionVault] hydrate(): snapshot hydrated=${_snapshot.hydrated} hasTokens=${_snapshot.hasTokens}',
    );
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
