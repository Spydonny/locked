abstract interface class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> restoreSession();

  Future<void> logout();
}
