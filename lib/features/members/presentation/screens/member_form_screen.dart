import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/member.dart';
import '../providers/members_controller.dart';

/// Formulario de alta/edición de un miembro. Si [member] es null,
/// crea uno nuevo; si viene con datos, edita ese miembro.
///
/// Toda la validación se apoya en [Validators] (core/utils), nunca
/// hay una expresión regular o un `if (value.isEmpty)` suelto acá.
class MemberFormScreen extends ConsumerStatefulWidget {
  final Member? member;

  const MemberFormScreen({super.key, this.member});

  bool get isEditing => member != null;

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _documentIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  DateTime? _birthDate;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _firstNameController = TextEditingController(text: member?.firstName ?? '');
    _lastNameController = TextEditingController(text: member?.lastName ?? '');
    _documentIdController = TextEditingController(text: member?.documentId ?? '');
    _emailController = TextEditingController(text: member?.email ?? '');
    _phoneController = TextEditingController(text: member?.phone ?? '');
    _addressController = TextEditingController(text: member?.address ?? '');
    _birthDate = member?.birthDate;
    _isActive = member?.isActive ?? true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _documentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);

    final controller = ref.read(membersControllerProvider.notifier);
    final baseMember = widget.member ??
        Member.draft(firstName: '', lastName: '', documentId: '');

    final memberToSave = baseMember.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      documentId: _documentIdController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      birthDate: _birthDate,
      isActive: _isActive,
    );

    final success = widget.isEditing
        ? await controller.updateMember(memberToSave)
        : await controller.createMember(memberToSave);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      final errorMessage = ref.read(membersControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'No se pudo guardar el miembro.')),
      );
      controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar miembro' : 'Nuevo miembro'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Nombres *'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.required(v, 'El nombre'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Apellidos *'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.required(v, 'El apellido'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _documentIdController,
              decoration: const InputDecoration(labelText: 'Documento (CI/DNI) *'),
              validator: (v) => Validators.required(v, 'El documento'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.optionalEmail,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              validator: Validators.optionalPhone,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
                child: Text(
                  _birthDate == null ? 'Sin definir' : dateFormat.format(_birthDate!),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Miembro activo', style: theme.textTheme.titleMedium),
              subtitle: Text(
                'Si lo desactivás, queda deshabilitado en el sistema (no se borra).',
                style: theme.textTheme.bodySmall,
              ),
              value: _isActive,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _isActive = value),
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
