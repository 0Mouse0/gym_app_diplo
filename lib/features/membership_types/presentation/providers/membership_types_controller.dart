import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../data/providers/membership_type_repository_provider.dart';
import '../../domain/entities/membership_type.dart';
import '../../domain/repositories/membership_type_repository.dart';
import 'membership_types_state.dart';

class MembershipTypesController extends StateNotifier<MembershipTypesState> {
  final MembershipTypeRepository _repository;

  MembershipTypesController(this._repository) : super(const MembershipTypesState.initial()) {
    loadTypes();
  }

  Future<void> loadTypes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final types = await _repository.getAll();
      state = state.copyWith(isLoading: false, types: types);
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al cargar los tipos de membresía.',
      );
    }
  }

  Future<bool> createType(MembershipType draft) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.create(draft);
      await loadTypes();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al crear el tipo de membresía.',
      );
      return false;
    }
  }

  Future<bool> updateType(MembershipType type) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.update(type);
      await loadTypes();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al actualizar el tipo de membresía.',
      );
      return false;
    }
  }

  Future<void> deleteType(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.delete(id);
      await loadTypes();
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al eliminar el tipo de membresía.',
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final membershipTypesControllerProvider =
    StateNotifierProvider<MembershipTypesController, MembershipTypesState>((ref) {
  final repository = ref.watch(membershipTypeRepositoryProvider);
  return MembershipTypesController(repository);
});
