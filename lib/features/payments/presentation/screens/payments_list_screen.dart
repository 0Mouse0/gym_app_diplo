import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/payment_details.dart';
import '../providers/payments_controller.dart';
import 'payment_form_screen.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PaymentDetails> _applyFilter(List<PaymentDetails> payments) {
    if (_query.trim().isEmpty) return payments;
    final query = _query.trim().toLowerCase();
    return payments
        .where((p) =>
            p.memberFullName.toLowerCase().contains(query) ||
            p.membershipTypeName.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _confirmDelete(BuildContext context, PaymentDetails details) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar pago'),
        content: Text(
          '¿Seguro que querés eliminar el pago de "${details.memberFullName}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(paymentsControllerProvider.notifier).deletePayment(details.payment.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(paymentsControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final filteredPayments = _applyFilter(state.payments);
    final filteredTotal = filteredPayments.fold(0.0, (sum, p) => sum + p.payment.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Pagos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaymentFormScreen()),
        ),
        tooltip: 'Nuevo pago',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(paymentsControllerProvider.notifier).loadPayments(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por miembro o tipo',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _query.trim().isEmpty ? 'Total registrado' : 'Total (filtrado)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    currencyFormat.format(filteredTotal),
                    style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.errorMessage != null)
              Container(
                width: double.infinity,
                color: AppColors.error.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ),
            Expanded(
              child: filteredPayments.isEmpty && !state.isLoading
                  ? Center(
                      child: Text(
                        state.payments.isEmpty
                            ? 'Todavía no hay pagos.\nTocá + para registrar el primero.'
                            : 'No hay pagos que coincidan con la búsqueda.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filteredPayments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final details = filteredPayments[index];
                        final payment = details.payment;

                        return Card(
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PaymentFormScreen(payment: payment),
                              ),
                            ),
                            title: Text(details.memberFullName, style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              '${details.membershipTypeName} · ${payment.method.label} · '
                              '${dateFormat.format(payment.paymentDate)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currencyFormat.format(payment.amount),
                                  style: theme.textTheme.titleMedium?.copyWith(color: AppColors.success),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () => _confirmDelete(context, details),
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
      ),
    );
  }
}
