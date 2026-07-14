/// Se llama `AppAuthStatus`/`AppAuthState` (no `AuthState`) a propósito:
/// `package:supabase_flutter` ya define una clase `AuthState` (la que
/// llega por `onAuthStateChange`), y usar el mismo nombre generaría
/// el mismo problema de ambigüedad que ya nos pasó una vez con
/// `ConnectionState` de Flutter.
enum AppAuthStatus { checking, authenticated, unauthenticated }

class AppAuthState {
  final AppAuthStatus status;
  final bool isSubmitting;
  final String? errorMessage;

  const AppAuthState({
    required this.status,
    this.isSubmitting = false,
    this.errorMessage,
  });

  const AppAuthState.checking()
      : status = AppAuthStatus.checking,
        isSubmitting = false,
        errorMessage = null;

  AppAuthState copyWith({
    AppAuthStatus? status,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
