import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/member.dart';
import '../providers/members_controller.dart';

/// Pantalla temporal de la Parte 1. Prueba el repositorio y el
/// controller de miembros contra Supabase sin depender todavía de
/// un formulario validado (eso llega en la Parte 2).
class MembersTestScreen extends ConsumerWidget {
  const MembersTestScreen({super.key});

  void _createSampleMember(WidgetRef ref) {
    final uniqueSuffix = DateTime.now().millisecondsSinceEpoch.toString();
    final draft = Member.draft(
      fullName: 'Miembro de prueba $uniqueSuffix',
      documentId: 'TEST-$uniqueSuffix',
      email: 'prueba$uniqueSuffix@ejemplo.com',
    );
    ref.read(membersControllerProvider.notifier).createMember(draft);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(membersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Miembros (prueba Parte 1)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createSampleMember(ref),
        tooltip: 'Crear miembro de prueba',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(membersControllerProvider.notifier).loadMembers(),
        child: Column(
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.errorMessage != null)
              Container(
                width: double.infinity,
                color: AppColors.error.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ),
            Expanded(
              child: state.members.isEmpty && !state.isLoading
                  ? Center(
                      child: Text(
                        'Todavía no hay miembros.\nToca + para crear uno de prueba.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: state.members.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final member = state.members[index];
                        return Card(
                          child: ListTile(
                            title: Text(member.fullName, style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              'Doc: ${member.documentId} · ${member.email ?? 'sin email'}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => ref
                                  .read(membersControllerProvider.notifier)
                                  .deleteMember(member.id),
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
