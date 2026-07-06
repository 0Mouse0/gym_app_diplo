import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../data/providers/enrollment_repository_provider.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/services/enrollment_rules_service.dart';
import '../../domain/services/enrollment_rules_service_provider.dart';
import 'enrollments_state.dart';

class EnrollmentsController extends StateNotifier<EnrollmentsState> {
  final EnrollmentRepository _repository;
  final EnrollmentRulesService _rulesService;

  EnrollmentsController(this._repository, this._rulesService)
      : super(const EnrollmentsState.initial()) {
    loadEnrollments();
  }

  Future<void> loadEnrollments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final enrollments = await _repository.getAllWithDetails();
      state = state.copyWith(isLoading: false, enrollments: enrollments);
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al cargar las inscripciones.',
      );
    }
  }

  Future<bool> enroll({required String memberId, required String classId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _rulesService.ensureCanEnroll(memberId: memberId, classId: classId);
      await _repository.create(Enrollment.draft(memberId: memberId, classId: classId));
      await loadEnrollments();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al inscribir al miembro.',
      );
      return false;
    }
  }

  Future<void> cancelEnrollment(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.delete(id);
      await loadEnrollments();
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al cancelar la inscripción.',
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final enrollmentsControllerProvider =
    StateNotifierProvider<EnrollmentsController, EnrollmentsState>((ref) {
  final repository = ref.watch(enrollmentRepositoryProvider);
  final rulesService = ref.watch(enrollmentRulesServiceProvider);
  return EnrollmentsController(repository, rulesService);
});
