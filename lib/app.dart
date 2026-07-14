import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/widgets/auth_gate.dart';

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Gimnasio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}
