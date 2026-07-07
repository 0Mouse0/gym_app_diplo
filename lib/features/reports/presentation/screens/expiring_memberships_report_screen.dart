import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../memberships/presentation/providers/memberships_controller.dart';
import '../../domain/expiring_memberships_report.dart';

class ExpiringMembershipsReportScreen extends ConsumerStatefulWidget {
  const ExpiringMembershipsReportScreen({super.key});

  @override
  ConsumerState<ExpiringMembershipsReportScreen> createState() =>
      _ExpiringMembershipsReportScreenState();
}

class _ExpiringMembershipsReportScreenState extends ConsumerState<ExpiringMembershipsReportScreen> {
  int _withinDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final state = ref.watch(membershipsControllerProvider);
    final report = ExpiringMembershipsReport.filter(state.memberships, _withinDays);

    return Scaffold(
      appBar: AppBar(title: const Text('Membresías por vencer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text('Ventana:', style: theme.textTheme.bodyMedium),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    children: [7, 15, 30].map((days) {
                      final selected = days == _withinDays;
                      return ChoiceChip(
                        label: Text('$days días'),
                        selected: selected,
                        onSelected: (_) => setState(() => _withinDays = days),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoading) const LinearProgressIndicator(),
          Expanded(
            child: report.isEmpty
                ? Center(
                    child: Text(
                      'Ninguna membresía vence en los próximos $_withinDays días.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: report.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final details = report[index];
                      final membership = details.membership;
                      final days = membership.daysUntilExpiration;
                      final urgent = days <= 3;

                      return Card(
                        child: ListTile(
                          title: Text(details.memberFullName, style: theme.textTheme.titleMedium),
                          subtitle: Text(
                            '${details.membershipTypeName} · vence el ${dateFormat.format(membership.endDate)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (urgent ? AppColors.error : AppColors.warning).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              days == 0 ? 'Vence hoy' : 'En $days día${days == 1 ? '' : 's'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: urgent ? AppColors.error : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
