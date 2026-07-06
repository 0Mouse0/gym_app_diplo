import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../data/providers/class_repository_provider.dart';
import '../../domain/entities/gym_class.dart';
import '../../domain/repositories/class_repository.dart';
import 'classes_state.dart';

class ClassesController extends StateNotifier<ClassesState> {
  final ClassRepository _repository;

  ClassesController(this._repository) : super(const ClassesState.initial()) {
    loadClasses();
  }

  Future<void> loadClasses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final classes = await _repository.getAll();
      state = state.copyWith(isLoading: false, classes: classes);
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al cargar las clases.',
      );
    }
  }

  Future<bool> createClass(GymClass draft) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.create(draft);
      await loadClasses();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al crear la clase.',
      );
      return false;
    }
  }

  Future<bool> updateClass(GymClass gymClass) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.update(gymClass);
      await loadClasses();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al actualizar la clase.',
      );
      return false;
    }
  }

  Future<void> deleteClass(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.delete(id);
      await loadClasses();
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al eliminar la clase.',
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final classesControllerProvider = StateNotifierProvider<ClassesController, ClassesState>((ref) {
  final repository = ref.watch(classRepositoryProvider);
  return ClassesController(repository);
});
