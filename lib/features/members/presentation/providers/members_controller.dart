import 'package:flutter_riverpod/legacy.dart';

import '../../data/providers/member_repository_provider.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import 'members_state.dart';

/// Orquesta las operaciones sobre miembros. La UI (widgets) solo llama
/// a estos métodos y observa el estado; nunca habla con el
/// repositorio ni con Supabase directamente.
class MembersController extends StateNotifier<MembersState> {
  final MemberRepository _repository;

  MembersController(this._repository) : super(const MembersState.initial()) {
    loadMembers();
  }

  Future<void> loadMembers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final members = await _repository.getAll();
      state = state.copyWith(isLoading: false, members: members);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudieron cargar los miembros: $e',
      );
    }
  }

  Future<void> createMember(Member draft) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.create(draft);
      await loadMembers();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo crear el miembro: $e',
      );
    }
  }

  Future<void> deleteMember(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.delete(id);
      await loadMembers();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo eliminar el miembro: $e',
      );
    }
  }
}

final membersControllerProvider =
    StateNotifierProvider<MembersController, MembersState>((ref) {
  final repository = ref.watch(memberRepositoryProvider);
  return MembersController(repository);
});
