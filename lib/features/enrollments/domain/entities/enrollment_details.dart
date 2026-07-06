import 'enrollment.dart';

/// Vista de lectura que combina una [Enrollment] con el nombre del
/// miembro y los datos de la clase (nombre, horario, cupo), armada
/// con un `select` embebido de Supabase.
class EnrollmentDetails {
  final Enrollment enrollment;
  final String memberFullName;
  final String className;
  final DateTime classScheduledAt;
  final int classCapacity;

  const EnrollmentDetails({
    required this.enrollment,
    required this.memberFullName,
    required this.className,
    required this.classScheduledAt,
    required this.classCapacity,
  });

  factory EnrollmentDetails.fromMap(Map<String, dynamic> map) {
    final memberMap = map['member'] as Map<String, dynamic>?;
    final classMap = map['class'] as Map<String, dynamic>?;

    return EnrollmentDetails(
      enrollment: Enrollment.fromMap(map),
      memberFullName: memberMap == null
          ? 'Miembro eliminado'
          : '${memberMap['last_name']}, ${memberMap['first_name']}',
      className: classMap?['name'] as String? ?? 'Clase eliminada',
      classScheduledAt: classMap == null
          ? DateTime.now()
          : DateTime.parse(classMap['scheduled_at'] as String).toLocal(),
      classCapacity: classMap?['capacity'] as int? ?? 0,
    );
  }
}
