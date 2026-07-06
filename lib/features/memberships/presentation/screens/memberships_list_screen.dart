import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/membership_details.dart';
import '../providers/memberships_controller.dart';
import 'membership_form_screen.dart';

class MembershipsListScreen extends ConsumerStatefulWidget {
  const MembershipsListScreen({super.key});

  @override
  ConsumerState<MembershipsListScreen> createState() => _MembershipsListScreenState();
}

class _MembershipsListScreenState extends ConsumerState<MembershipsListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MembershipDetails> _applyFilter(List<MembershipDetails> memberships) {
    if (_query.trim().isEmpty) return memberships;
    final query = _query.trim().toLowerCase();
    return memberships
        .where((d) =>
            d.memberFullName.toLowerCase().contains(query) ||
            d.membershipTypeName.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, MembershipDetails details) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar membresía'),
        content: Text('¿Seguro que querés eliminar la membresía de "${details.memberFullName}"?'),
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
      ref.read(membershipsControllerProvider.notifier).deleteMembership(details.membership.id);
    }
  }

  ({String label, Color color}) _statusBadge(MembershipDetails details) {
    final membership = details.membership;
    if (!membership.isActive) {
      return (label: 'Inactiva', color: AppColors.textSecondary);
    }
    if (membership.isExpired) {
      return (label: 'Vencida', color: AppColors.error);
    }
    if (membership.isFuture) {
      return (label: 'Programada', color: AppColors.info);
    }
    return (label: 'Activa', color: AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(membershipsControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final filteredMemberships = _applyFilter(state.memberships);

    return Scaffold(
      appBar: AppBar(title: const Text('Membresías')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MembershipFormScreen()),
        ),
        tooltip: 'Nueva membresía',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(membershipsControllerProvider.notifier).loadMemberships(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por miembro o tipo',
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
              child: filteredMemberships.isEmpty && !state.isLoading
                  ? Center(
                      child: Text(
                        state.memberships.isEmpty
                            ? 'Todavía no hay membresías.\nToca + para asignar la primera.'
                            : 'No hay membresías que coincidan con la búsqueda.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filteredMemberships.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final details = filteredMemberships[index];
                        final membership = details.membership;
                        final badge = _statusBadge(details);

                        return Card(
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MembershipFormScreen(membership: membership),
                              ),
                            ),
                            title: Text(details.memberFullName, style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              '${details.membershipTypeName} · '
                              '${dateFormat.format(membership.startDate)} a ${dateFormat.format(membership.endDate)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badge.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    badge.label,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: badge.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () => _confirmDelete(context, ref, details),
                                ),
                              ],
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
