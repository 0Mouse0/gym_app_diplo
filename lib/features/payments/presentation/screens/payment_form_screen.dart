import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../memberships/domain/entities/membership_details.dart';
import '../../../memberships/presentation/providers/memberships_controller.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/payments_controller.dart';

/// Formulario de alta/edición de un pago.
///
/// Al elegir una membresía, se sugiere el monto según el precio de
/// su tipo (editable) — así el operador no tiene que acordarse el
/// precio de memoria, pero puede ajustar si corresponde (descuento,
/// pago parcial, etc.).
class PaymentFormScreen extends ConsumerStatefulWidget {
  final Payment? payment;

  const PaymentFormScreen({super.key, this.payment});

  bool get isEditing => payment != null;

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  String? _selectedMembershipId;
  DateTime _paymentDate = DateTime.now();
  PaymentMethod _method = PaymentMethod.cash;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final payment = widget.payment;
    _selectedMembershipId = payment?.membershipId;
    _amountController = TextEditingController(
      text: payment == null ? '' : payment.amount.toStringAsFixed(2),
    );
    _notesController = TextEditingController(text: payment?.notes ?? '');
    _paymentDate = payment?.paymentDate ?? DateTime.now();
    _method = payment?.method ?? PaymentMethod.cash;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  MembershipDetails? _findMembership(List<MembershipDetails> memberships, String? id) {
    if (id == null) return null;
    for (final m in memberships) {
      if (m.membership.id == id) return m;
    }
    return null;
  }

  void _onMembershipSelected(String? membershipId, List<MembershipDetails> memberships) {
    setState(() {
      _selectedMembershipId = membershipId;
      // Solo pre-completamos el monto si el campo está vacío o si
      // todavía no se tocó, para no pisar un valor que el usuario ya
      // haya escrito a mano.
      if (!widget.isEditing && _amountController.text.trim().isEmpty) {
        final selected = _findMembership(memberships, membershipId);
        if (selected != null) {
          _amountController.text = selected.membershipPrice.toStringAsFixed(2);
        }
      }
    });
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _selectedMembershipId == null) {
      if (_selectedMembershipId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Elegí a qué membresía corresponde el pago.')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    final controller = ref.read(paymentsControllerProvider.notifier);
    final amount = double.parse(_amountController.text.trim().replaceAll(',', '.'));
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    final draft = widget.isEditing
        ? widget.payment!.copyWith(
            membershipId: _selectedMembershipId,
            amount: amount,
            paymentDate: _paymentDate,
            method: _method,
            notes: notes,
          )
        : Payment.draft(
            membershipId: _selectedMembershipId!,
            amount: amount,
            paymentDate: _paymentDate,
            method: _method,
            notes: notes,
          );

    final success = widget.isEditing
        ? await controller.updatePayment(draft)
        : await controller.createPayment(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      final errorMessage = ref.read(paymentsControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'No se pudo guardar el pago.')),
      );
      controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final membershipsState = ref.watch(membershipsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Editar pago' : 'Nuevo pago')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedMembershipId,
              decoration: const InputDecoration(labelText: 'Membresía *'),
              isExpanded: true,
              items: membershipsState.memberships
                  .map((d) => DropdownMenuItem(
                        value: d.membership.id,
                        child: Text(
                          '${d.memberFullName} · ${d.membershipTypeName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (value) => _onMembershipSelected(value, membershipsState.memberships),
              validator: (value) => value == null ? 'Elegí una membresía' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Monto *', prefixText: '\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => Validators.positiveDecimal(v, 'El monto'),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickPaymentDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha de pago *'),
                child: Text(dateFormat.format(_paymentDate), style: theme.textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Método de pago *'),
              items: PaymentMethod.values
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                  .toList(),
              onChanged: (value) => setState(() => _method = value ?? _method),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notas (opcional)'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isSaving ? null : _handleSubmit,
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
