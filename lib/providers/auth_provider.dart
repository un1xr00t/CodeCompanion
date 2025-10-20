import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

// Auth State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    _checkAuthStatus();
  }

  // Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isAuth = await _authRepository.isAuthenticated();
      
      if (isAuth) {
        final user = await _authRepository.getCachedUser();
        final token = await _authRepository.getAccessToken();
        
        if (user != null && token != null) {
          // Verify token is still valid by fetching current user
          try {
            final currentUser = await _authRepository.getCurrentUser(token);
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              user: currentUser,
            );
          } catch (e) {
            // Token invalid, logout
            await logout();
          }
        } else {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: false,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Get authorization URL
  String getAuthorizationUrl() {
    return _authRepository.getAuthorizationUrl();
  }

  // Handle OAuth callback with code
  Future<void> handleAuthCallback(String code) async {
    debugPrint('📝 [AuthProvider] Starting handleAuthCallback with code: ${code.substring(0, 8)}...');
    debugPrint('📝 [AuthProvider] Current state - isAuth: ${state.isAuthenticated}, isLoading: ${state.isLoading}');
    
    state = state.copyWith(isLoading: true, error: null);
    debugPrint('📝 [AuthProvider] Set isLoading to true');
    
    try {
      debugPrint('🔄 [AuthProvider] Exchanging code for token...');
      final token = await _authRepository.exchangeCodeForToken(code);
      debugPrint('✅ [AuthProvider] Got token: ${token.substring(0, 10)}...');
      
      debugPrint('👤 [AuthProvider] Getting user info...');
      final user = await _authRepository.getCurrentUser(token);
      debugPrint('✅ [AuthProvider] Got user: ${user.login}');
      
      debugPrint('💾 [AuthProvider] Updating state to authenticated...');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
      debugPrint('✅ [AuthProvider] State updated successfully!');
      debugPrint('📊 [AuthProvider] Final state - isAuth: ${state.isAuthenticated}, isLoading: ${state.isLoading}, user: ${state.user?.login}');
    } catch (e, stackTrace) {
      debugPrint('❌ [AuthProvider] Error in handleAuthCallback: $e');
      debugPrint('❌ [AuthProvider] Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      final token = await _authRepository.getAccessToken();
      if (token != null) {
        final user = await _authRepository.getCurrentUser(token);
        state = state.copyWith(user: user);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});