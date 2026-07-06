import '../entities/gym_class.dart';

abstract class ClassRepository {
  Future<List<GymClass>> getAll();
  Future<GymClass?> getById(String id);
  Future<GymClass> create(GymClass gymClass);
  Future<GymClass> update(GymClass gymClass);
  Future<void> delete(String id);
}
