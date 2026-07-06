import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/gym_class.dart';
import '../providers/classes_controller.dart';
import 'class_form_screen.dart';

class ClassesListScreen extends ConsumerStatefulWidget {
  const ClassesListScreen({super.key});

  @override
  ConsumerState<ClassesListScreen> createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends ConsumerState<ClassesListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GymClass> _applyFilter(List<GymClass> classes) {
    if (_query.trim().isEmpty) return classes;
    final query = _query.trim().toLowerCase();
    return classes
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            (c.instructor ?? '').toLowerCase().contains(query))
        .toList();
  }

  Future<void> _confirmDelete(BuildContext context, GymClass gymClass) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar clase'),
        content: Text('¿Seguro que querés eliminar "${gymClass.name}"? Esta acción no se puede deshacer.'),
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
      ref.read(classesControllerProvider.notifier).deleteClass(gymClass.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(classesControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');
    final filteredClasses = _applyFilter(state.classes);

    return Scaffold(
      appBar: AppBar(title: const Text('Clases')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClassFormScreen()),
        ),
        tooltip: 'Nueva clase',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(classesControllerProvider.notifier).loadClasses(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por nombre o instructor/a',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
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
              child: filteredClasses.isEmpty && !state.isLoading
                  ? Center(
                      child: Text(
                        state.classes.isEmpty
                            ? 'Todavía no hay clases.\nToca + para crear la primera.'
                            : 'No hay clases que coincidan con la búsqueda.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filteredClasses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final gymClass = filteredClasses[index];

                        return Card(
                          child: Opacity(
                            opacity: gymClass.isPast ? 0.55 : 1,
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => ClassFormScreen(gymClass: gymClass)),
                              ),
                              title: Text(gymClass.name, style: theme.textTheme.titleMedium),
                              subtitle: Text(
                                '${gymClass.instructor ?? 'Sin instructor asignado'} · '
                                '${dateFormat.format(gymClass.scheduledAt)} · ${gymClass.durationMinutes} min'
                                '${gymClass.isPast ? ' · Ya pasó' : ''}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Cupo: ${gymClass.capacity}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () => _confirmDelete(context, gymClass),
                                  ),
                                ],
                              ),
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
