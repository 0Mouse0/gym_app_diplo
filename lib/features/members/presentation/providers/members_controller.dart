import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../data/providers/member_repository_provider.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import 'members_state.dart';

/// Orquesta las operaciones sobre miembros. La UI (widgets) solo llama
/// a estos métodos y observa el estado; nunca habla con el
/// repositorio ni con Supabase directamente. Tampoco conoce
/// PostgrestException ni ningún tipo propio de Supabase: solo
/// RepositoryException, que ya trae el mensaje listo para mostrar.
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
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al cargar los miembros.',
      );
    }
  }

  /// Devuelve true si se creó correctamente. Si devuelve false, el
  /// mensaje de error queda disponible en el estado (`errorMessage`).
  Future<bool> createMember(Member draft) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.create(draft);
      await loadMembers();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al crear el miembro.',
      );
      return false;
    }
  }

  /// Devuelve true si se actualizó correctamente.
  Future<bool> updateMember(Member member) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.update(member);
      await loadMembers();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al actualizar el miembro.',
      );
      return false;
    }
  }

  Future<void> deleteMember(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.delete(id);
      await loadMembers();
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al eliminar el miembro.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final membersControllerProvider =
    StateNotifierProvider<MembersController, MembersState>((ref) {
  final repository = ref.watch(memberRepositoryProvider);
  return MembersController(repository);
});
