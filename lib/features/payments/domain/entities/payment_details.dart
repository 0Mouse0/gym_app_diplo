import 'payment.dart';

/// Vista de lectura: un pago junto con el nombre del miembro y del
/// tipo de membresía a la que corresponde. Se arma a partir de un
/// `select` embebido de dos niveles (payments -> memberships ->
/// members / membership_types), no con joins manuales en Dart.
class PaymentDetails {
  final Payment payment;
  final String memberFullName;
  final String membershipTypeName;

  const PaymentDetails({
    required this.payment,
    required this.memberFullName,
    required this.membershipTypeName,
  });

  factory PaymentDetails.fromMap(Map<String, dynamic> map) {
    final membershipMap = map['membership'] as Map<String, dynamic>?;
    final memberMap = membershipMap?['member'] as Map<String, dynamic>?;
    final typeMap = membershipMap?['membership_type'] as Map<String, dynamic>?;

    final firstName = memberMap?['first_name'] as String?;
    final lastName = memberMap?['last_name'] as String?;

    return PaymentDetails(
      payment: Payment.fromMap(map),
      memberFullName: (firstName == null && lastName == null)
          ? 'Miembro eliminado'
          : '${lastName ?? ''}, ${firstName ?? ''}',
      membershipTypeName: typeMap?['name'] as String? ?? 'Tipo eliminado',
    );
  }
}
