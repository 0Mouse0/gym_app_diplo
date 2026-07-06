import '../entities/enrollment.dart';
import '../entities/enrollment_details.dart';

export '../entities/enrollment.dart';

abstract class EnrollmentRepository {
  /// Listado enriquecido con nombre de miembro y datos de la clase.
  Future<List<EnrollmentDetails>> getAllWithDetails();

  /// Cantidad de inscripciones activas de una clase (para chequear
  /// cupo antes de crear una nueva).
  Future<int> getCountForClass(String classId);

  Future<Enrollment> create(Enrollment enrollment);

  /// No hay `update`: cancelar una inscripción es borrarla.
  Future<void> delete(String id);
}
