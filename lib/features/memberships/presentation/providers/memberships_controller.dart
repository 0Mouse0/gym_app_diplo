import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../data/providers/membership_repository_provider.dart';
import '../../domain/repositories/membership_repository.dart';
import '../../domain/services/membership_rules_service.dart';
import '../../domain/services/membership_rules_service_provider.dart';
import 'memberships_state.dart';

class MembershipsController extends StateNotifier<MembershipsState> {
  final MembershipRepository _repository;
  final MembershipRulesService _rulesService;

  MembershipsController(this._repository, this._rulesService)
      : super(const MembershipsState.initial()) {
    loadMemberships();
  }

  Future<void> loadMemberships() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final memberships = await _repository.getAllWithDetails();
      state = state.copyWith(isLoading: false, memberships: memberships);
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al cargar las membresías.',
      );
    }
  }

  Future<bool> createMembership(Membership draft) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _rulesService.ensureCanAssign(
        memberId: draft.memberId,
        startDate: draft.startDate,
        endDate: draft.endDate,
      );
      await _repository.create(draft);
      await loadMemberships();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al crear la membresía.',
      );
      return false;
    }
  }

  Future<bool> updateMembership(Membership membership) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _rulesService.ensureCanAssign(
        memberId: membership.memberId,
        startDate: membership.startDate,
        endDate: membership.endDate,
        excludingMembershipId: membership.id,
      );
      await _repository.update(membership);
      await loadMemberships();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al actualizar la membresía.',
      );
      return false;
    }
  }

  Future<void> deleteMembership(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.delete(id);
      await loadMemberships();
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al eliminar la membresía.',
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final membershipsControllerProvider =
    StateNotifierProvider<MembershipsController, MembershipsState>((ref) {
  final repository = ref.watch(membershipRepositoryProvider);
  final rulesService = ref.watch(membershipRulesServiceProvider);
  return MembershipsController(repository, rulesService);
});
