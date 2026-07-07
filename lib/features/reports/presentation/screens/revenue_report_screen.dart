import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../payments/presentation/providers/payments_controller.dart';
import '../../domain/revenue_report.dart';

class RevenueReportScreen extends ConsumerStatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  ConsumerState<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends ConsumerState<RevenueReportScreen> {
  DateTimeRange? _customRange;

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: _customRange,
    );
    if (picked != null) setState(() => _customRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final state = ref.watch(paymentsControllerProvider);
    final monthly = RevenueReport.groupByMonth(state.payments);
    final maxTotal = monthly.isEmpty ? 1.0 : monthly.map((m) => m.total).reduce((a, b) => a > b ? a : b);

    final customTotal = _customRange == null
        ? null
        : RevenueReport.totalForRange(state.payments, _customRange!.start, _customRange!.end);

    return Scaffold(
      appBar: AppBar(title: const Text('Ingresos por período')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Período personalizado', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _pickCustomRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _customRange == null
                          ? 'Elegir rango de fechas'
                          : '${dateFormat.format(_customRange!.start)} — ${dateFormat.format(_customRange!.end)}',
                    ),
                  ),
                  if (customTotal != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Total en el período: ${currencyFormat.format(customTotal)}',
                      style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Por mes', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (state.isLoading) const LinearProgressIndicator(),
          if (monthly.isEmpty && !state.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text('Todavía no hay pagos registrados.', style: theme.textTheme.bodyMedium),
            ),
          ...monthly.map((m) {
            final barFraction = maxTotal == 0 ? 0.0 : m.total / maxTotal;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.label, style: theme.textTheme.bodyMedium),
                      Text(
                        '${currencyFormat.format(m.total)} (${m.paymentCount} pago${m.paymentCount == 1 ? '' : 's'})',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: 10,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Container(
                            height: 10,
                            width: constraints.maxWidth * barFraction,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
