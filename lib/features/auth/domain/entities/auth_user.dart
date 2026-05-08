class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? json['_id'] as String,
      email: json['email'] as String,
      displayName:
          json['display_name'] as String? ?? json['displayName'] as String,
      role: json['role'] as String? ?? 'member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'role': role,
    };
  }
}
