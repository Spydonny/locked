import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_session.dart';
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
  Future<AuthSession> login({
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

    return AuthSession(tokens: tokens, user: user);
  }

  @override
  Future<AuthSession> register({
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
  Future<AuthSession?> restoreSession() async {
    final snapshot = await _vault.hydrate();
    if (!snapshot.hasTokens) {
      return null;
    }

    try {
      final user = await _apiService.getCurrentUser();
      await _vault.saveUser(user);
      final refreshedSnapshot = _vault.snapshot;
      if (refreshedSnapshot.tokens == null) {
        return null;
      }

      return AuthSession(
        tokens: refreshedSnapshot.tokens!,
        user: user,
      );
    } on ApiException {
      await _vault.clear();
      rethrow;
    }
  }

  @override
  Future<void> logout() => _vault.clear();
}
