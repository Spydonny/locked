import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/auth_session_vault.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_api_service.dart';
import '../../domain/entities/auth_snapshot.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthFlowStatus {
  idle,
  bootstrapping,
  submitting,
}

class AuthFlowState {
  const AuthFlowState({
    required this.snapshot,
    this.status = AuthFlowStatus.idle,
    this.errorMessage,
  });

  final AuthSnapshot snapshot;
  final AuthFlowStatus status;
  final String? errorMessage;

  bool get isBootstrapping => status == AuthFlowStatus.bootstrapping;
  bool get isSubmitting => status == AuthFlowStatus.submitting;
  bool get isBusy => isBootstrapping || isSubmitting;

  AuthFlowState copyWith({
    AuthSnapshot? snapshot,
    AuthFlowStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthFlowState(
      snapshot: snapshot ?? this.snapshot,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authSessionVaultProvider = Provider<AuthSessionVault>((ref) {
  final vault = AuthSessionVault(ref.watch(secureStorageServiceProvider));
  ref.onDispose(() {
    vault.dispose();
  });
  return vault;
});

final apiBaseUrlProvider = Provider<String>((ref) {
  return const String.fromEnvironment(
    'LOCKED_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final vault = ref.watch(authSessionVaultProvider);

  late final ApiClient client;
  client = ApiClient(
    baseUrl: ref.watch(apiBaseUrlProvider),
    readTokens: () async => vault.snapshot.tokens,
    saveTokens: vault.saveTokens,
    refreshTokens: (refreshToken) {
      final authApi = AuthApiService(
        publicDio: client.publicDio,
        authenticatedDio: client.dio,
      );
      return authApi.refreshToken(refreshToken);
    },
    onSessionExpired: vault.clear,
  );

  return client;
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApiService(
    publicDio: client.publicDio,
    authenticatedDio: client.dio,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiService: ref.watch(authApiServiceProvider),
    vault: ref.watch(authSessionVaultProvider),
  );
});

class AuthController extends Notifier<AuthFlowState> {
  @override
  AuthFlowState build() {
    return AuthFlowState(snapshot: AuthSnapshot.empty());
  }

  Future<void> initialize() async {
    if (state.snapshot.hydrated) {
      return;
    }

    debugPrint('[AuthController] initialize() start');

    state = state.copyWith(
      status: AuthFlowStatus.bootstrapping,
      clearError: true,
    );

    final repository = ref.read(authRepositoryProvider);
    final vault = ref.read(authSessionVaultProvider);

    try {
      await repository.restoreSession();
    } on ApiException catch (_) {
      // The repository already clears the vault on restore failure.
      debugPrint('[AuthController] restoreSession(): ApiException');
    } catch (error) {
      debugPrint('[AuthController] restoreSession(): unexpected $error');
    } finally {
      state = AuthFlowState(snapshot: vault.snapshot);
      debugPrint(
        '[AuthController] initialize() done hydrated=${state.snapshot.hydrated} authed=${state.snapshot.isAuthenticated}',
      );
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthFlowStatus.submitting,
      clearError: true,
    );

    try {
      await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
      state = AuthFlowState(
        snapshot: ref.read(authSessionVaultProvider).snapshot,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        status: AuthFlowStatus.idle,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthFlowStatus.idle,
        errorMessage: 'Unable to sign you in right now.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthFlowStatus.submitting,
      clearError: true,
    );

    try {
      await ref.read(authRepositoryProvider).register(
            displayName: displayName,
            email: email,
            password: password,
          );
      state = AuthFlowState(
        snapshot: ref.read(authSessionVaultProvider).snapshot,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        status: AuthFlowStatus.idle,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthFlowStatus.idle,
        errorMessage: 'Unable to create your account right now.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: AuthFlowStatus.submitting,
      clearError: true,
    );
    await ref.read(authRepositoryProvider).logout();
    state = AuthFlowState(
      snapshot: ref.read(authSessionVaultProvider).snapshot,
    );
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    state = state.copyWith(clearError: true);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthFlowState>(AuthController.new);

final authBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authControllerProvider.notifier).initialize();
});
