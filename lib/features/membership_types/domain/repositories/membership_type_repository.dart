import '../entities/membership_type.dart';

abstract class MembershipTypeRepository {
  Future<List<MembershipType>> getAll();
  Future<MembershipType> create(MembershipType type);
  Future<MembershipType> update(MembershipType type);
  Future<void> delete(String id);
}
