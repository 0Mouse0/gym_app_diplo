import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/gym_class.dart';
import '../providers/classes_controller.dart';

class ClassFormScreen extends ConsumerStatefulWidget {
  final GymClass? gymClass;

  const ClassFormScreen({super.key, this.gymClass});

  bool get isEditing => gymClass != null;

  @override
  ConsumerState<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends ConsumerState<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _instructorController;
  late final TextEditingController _durationController;
  late final TextEditingController _capacityController;

  DateTime _scheduledAt = DateTime.now().add(const Duration(days: 1));
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final gymClass = widget.gymClass;
    _nameController = TextEditingController(text: gymClass?.name ?? '');
    _instructorController = TextEditingController(text: gymClass?.instructor ?? '');
    _durationController = TextEditingController(
      text: (gymClass?.durationMinutes ?? 60).toString(),
    );
    _capacityController = TextEditingController(
      text: gymClass?.capacity.toString() ?? '',
    );
    if (gymClass != null) _scheduledAt = gymClass.scheduledAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _durationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduledAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);
    final controller = ref.read(classesControllerProvider.notifier);

    final draft = widget.isEditing
        ? widget.gymClass!.copyWith(
            name: _nameController.text.trim(),
            instructor: _instructorController.text.trim().isEmpty ? null : _instructorController.text.trim(),
            scheduledAt: _scheduledAt,
            durationMinutes: int.parse(_durationController.text.trim()),
            capacity: int.parse(_capacityController.text.trim()),
          )
        : GymClass.draft(
            name: _nameController.text.trim(),
            instructor: _instructorController.text.trim().isEmpty ? null : _instructorController.text.trim(),
            scheduledAt: _scheduledAt,
            durationMinutes: int.parse(_durationController.text.trim()),
            capacity: int.parse(_capacityController.text.trim()),
          );

    final success = widget.isEditing
        ? await controller.updateClass(draft)
        : await controller.createClass(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      final errorMessage = ref.read(classesControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'No se pudo guardar la clase.')),
      );
      controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Editar clase' : 'Nueva clase')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre de la clase *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.required(v, 'El nombre'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _instructorController,
              decoration: const InputDecoration(labelText: 'Instructor/a (opcional)'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickScheduledAt,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha y hora *'),
                child: Text(dateFormat.format(_scheduledAt), style: theme.textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Duración (min) *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.positiveInteger(v, 'La duración'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(labelText: 'Cupo *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.positiveInteger(v, 'El cupo'),
                  ),
                ),
              ],
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
