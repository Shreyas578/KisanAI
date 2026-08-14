import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../repository/auth_repository.dart';

/// State notifier for authentication state
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncLoading()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (!mounted) return; // Prevent state updates if disposed

      final user = await _authRepository.getCurrentUser();
      if (isLoggedIn && user != null) {
        state = AsyncData(AuthState.authenticated(user));
      } else {
        state = const AsyncData(AuthState.unauthenticated());
      }
    } catch (e) {
      state = AsyncError('Failed to check auth status: $e', StackTrace.current);
    }
  }

  /// Login user
  Future<void> login(String phone, String password) async {
    state = const AsyncLoading();
    try {
      final request = LoginRequest(phone: phone, password: password);

      final response = await _authRepository.login(request);
      if (response.success) {
        state = AsyncData(AuthState.authenticated(response.user!));
      } else {
        state = AsyncError(
          response.message ?? 'Login failed',
          StackTrace.current,
        );
      }
    } catch (e) {
      state = AsyncError('Login error: $e', StackTrace.current);
    }
  }

  /// Register new user
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    state = const AsyncLoading();
    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      final response = await _authRepository.register(request);
      if (response.success) {
        state = AsyncData(AuthState.authenticated(response.user!));
      } else {
        state = AsyncError(
          response.message ?? 'Registration failed',
          StackTrace.current,
        );
      }
    } catch (e) {
      state = AsyncError('Registration error: $e', StackTrace.current);
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final success = await _authRepository.logout();
      if (success) {
        state = const AsyncData(AuthState.unauthenticated());
      } else {
        state = AsyncError('Logout failed', StackTrace.current);
      }
    } catch (e) {
      state = AsyncError('Logout error: $e', StackTrace.current);
    }
  }

  /// Refresh authentication token
  Future<void> refreshToken() async {
    final currentStateValue = state.valueOrNull;
    if (currentStateValue == null || !currentStateValue.authenticated) return;

    state = const AsyncLoading();
    try {
      final response = await _authRepository.refreshToken();
      if (response.success) {
        final currentState = state.valueOrNull;
        if (currentState != null && currentState.authenticated) {
          state = AsyncData(AuthState.authenticated(currentState.user!));
        }
      } else {
        // Token refresh failed, force logout
        await logout();
      }
    } catch (e) {
      state = AsyncError('Token refresh failed: $e', StackTrace.current);
    }
  }
}

/// Authentication state
class AuthState {
  final bool authenticated;
  final User? user;

  const AuthState.unauthenticated() : authenticated = false, user = null;

  const AuthState.authenticated(this.user) : authenticated = true;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.authenticated == authenticated &&
        other.user == user;
  }

  @override
  int get hashCode => Object.hash(authenticated, user);
}

/// Provider for auth notifier
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return AuthNotifier(authRepository);
  },
);

/// Provider to get current user (null if not authenticated)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (state) => state.authenticated ? state.user : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (state) => state.authenticated,
    loading: () => false,
    error: (_, __) => false,
  );
});
