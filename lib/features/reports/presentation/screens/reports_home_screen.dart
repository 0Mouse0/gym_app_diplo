import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'class_occupancy_report_screen.dart';
import 'expiring_memberships_report_screen.dart';
import 'revenue_report_screen.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _ReportCard(
            icon: Icons.event_busy_outlined,
            title: 'Membresías por vencer',
            subtitle: 'Miembros con la membresía por vencer en los próximos días.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpiringMembershipsReportScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ReportCard(
            icon: Icons.attach_money_outlined,
            title: 'Ingresos por período',
            subtitle: 'Total de pagos por mes, o para un rango de fechas personalizado.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RevenueReportScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ReportCard(
            icon: Icons.groups_outlined,
            title: 'Ocupación de clases',
            subtitle: 'Inscritos vs. cupo de cada clase.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClassOccupancyReportScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary, size: 32),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
