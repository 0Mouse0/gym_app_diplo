import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/providers/members_controller.dart';
import '../../../membership_types/domain/entities/membership_type.dart';
import '../../../membership_types/presentation/providers/membership_types_controller.dart';
import '../../domain/entities/membership.dart';
import '../providers/memberships_controller.dart';

/// Formulario de alta/edición de una membresía.
///
/// La fecha de fin NUNCA se escribe a mano: se recalcula siempre a
/// partir de la fecha de inicio + la duración del tipo elegido
/// (`Membership.fromTypeSelection`, en el dominio). Si el gimnasio
/// quiere renovar una membresía, se crea una fila nueva — así queda
/// historial, que después alimenta los reportes.
class MembershipFormScreen extends ConsumerStatefulWidget {
  final Membership? membership;

  const MembershipFormScreen({super.key, this.membership});

  bool get isEditing => membership != null;

  @override
  ConsumerState<MembershipFormScreen> createState() => _MembershipFormScreenState();
}

class _MembershipFormScreenState extends ConsumerState<MembershipFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedMemberId;
  String? _selectedTypeId;
  DateTime _startDate = DateTime.now();
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final membership = widget.membership;
    _selectedMemberId = membership?.memberId;
    _selectedTypeId = membership?.membershipTypeId;
    _startDate = membership?.startDate ?? DateTime.now();
    _isActive = membership?.isActive ?? true;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  MembershipType? _findSelectedType(List<MembershipType> types) {
    if (_selectedTypeId == null) return null;
    for (final type in types) {
      if (type.id == _selectedTypeId) return type;
    }
    return null;
  }

  /// Miembros seleccionables: solo activos, más el miembro ya asignado
  /// si se está editando una membresía de alguien que hoy está
  /// inactivo (para no romper el dropdown con un valor "fantasma").
  List<Member> _selectableMembers(List<Member> allMembers) {
    final active = allMembers.where((m) => m.isActive).toList();
    if (widget.membership == null) return active;

    final alreadyIncluded = active.any((m) => m.id == widget.membership!.memberId);
    if (alreadyIncluded) return active;

    for (final m in allMembers) {
      if (m.id == widget.membership!.memberId) {
        return [...active, m];
      }
    }
    return active;
  }

  Future<void> _handleSubmit(MembershipType? selectedType) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _selectedMemberId == null || selectedType == null) {
      if (_selectedMemberId == null || selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Elige un miembro y un tipo de membresía.')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    final controller = ref.read(membershipsControllerProvider.notifier);

    final draft = widget.isEditing
        ? widget.membership!.copyWith(
            memberId: _selectedMemberId,
            membershipTypeId: selectedType.id,
            startDate: _startDate,
            endDate: _startDate.add(Duration(days: selectedType.durationDays)),
            isActive: _isActive,
          )
        : Membership.fromTypeSelection(
            memberId: _selectedMemberId!,
            membershipTypeId: selectedType.id,
            typeDurationDays: selectedType.durationDays,
            startDate: _startDate,
          ).copyWith(isActive: _isActive);

    final success = widget.isEditing
        ? await controller.updateMembership(draft)
        : await controller.createMembership(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      final errorMessage = ref.read(membershipsControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'No se pudo guardar la membresía.')),
      );
      controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    final membersState = ref.watch(membersControllerProvider);
    final typesState = ref.watch(membershipTypesControllerProvider);
    final selectableMembers = _selectableMembers(membersState.members);
    final selectedType = _findSelectedType(typesState.types);
    final projectedEndDate =
        selectedType == null ? null : _startDate.add(Duration(days: selectedType.durationDays));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar membresía' : 'Nueva membresía'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedMemberId,
              decoration: const InputDecoration(labelText: 'Miembro *'),
              items: selectableMembers
                  .map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.isActive ? m.displayNameLastFirst : '${m.displayNameLastFirst} (inactivo)'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedMemberId = value),
              validator: (value) => value == null ? 'Elige un miembro' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Solo se listan miembros activos (salvo el ya asignado, si estás editando).',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _selectedTypeId,
              decoration: const InputDecoration(labelText: 'Tipo de membresía *'),
              items: typesState.types
                  .map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text('${t.name} (${t.durationDays} días · \$${t.price.toStringAsFixed(2)})'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedTypeId = value),
              validator: (value) => value == null ? 'Elegí un tipo de membresía' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickStartDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha de inicio *'),
                child: Text(dateFormat.format(_startDate), style: theme.textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Fecha de fin (calculada)'),
              child: Text(
                projectedEndDate == null ? 'Elegí un tipo de membresía primero' : dateFormat.format(projectedEndDate),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Membresía activa', style: theme.textTheme.titleMedium),
              subtitle: Text(
                'Desactivala si el gimnasio quiere anularla manualmente antes de que venza por fecha.',
                style: theme.textTheme.bodySmall,
              ),
              value: _isActive,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isSaving ? null : () => _handleSubmit(selectedType),
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
