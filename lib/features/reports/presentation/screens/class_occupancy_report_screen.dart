import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../classes/presentation/providers/classes_controller.dart';
import '../../../enrollments/presentation/providers/enrollments_controller.dart';
import '../../domain/class_occupancy_report.dart';

class ClassOccupancyReportScreen extends ConsumerWidget {
  const ClassOccupancyReportScreen({super.key});

  Color _colorFor(double rate) {
    if (rate >= 1) return AppColors.error;
    if (rate >= 0.7) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');
    final classesState = ref.watch(classesControllerProvider);
    final enrollmentsState = ref.watch(enrollmentsControllerProvider);

    final report = ClassOccupancyReport.build(
      classesState.classes,
      enrollmentsState.countForClass,
    );

    final isLoading = classesState.isLoading || enrollmentsState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Ocupación de clases')),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: report.isEmpty
                ? Center(
                    child: Text('Todavía no hay clases cargadas.', style: theme.textTheme.bodyMedium),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: report.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final occupancy = report[index];
                      final gymClass = occupancy.gymClass;
                      final color = _colorFor(occupancy.occupancyRate);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(gymClass.name, style: theme.textTheme.titleMedium),
                                  ),
                                  Text(
                                    '${occupancy.enrolledCount}/${gymClass.capacity}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${gymClass.instructor ?? 'Sin instructor'} · ${dateFormat.format(gymClass.scheduledAt)}'
                                '${gymClass.isPast ? ' · Ya pasó' : ''}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: occupancy.occupancyRate.clamp(0, 1),
                                  minHeight: 10,
                                  backgroundColor: AppColors.border,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                occupancy.isFull
                                    ? 'Cupo completo'
                                    : '${(occupancy.occupancyRate * 100).toStringAsFixed(0)}% ocupado',
                                style: theme.textTheme.bodySmall?.copyWith(color: color),
                              ),
                            ],
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
