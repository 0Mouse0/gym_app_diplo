import '../entities/payment.dart';
import '../entities/payment_details.dart';

export '../entities/payment.dart';

abstract class PaymentRepository {
  /// Listado enriquecido con nombre de miembro y tipo (para la UI).
  Future<List<PaymentDetails>> getAllWithDetails();

  Future<Payment> create(Payment payment);

  Future<Payment> update(Payment payment);

  Future<void> delete(String id);
}
