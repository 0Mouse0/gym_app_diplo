import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../data/providers/payment_repository_provider.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payments_state.dart';

class PaymentsController extends StateNotifier<PaymentsState> {
  final PaymentRepository _repository;

  PaymentsController(this._repository) : super(const PaymentsState.initial()) {
    loadPayments();
  }

  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final payments = await _repository.getAllWithDetails();
      state = state.copyWith(isLoading: false, payments: payments);
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al cargar los pagos.',
      );
    }
  }

  Future<bool> createPayment(Payment draft) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.create(draft);
      await loadPayments();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al registrar el pago.',
      );
      return false;
    }
  }

  Future<bool> updatePayment(Payment payment) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.update(payment);
      await loadPayments();
      return true;
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al actualizar el pago.',
      );
      return false;
    }
  }

  Future<void> deletePayment(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.delete(id);
      await loadPayments();
    } on RepositoryException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al eliminar el pago.',
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final paymentsControllerProvider = StateNotifierProvider<PaymentsController, PaymentsState>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentsController(repository);
});
