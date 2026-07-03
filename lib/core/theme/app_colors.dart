import 'package:flutter/material.dart';

/// Paleta de colores única de la aplicación.
///
/// Regla del proyecto: ningún widget define un Color(...) suelto.
/// Todo color usado en la UI debe salir de esta clase o del
/// ColorScheme construido a partir de ella en [AppTheme].
class AppColors {
  AppColors._();

  // Marca
  static const Color primary = Color(0xFF2A3EB1);
  static const Color primaryDark = Color(0xFF1B2680);
  static const Color primaryLight = Color(0xFF5C6FE0);

  // Acento (energía / llamadas a la acción)
  static const Color accent = Color(0xFFFF6B35);

  // Semánticos
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Neutros / superficie
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E4E9);

  // Texto
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}
