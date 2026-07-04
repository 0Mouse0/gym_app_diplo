import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/member.dart';
import '../providers/members_controller.dart';
import 'member_form_screen.dart';

/// Listado real de miembros: búsqueda por nombre/documento, estado
/// activo/inactivo, navegación a edición y alta de un miembro nuevo.
class MembersListScreen extends ConsumerStatefulWidget {
  const MembersListScreen({super.key});

  @override
  ConsumerState<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends ConsumerState<MembersListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Member> _applyFilter(List<Member> members) {
    if (_query.trim().isEmpty) return members;
    final query = _query.trim().toLowerCase();
    return members
        .where((m) =>
            m.firstName.toLowerCase().contains(query) ||
            m.lastName.toLowerCase().contains(query) ||
            m.documentId.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _confirmDelete(BuildContext context, Member member) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text(
          '¿Seguro que querés eliminar a "${member.fullName}"? Esta acción no se puede deshacer.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(membersControllerProvider.notifier).deleteMember(member.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(membersControllerProvider);
    final filteredMembers = _applyFilter(state.members);

    return Scaffold(
      appBar: AppBar(title: const Text('Miembros')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MemberFormScreen()),
        ),
        tooltip: 'Nuevo miembro',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(membersControllerProvider.notifier).loadMembers(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por nombre o documento',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ),
            Expanded(
              child: filteredMembers.isEmpty && !state.isLoading
                  ? Center(
                      child: Text(
                        state.members.isEmpty
                            ? 'Todavía no hay miembros.\nToca + para agregar el primero.'
                            : 'No hay miembros que coincidan con la búsqueda.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: filteredMembers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return Card(
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MemberFormScreen(member: member),
                              ),
                            ),
                            title: Text(member.displayNameLastFirst, style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              'Doc: ${member.documentId} · ${member.email ?? 'sin email'}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: member.isActive
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.textSecondary.withValues(alpha: 0.15),
                              child: Icon(
                                member.isActive ? Icons.check : Icons.pause,
                                color: member.isActive ? AppColors.success : AppColors.textSecondary,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _confirmDelete(context, member),
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
