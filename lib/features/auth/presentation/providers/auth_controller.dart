import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_providers.dart';
import 'app_auth_state.dart';

// Envuelve `SupabaseClient.auth`: expone el estado de sesión como
// [AppAuthState] y los métodos de login/logout. Es el único lugar
// de la app que conoce la API de Supabase Auth — igual que un
// repositorio, pero para autenticación en vez de datos.
class AuthController extends StateNotifier<AppAuthState> {
  final SupabaseClient _client;
  late final StreamSubscription<dynamic> _subscription;

  AuthController(this._client) : super(const AppAuthState.checking()) {
    final hasSession = _client.auth.currentSession != null;
    state = AppAuthState(
      status: hasSession ? AppAuthStatus.authenticated : AppAuthStatus.unauthenticated,
    );

    // Se actualiza solo ante login, logout, o expiración/renovación
    // de sesión — así la UI reacciona sin que ningún widget tenga
    // que preguntar "¿sigo logueado?" a cada rato.
    _subscription = _client.auth.onAuthStateChange.listen((data) {
      final isAuthenticated = data.session != null;
      state = state.copyWith(
        status: isAuthenticated ? AppAuthStatus.authenticated : AppAuthStatus.unauthenticated,
      );
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      // El listener de onAuthStateChange ya actualiza `status` a
      // authenticated; acá solo apagamos el spinner.
      state = state.copyWith(isSubmitting: false);
    } on AuthException catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Email o contraseña incorrectos.',
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'No se pudo conectar con el servidor.',
      );
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  void clearError() => state = state.copyWith(clearError: true);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AppAuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthController(client);
});
