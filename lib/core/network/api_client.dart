import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';

import '../../features/auth/domain/entities/auth_tokens.dart';

typedef ReadTokens = Future<AuthTokens?> Function();
typedef SaveTokens = Future<void> Function(AuthTokens tokens);
typedef RefreshTokens = Future<AuthTokens> Function(String refreshToken);
typedef SessionExpired = Future<void> Function();

class ApiClient {
  ApiClient({
    String? baseUrl,
    required ReadTokens readTokens,
    required SaveTokens saveTokens,
    required RefreshTokens refreshTokens,
    required SessionExpired onSessionExpired,
  })  : _readTokens = readTokens,
        _saveTokens = saveTokens,
        _refreshTokens = refreshTokens,
        _onSessionExpired = onSessionExpired,
        publicDio = Dio(_options(baseUrl)),
        dio = Dio(_options(baseUrl)) {
    _configure();
  }

  final Dio publicDio;
  final Dio dio;

  final ReadTokens _readTokens;
  final SaveTokens _saveTokens;
  final RefreshTokens _refreshTokens;
  final SessionExpired _onSessionExpired;

  Completer<AuthTokens>? _refreshCompleter;

  static BaseOptions _options(String? baseUrl) {
    final resolvedBaseUrl = baseUrl ??
        const String.fromEnvironment(
          'LOCKED_API_BASE_URL',
          defaultValue: 'http://127.0.0.1:8000/api/v1',
        );
    final uri = Uri.tryParse(resolvedBaseUrl);

    // if (kReleaseMode &&
    //     uri != null &&
    //     uri.scheme != 'https' &&
    //     uri.host != '127.0.0.1' &&
    //     uri.host != 'localhost') {
    //   throw StateError(
    //     'LOCKED_API_BASE_URL must use HTTPS outside local development.',
    //   );
    // }

    return BaseOptions(
      baseUrl: resolvedBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> probeStartup() async {
    final target = Uri.parse(publicDio.options.baseUrl);

    try {
      final response = await publicDio
          .getUri<dynamic>(
            target,
            options: Options(
              extra: const {
                'requiresAuth': false,
                'skipAuthRefresh': true,
              },
              validateStatus: (_) => true,
            ),
          )
          .timeout(const Duration(seconds: 3));

      debugPrint(
        '[ApiClient] startup probe ${response.statusCode} ${target.toString()}',
      );
    } on TimeoutException {
      debugPrint('[ApiClient] startup probe timeout ${target.toString()}');
    } on DioException catch (error) {
      debugPrint(
        '[ApiClient] startup probe failed ${target.toString()} ${error.message}',
      );
    } catch (error) {
      debugPrint(
        '[ApiClient] startup probe unexpected ${target.toString()} $error',
      );
    }
  }

  void _configure() {
    debugPrint('[ApiClient] baseUrl=${publicDio.options.baseUrl}');

    if (kDebugMode) {
      final logger = LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (object) {
          debugPrint('[ApiClient] ${object.toString()}');
        },
      );

      publicDio.interceptors.add(logger);
      dio.interceptors.add(logger);
    }

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['requiresAuth'] == false) {
            handler.next(options);
            return;
          }

          final tokens = await _readTokens();
          if (tokens != null) {
            options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (_shouldRetryTransient(error)) {
            final response = await _retryRequest(error.requestOptions);
            if (response != null) {
              handler.resolve(response);
              return;
            }
          }

          if (_shouldAttemptRefresh(error)) {
            try {
              final refreshed = await _refreshAccessToken();
              final response = await _retryRequest(
                error.requestOptions,
                overrideToken: refreshed.accessToken,
              );

              if (response != null) {
                handler.resolve(response);
                return;
              }
            } catch (_) {
              await _onSessionExpired();
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetryTransient(DioException error) {
    if (error.requestOptions.extra['retriedNetwork'] == true) {
      return false;
    }

    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout => true,
      _ => false,
    };
  }

  bool _shouldAttemptRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    final requestOptions = error.requestOptions;

    return statusCode == 401 &&
        requestOptions.extra['requiresAuth'] != false &&
        requestOptions.extra['skipAuthRefresh'] != true &&
        requestOptions.extra['retriedAuth'] != true;
  }

  Future<AuthTokens> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<AuthTokens>();
    try {
      final tokens = await _readTokens();
      if (tokens == null) {
        throw StateError('Missing refresh token.');
      }

      final refreshed = await _refreshTokens(tokens.refreshToken);
      await _saveTokens(refreshed);
      _refreshCompleter!.complete(refreshed);
      return refreshed;
    } catch (error) {
      _refreshCompleter!.completeError(error);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>?> _retryRequest(
    RequestOptions requestOptions, {
    String? overrideToken,
  }) async {
    try {
      final headers = Map<String, dynamic>.from(requestOptions.headers);
      if (overrideToken != null) {
        headers['Authorization'] = 'Bearer $overrideToken';
      }

      return await dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        cancelToken: requestOptions.cancelToken,
        options: Options(
          method: requestOptions.method,
          headers: headers,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
          extra: {
            ...requestOptions.extra,
            if (overrideToken != null) 'retriedAuth': true,
            if (overrideToken == null) 'retriedNetwork': true,
          },
        ),
      );
    } on DioException {
      return null;
    }
  }
}
