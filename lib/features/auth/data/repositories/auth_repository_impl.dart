import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_session_vault.dart';
import '../services/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApiService apiService,
    required AuthSessionVault vault,
  })  : _apiService = apiService,
        _vault = vault;

  final AuthApiService _apiService;
  final AuthSessionVault _vault;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _apiService.login(
      email: email,
      password: password,
    );
    await _vault.saveTokens(tokens);
    final user = await _apiService.getCurrentUser();
    await _vault.saveUser(user);
  }

  @override
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await _apiService.register(
      displayName: displayName,
      email: email,
      password: password,
    );

    return login(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> restoreSession() async {
    debugPrint('[AuthRepository] restoreSession(): hydrate start');
    final snapshot = await _vault.hydrate();
    debugPrint(
      '[AuthRepository] restoreSession(): hydrate done hydrated=${snapshot.hydrated} hasTokens=${snapshot.hasTokens}',
    );
    if (!snapshot.hasTokens) {
      return;
    }

    try {
      debugPrint('[AuthRepository] restoreSession(): getCurrentUser start');
      final user = await _apiService
          .getCurrentUser()
          .timeout(const Duration(seconds: 6));
      debugPrint('[AuthRepository] restoreSession(): getCurrentUser done');
      await _vault.saveUser(user);
    } on ApiException {
      await _vault.clear();
      rethrow;
    } on TimeoutException {
      debugPrint('[AuthRepository] restoreSession(): getCurrentUser timeout');
      await _vault.clear();
    }
  }

  @override
  Future<void> logout() => _vault.clear();
}
