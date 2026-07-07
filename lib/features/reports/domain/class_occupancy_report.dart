import '../../classes/domain/entities/gym_class.dart';

/// Ocupación de una clase puntual: inscritos vs. cupo.
class ClassOccupancy {
  final GymClass gymClass;
  final int enrolledCount;

  const ClassOccupancy({required this.gymClass, required this.enrolledCount});

  double get occupancyRate => gymClass.capacity == 0 ? 0 : enrolledCount / gymClass.capacity;

  bool get isFull => enrolledCount >= gymClass.capacity;
}

/// Lógica pura del reporte de ocupación. Combina la lista de clases
/// con la cantidad de inscritos por clase (ya calculada por
/// `EnrollmentsState.countForClass`) — no vuelve a consultar Supabase.
class ClassOccupancyReport {
  ClassOccupancyReport._();

  /// [countForClass] es la función `countForClass` de `EnrollmentsState`,
  /// se la pasamos para no acoplar este archivo a esa clase concreta.
  static List<ClassOccupancy> build(
    List<GymClass> classes,
    int Function(String classId) countForClass,
  ) {
    final list = classes
        .map((c) => ClassOccupancy(gymClass: c, enrolledCount: countForClass(c.id)))
        .toList();

    // Más ocupadas primero — son las que más le interesan al staff.
    list.sort((a, b) => b.occupancyRate.compareTo(a.occupancyRate));
    return list;
  }
}
