import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/enrollment_details.dart';
import '../providers/enrollments_controller.dart';
import 'enrollment_form_screen.dart';

class EnrollmentsListScreen extends ConsumerStatefulWidget {
  const EnrollmentsListScreen({super.key});

  @override
  ConsumerState<EnrollmentsListScreen> createState() => _EnrollmentsListScreenState();
}

class _EnrollmentsListScreenState extends ConsumerState<EnrollmentsListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EnrollmentDetails> _applyFilter(List<EnrollmentDetails> enrollments) {
    if (_query.trim().isEmpty) return enrollments;
    final query = _query.trim().toLowerCase();
    return enrollments
        .where((e) =>
            e.memberFullName.toLowerCase().contains(query) ||
            e.className.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _confirmCancel(BuildContext context, EnrollmentDetails details) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar inscripción'),
        content: Text(
          '¿Seguro que querés cancelar la inscripción de "${details.memberFullName}" '
          'a "${details.className}"? Esto libera un cupo en la clase.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Volver')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar inscripción', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(enrollmentsControllerProvider.notifier).cancelEnrollment(details.enrollment.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(enrollmentsControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy · HH:mm');
    final filtered = _applyFilter(state.enrollments);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscripciones')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EnrollmentFormScreen()),
        ),
        tooltip: 'Nueva inscripción',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(enrollmentsControllerProvider.notifier).loadEnrollments(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por miembro o clase',
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
              child: filtered.isEmpty && !state.isLoading
                  ? Center(
                      child: Text(
                        state.enrollments.isEmpty
                            ? 'Todavía no hay inscripciones.\nTocá + para crear la primera.'
                            : 'No hay inscripciones que coincidan con la búsqueda.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final details = filtered[index];
                        final enrolledCount = state.countForClass(details.enrollment.classId);

                        return Card(
                          child: ListTile(
                            title: Text(details.memberFullName, style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              '${details.className} · ${dateFormat.format(details.classScheduledAt)}\n'
                              'Cupo: $enrolledCount/${details.classCapacity}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                              tooltip: 'Cancelar inscripción',
                              onPressed: () => _confirmCancel(context, details),
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
