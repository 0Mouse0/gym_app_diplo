import '../../domain/entities/payment_details.dart';

class PaymentsState {
  final bool isLoading;
  final List<PaymentDetails> payments;
  final String? errorMessage;

  const PaymentsState({
    this.isLoading = false,
    this.payments = const [],
    this.errorMessage,
  });

  const PaymentsState.initial()
      : isLoading = false,
        payments = const [],
        errorMessage = null;

  /// Suma de los montos actualmente cargados. Útil para mostrar un
  /// total en pantalla y como preview de lo que va a ser el reporte
  /// de "ingresos por período" más adelante.
  double get totalAmount => payments.fold(0.0, (sum, p) => sum + p.payment.amount);

  PaymentsState copyWith({
    bool? isLoading,
    List<PaymentDetails>? payments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
