import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/auth_repository.dart';
import '../../data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider), ref.watch(secureStorageProvider));
});

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isSubmitting;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.isSubmitting = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref, this._repository) : super(const AuthState()) {
    _restoreSession();
    _ref.read(apiClientProvider).unauthorizedStream.listen((_) => _forceLogout());
  }

  final Ref _ref;
  final AuthRepository _repository;

  Future<void> _restoreSession() async {
    final storage = _ref.read(secureStorageProvider);
    final hasSession = await storage.hasSession();
    if (!hasSession) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    // We don't have a "me" endpoint in the backend surface we've mapped, so
    // a restored session trusts the locally cached role/id rather than
    // re-fetching the profile on every cold start.
    final roleId = await storage.getRoleId();
    final userId = await storage.getUserId();
    if (roleId == null || userId == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: UserModel(id: userId, fullName: '', roleId: roleId),
    );

    // full_name isn't persisted locally - refresh it in the background so
    // the dashboard's "Welcome, {name}" doesn't stay blank until the user
    // navigates somewhere that happens to refetch it.
    unawaited(_refreshProfile());
  }

  Future<void> _refreshProfile() async {
    try {
      final user = await _repository.fetchMe();
      if (state.status == AuthStatus.authenticated) {
        state = state.copyWith(user: user);
      }
    } catch (_) {
      // Best-effort only - the cached id/role already let the user in.
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final result = await _repository.login(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        isSubmitting: false,
      );
      unawaited(_ref.read(fcmServiceProvider).registerToken(result.user.id));
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // The repository already clears the local session in a `finally`
      // block even if the network call fails - don't leave the user stuck
      // looking logged-in just because the backend call errored.
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void _forceLogout() {
    _ref.read(secureStorageProvider).clear();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Session expired. Please log in again.',
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref, ref.watch(authRepositoryProvider));
});
