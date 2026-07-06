import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/membership_type.dart';
import '../providers/membership_types_controller.dart';
import 'membership_type_form_screen.dart';

class MembershipTypesListScreen extends ConsumerWidget {
  const MembershipTypesListScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, MembershipType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tipo de membresía'),
        content: Text('¿Seguro que querés eliminar "${type.name}"?'),
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
      ref.read(membershipTypesControllerProvider.notifier).deleteType(type.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(membershipTypesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tipos de Membresía')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MembershipTypeFormScreen()),
        ),
        tooltip: 'Nuevo tipo',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(membershipTypesControllerProvider.notifier).loadTypes(),
        child: Column(
          children: [
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
              child: state.types.isEmpty && !state.isLoading
                  ? Center(
                      child: Text(
                        'Todavía no hay tipos de membresía.\nToca + para crear el primero.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: state.types.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final type = state.types[index];
                        return Card(
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MembershipTypeFormScreen(type: type)),
                            ),
                            title: Text(type.name, style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              '${type.durationDays} días · \$${type.price.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _confirmDelete(context, ref, type),
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
