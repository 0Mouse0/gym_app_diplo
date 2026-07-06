import 'payment_method.dart';

/// Un pago concreto, asociado a una membresía.
///
/// Modelamos el pago contra la membresía (no directo contra el
/// miembro) porque un pago siempre corresponde a un período de
/// vigencia concreto — esto es lo que después permite el reporte de
/// "ingresos por período" sin ambigüedad sobre qué se pagó.
class Payment {
  final String id;
  final String membershipId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod method;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.membershipId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory Payment.draft({
    required String membershipId,
    required double amount,
    required DateTime paymentDate,
    required PaymentMethod method,
    String? notes,
  }) {
    final now = DateTime.now();
    return Payment(
      id: '',
      membershipId: membershipId,
      amount: amount,
      paymentDate: paymentDate,
      method: method,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  Payment copyWith({
    String? id,
    String? membershipId,
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? method,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      membershipId: membershipId ?? this.membershipId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Lee solo las columnas propias de `payments`. El detalle
  /// enriquecido (nombre de miembro/tipo) lo arma PaymentDetails con
  /// el mismo map, a partir de las relaciones embebidas.
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      membershipId: map['membership_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['payment_date'] as String),
      method: PaymentMethod.fromDb(map['payment_method'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'membership_id': membershipId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T').first,
      'payment_method': method.dbValue,
      'notes': notes,
    };
  }
}
