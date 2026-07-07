import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../reports/presentation/screens/reports_home_screen.dart';
import '../providers/connection_status.dart';
import '../providers/connection_status_provider.dart';
import '../widgets/app_drawer.dart';

/// Pantalla principal: estado de conexión + acceso rápido a
/// Reportes. El resto de las secciones (Miembros, Membresías, Pagos,
/// Clases, Inscripciones) viven en el Drawer (ver [AppDrawer]).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connection = ref.watch(connectionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panel principal')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado de conexión', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            _ConnectionCard(connection: connection),
            const SizedBox(height: AppSpacing.xl),
            Text('Accesos rápidos', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _ReportsQuickAccessCard(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Para Miembros, Membresías, Pagos, Clases e Inscripciones, '
              'abrí el menú (☰) arriba a la izquierda.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsQuickAccessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: AppColors.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReportsHomeScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.bar_chart_outlined, color: AppColors.textOnPrimary, size: 36),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reportes',
                      style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textOnPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Membresías por vencer, ingresos y ocupación de clases.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textOnPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends ConsumerWidget {
  final ConnectionStatus connection;

  const _ConnectionCard({required this.connection});

  Color _dotColor() {
    switch (connection.state) {
      case AppConnectionState.checking:
        return AppColors.warning;
      case AppConnectionState.connected:
        return AppColors.success;
      case AppConnectionState.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: _dotColor(), shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(connection.message, style: theme.textTheme.bodyMedium),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reintentar',
              onPressed: () =>
                  ref.read(connectionStatusProvider.notifier).checkConnection(),
            ),
          ],
        ),
      ),
    );
  }
}
