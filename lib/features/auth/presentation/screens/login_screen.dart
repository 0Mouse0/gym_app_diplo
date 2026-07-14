import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.fitness_center, size: 56, color: AppColors.primary),
                    const SizedBox(height: AppSpacing.md),
                    Text('Gimnasio', style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ingresa con tu cuenta de administrador',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) => Validators.required(v, 'El email'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: (v) => Validators.required(v, 'La contraseña'),
                      onFieldSubmitted: (_) => _handleSubmit(),
                    ),
                    if (authState.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        authState.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: authState.isSubmitting ? null : _handleSubmit,
                      child: authState.isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                            )
                          : const Text('Ingresar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
