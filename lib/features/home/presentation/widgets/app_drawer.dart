import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../classes/presentation/screens/classes_list_screen.dart';
import '../../../enrollments/presentation/screens/enrollments_list_screen.dart';
import '../../../members/presentation/screens/members_list_screen.dart';
import '../../../membership_types/presentation/screens/membership_types_list_screen.dart';
import '../../../memberships/presentation/screens/memberships_list_screen.dart';
import '../../../payments/presentation/screens/payments_list_screen.dart';
import '../../../reports/presentation/screens/reports_home_screen.dart';

/// Menú lateral con acceso a todas las secciones de gestión de datos.
/// Los Reportes también se destacan como acceso rápido en el home,
/// pero se repiten acá para que el drawer sea el índice completo de
/// la app.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
              child: Text(
                'Gimnasio',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textOnPrimary),
              ),
            ),
            _DrawerItem(
              icon: Icons.people_outline,
              label: 'Miembros',
              builder: (_) => const MembersListScreen(),
            ),
            _DrawerItem(
              icon: Icons.card_membership_outlined,
              label: 'Tipos de Membresía',
              builder: (_) => const MembershipTypesListScreen(),
            ),
            _DrawerItem(
              icon: Icons.assignment_ind_outlined,
              label: 'Membresías',
              builder: (_) => const MembershipsListScreen(),
            ),
            _DrawerItem(
              icon: Icons.payments_outlined,
              label: 'Pagos',
              builder: (_) => const PaymentsListScreen(),
            ),
            _DrawerItem(
              icon: Icons.fitness_center_outlined,
              label: 'Clases',
              builder: (_) => const ClassesListScreen(),
            ),
            _DrawerItem(
              icon: Icons.how_to_reg_outlined,
              label: 'Inscripciones',
              builder: (_) => const EnrollmentsListScreen(),
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.bar_chart_outlined,
              label: 'Reportes',
              builder: (_) => const ReportsHomeScreen(),
            ),
            const Divider(height: 1),
            Consumer(
              builder: (context, ref, _) => ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  'Cerrar sesión',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  const _DrawerItem({required this.icon, required this.label, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.bodyLarge),
      onTap: () {
        Navigator.of(context).pop(); // cierra el drawer primero
        Navigator.of(context).push(MaterialPageRoute(builder: builder));
      },
    );
  }
}
