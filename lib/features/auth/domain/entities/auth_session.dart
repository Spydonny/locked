import 'auth_tokens.dart';
import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.tokens,
    required this.user,
  });

  final AuthTokens tokens;
  final AuthUser user;
}
