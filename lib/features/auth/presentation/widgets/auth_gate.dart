import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../providers/app_auth_state.dart';
import '../providers/auth_controller.dart';
import '../screens/login_screen.dart';

/// Punto de entrada real de la app (ver `app.dart`): mientras se
/// verifica si ya hay una sesión guardada muestra un loader, y
/// después decide entre [LoginScreen] y [HomeScreen] — y se
/// actualiza solo si la sesión cambia (login, logout, expiración).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    switch (authState.status) {
      case AppAuthStatus.checking:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AppAuthStatus.unauthenticated:
        return const LoginScreen();
      case AppAuthStatus.authenticated:
        return const HomeScreen();
    }
  }
}
