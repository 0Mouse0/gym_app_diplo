import '../entities/membership.dart' show Membership;
import '../entities/membership_details.dart';

export '../entities/membership.dart';

abstract class MembershipRepository {
  /// Listado enriquecido con nombre de miembro y tipo (para la UI).
  Future<List<MembershipDetails>> getAllWithDetails();

  /// Membresías con is_active = true de un miembro (para chequear
  /// superposición de fechas antes de crear/editar una nueva).
  Future<List<Membership>> getActiveMembershipsForMember(String memberId);

  Future<Membership> create(Membership membership);

  Future<Membership> update(Membership membership);

  Future<void> delete(String id);
}
