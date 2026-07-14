import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../domain/entities/payment_details.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  static const _table = 'payments';

  // Select embebido de dos niveles: payments -> memberships ->
  // members / membership_types. Así el listado de pagos muestra
  // nombre de miembro y tipo sin joins manuales en Dart.
  static const _selectWithDetails = '*, '
      'membership:memberships('
      'member:members(first_name, last_name), '
      'membership_type:membership_types(name)'
      ')';

  final SupabaseClient _client;

  PaymentRepositoryImpl(this._client);

  @override
  Future<List<PaymentDetails>> getAllWithDetails() async {
    try {
      final rows = await _client
          .from(_table)
          .select(_selectWithDetails)
          .order('payment_date', ascending: false);

      return (rows as List)
          .map((row) => PaymentDetails.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  @override
  Future<Payment> create(Payment payment) async {
    try {
      final row = await _client
          .from(_table)
          .insert(payment.toInsertMap())
          .select()
          .single();
      return Payment.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo registrar el pago.');
    }
  }

  @override
  Future<Payment> update(Payment payment) async {
    try {
      final row = await _client
          .from(_table)
          .update(payment.toInsertMap())
          .eq('id', payment.id)
          .select()
          .single();
      return Payment.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo actualizar el pago.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo eliminar el pago.');
    }
  }

  String _translate(PostgrestException e) {
    switch (e.code) {
      case '23503':
        return 'La membresía seleccionada no existe.';
      case '23502':
        return 'Faltan datos obligatorios del pago.';
      case '23514':
        return 'El monto debe ser mayor a 0.';
      case '42501':
        return 'No tienes permiso para hacer esto. Inicia sesión nuevamente.';
      default:
        return 'Ocurrió un error al comunicarse con el servidor.';
    }
  }
}
