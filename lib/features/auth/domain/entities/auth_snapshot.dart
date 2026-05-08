import 'auth_tokens.dart';
import 'auth_user.dart';

class AuthSnapshot {
  const AuthSnapshot({
    required this.hydrated,
    this.tokens,
    this.user,
  });

  final bool hydrated;
  final AuthTokens? tokens;
  final AuthUser? user;

  bool get hasTokens => tokens != null;
  bool get isAuthenticated => tokens != null && user != null;

  factory AuthSnapshot.empty() => const AuthSnapshot(hydrated: false);

  factory AuthSnapshot.fromJson(Map<String, dynamic> json) {
    return AuthSnapshot(
      hydrated: json['hydrated'] as bool? ?? true,
      tokens: json['tokens'] == null
          ? null
          : AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hydrated': hydrated,
      'tokens': tokens?.toJson(),
      'user': user?.toJson(),
    };
  }

  AuthSnapshot copyWith({
    bool? hydrated,
    AuthTokens? tokens,
    AuthUser? user,
    bool clearTokens = false,
    bool clearUser = false,
  }) {
    return AuthSnapshot(
      hydrated: hydrated ?? this.hydrated,
      tokens: clearTokens ? null : (tokens ?? this.tokens),
      user: clearUser ? null : (user ?? this.user),
    );
  }
}
