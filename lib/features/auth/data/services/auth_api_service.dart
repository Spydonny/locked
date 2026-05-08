import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/auth_user.dart';

class AuthApiService {
  AuthApiService({
    required Dio publicDio,
    required Dio authenticatedDio,
  })  : _publicDio = publicDio,
        _authenticatedDio = authenticatedDio;

  final Dio _publicDio;
  final Dio _authenticatedDio;

  Future<AuthUser> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _publicDio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'display_name': displayName,
          'email': email,
          'password': password,
        },
        options: Options(extra: {
          'requiresAuth': false,
          'skipAuthRefresh': true,
        }),
      );

      return AuthUser.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException(
        message: _extractMessage(error, fallback: 'Unable to create your account right now.'),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _publicDio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(extra: {
          'requiresAuth': false,
          'skipAuthRefresh': true,
        }),
      );

      return AuthTokens.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException(
        message: _extractMessage(error, fallback: 'Incorrect email or password.'),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    try {
      final response = await _publicDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(extra: {
          'requiresAuth': false,
          'skipAuthRefresh': true,
        }),
      );

      return AuthTokens.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException(
        message: _extractMessage(error, fallback: 'Your session expired. Please sign in again.'),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<AuthUser> getCurrentUser() async {
    try {
      final response = await _authenticatedDio.get<Map<String, dynamic>>('/auth/me');
      return AuthUser.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException(
        message: _extractMessage(error, fallback: 'Unable to restore your session.'),
        statusCode: error.response?.statusCode,
      );
    }
  }

  String _extractMessage(
    DioException error, {
    required String fallback,
  }) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }

    return fallback;
  }
}
