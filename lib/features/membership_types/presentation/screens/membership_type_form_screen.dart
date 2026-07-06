import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/membership_type.dart';
import '../providers/membership_types_controller.dart';

class MembershipTypeFormScreen extends ConsumerStatefulWidget {
  final MembershipType? type;

  const MembershipTypeFormScreen({super.key, this.type});

  bool get isEditing => type != null;

  @override
  ConsumerState<MembershipTypeFormScreen> createState() => _MembershipTypeFormScreenState();
}

class _MembershipTypeFormScreenState extends ConsumerState<MembershipTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final type = widget.type;
    _nameController = TextEditingController(text: type?.name ?? '');
    _durationController = TextEditingController(text: type?.durationDays.toString() ?? '');
    _priceController = TextEditingController(text: type?.price.toStringAsFixed(2) ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);
    final controller = ref.read(membershipTypesControllerProvider.notifier);

    final draft = (widget.type ?? MembershipType.draft(name: '', durationDays: 1, price: 0)).copyWith(
      name: _nameController.text.trim(),
      durationDays: int.parse(_durationController.text.trim()),
      price: double.parse(_priceController.text.trim().replaceAll(',', '.')),
    );

    final success = widget.isEditing
        ? await controller.updateType(draft)
        : await controller.createType(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      final errorMessage = ref.read(membershipTypesControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'No se pudo guardar el tipo de membresía.')),
      );
      controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar tipo de membresía' : 'Nuevo tipo de membresía'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del plan *', hintText: 'Ej: Mensual'),
              validator: (v) => Validators.required(v, 'El nombre'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duración en días *', hintText: 'Ej: 30'),
              keyboardType: TextInputType.number,
              validator: (v) => Validators.positiveInteger(v, 'La duración'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Precio *', hintText: 'Ej: 25.00'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => Validators.positiveDecimal(v, 'El precio'),
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
