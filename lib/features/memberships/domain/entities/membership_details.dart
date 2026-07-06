import 'membership.dart';

/// Vista de lectura que combina una [Membership] con datos del
/// miembro y del tipo de membresía, ya resueltos, para no obligar a
/// la UI a hacer sus propios cruces/búsquedas.
class MembershipDetails {
  final Membership membership;
  final String memberFullName;
  final String membershipTypeName;
  final double membershipPrice;

  const MembershipDetails({
    required this.membership,
    required this.memberFullName,
    required this.membershipTypeName,
    required this.membershipPrice,
  });

  /// Arma el objeto a partir de una fila de Supabase con los
  /// recursos embebidos: `select('*, members(...), membership_types(...)')`.
  factory MembershipDetails.fromMap(Map<String, dynamic> map) {
    final memberMap = map['members'] as Map<String, dynamic>?;
    final typeMap = map['membership_types'] as Map<String, dynamic>?;

    final memberName = memberMap == null
        ? 'Miembro eliminado'
        : '${memberMap['last_name']}, ${memberMap['first_name']}';

    return MembershipDetails(
      membership: Membership.fromMap(map),
      memberFullName: memberName,
      membershipTypeName: typeMap?['name'] as String? ?? 'Tipo eliminado',
      membershipPrice: typeMap == null ? 0.0 : (typeMap['price'] as num).toDouble(),
    );
  }
}
