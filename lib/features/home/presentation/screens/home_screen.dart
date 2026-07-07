import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../classes/presentation/screens/classes_list_screen.dart';
import '../../../enrollments/presentation/screens/enrollments_list_screen.dart';
import '../../../members/presentation/screens/members_list_screen.dart';
import '../../../membership_types/presentation/screens/membership_types_list_screen.dart';
import '../../../memberships/presentation/screens/memberships_list_screen.dart';
import '../../../payments/presentation/screens/payments_list_screen.dart';
import '../../../reports/presentation/screens/reports_home_screen.dart';
import '../providers/connection_status.dart';
import '../providers/connection_status_provider.dart';

/// Pantalla temporal de la Parte 0. Sirve para verificar visualmente
/// que el tema está bien centralizado y que la conexión a Supabase
/// funciona. Será reemplazada por el dashboard real más adelante.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connection = ref.watch(connectionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gimnasio · Setup base')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parte 0: tema + conexión', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Si ves esta pantalla con estilos y el estado de conexión '
              'de abajo, el setup base está funcionando.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ConnectionCard(connection: connection),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MembersListScreen()),
              ),
              icon: const Icon(Icons.people_outline),
              label: const Text('Ir a Miembros'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MembershipTypesListScreen()),
              ),
              icon: const Icon(Icons.card_membership_outlined),
              label: const Text('Ir a Tipos de Membresía'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MembershipsListScreen()),
              ),
              icon: const Icon(Icons.assignment_ind_outlined),
              label: const Text('Ir a Membresías'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaymentsListScreen()),
              ),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Ir a Pagos'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ClassesListScreen()),
              ),
              icon: const Icon(Icons.fitness_center_outlined),
              label: const Text('Ir a Clases'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EnrollmentsListScreen()),
              ),
              icon: const Icon(Icons.how_to_reg_outlined),
              label: const Text('Ir a Inscripciones'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsHomeScreen()),
              ),
              icon: const Icon(Icons.bar_chart_outlined),
              label: const Text('Ir a Reportes'),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Vista previa del tema', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Acción primaria')),
                OutlinedButton(onPressed: () {}, child: const Text('Secundaria')),
                TextButton(onPressed: () {}, child: const Text('Texto')),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Ejemplo de campo de formulario',
                hintText: 'Se usará en los CRUDs',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Título mediano', style: theme.textTheme.titleMedium),
            Text('Texto de cuerpo estándar (bodyMedium).', style: theme.textTheme.bodyMedium),
            Text('Texto pequeño / auxiliar (bodySmall).', style: theme.textTheme.bodySmall),
          ],
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
