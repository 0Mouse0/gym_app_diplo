import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../classes/presentation/providers/classes_controller.dart';
import '../../../members/presentation/providers/members_controller.dart';
import '../providers/enrollments_controller.dart';

/// Formulario de inscripción. Solo alta: cancelar una inscripción es
/// borrarla (ver EnrollmentsListScreen), no tiene un "editar" propio.
class EnrollmentFormScreen extends ConsumerStatefulWidget {
  const EnrollmentFormScreen({super.key});

  @override
  ConsumerState<EnrollmentFormScreen> createState() => _EnrollmentFormScreenState();
}

class _EnrollmentFormScreenState extends ConsumerState<EnrollmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMemberId;
  String? _selectedClassId;
  bool _isSaving = false;

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);
    final controller = ref.read(enrollmentsControllerProvider.notifier);
    final success = await controller.enroll(
      memberId: _selectedMemberId!,
      classId: _selectedClassId!,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      final errorMessage = ref.read(enrollmentsControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'No se pudo registrar la inscripción.')),
      );
      controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');

    final membersState = ref.watch(membersControllerProvider);
    final classesState = ref.watch(classesControllerProvider);
    final enrollmentsState = ref.watch(enrollmentsControllerProvider);

    final activeMembers = membersState.members.where((m) => m.isActive).toList();
    final upcomingClasses = classesState.classes.where((c) => !c.isPast).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva inscripción')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedMemberId,
              decoration: const InputDecoration(labelText: 'Miembro *'),
              items: activeMembers
                  .map((m) => DropdownMenuItem(value: m.id, child: Text(m.displayNameLastFirst)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedMemberId = value),
              validator: (value) => value == null ? 'Elige un miembro' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Solo se listan miembros activos. Además, el miembro tiene '
              'que tener una membresía vigente para poder inscribirse.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _selectedClassId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Clase *'),
              items: upcomingClasses.map((c) {
                final enrolled = enrollmentsState.countForClass(c.id);
                final isFull = enrolled >= c.capacity;
                return DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    '${c.name} · ${dateFormat.format(c.scheduledAt)} · '
                    '$enrolled/${c.capacity}${isFull ? ' (SIN CUPO)' : ''}',
                    overflow: TextOverflow.ellipsis,
                    style: isFull ? const TextStyle(color: AppColors.error) : null,
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedClassId = value),
              validator: (value) => value == null ? 'Elige una clase' : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Solo se listan clases que todavía no ocurrieron. Si una '
              'clase dice "SIN CUPO", igual la podés elegir para ver el '
              'mensaje de rechazo, pero no se va a poder guardar.',
              style: theme.textTheme.bodySmall,
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
                  : const Text('Inscribir'),
            ),
          ],
        ),
      ),
    );
  }
}
