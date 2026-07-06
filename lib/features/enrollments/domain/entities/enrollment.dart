/// Una inscripción de un miembro a una clase concreta.
///
/// No tiene "editar": para cambiar de clase, se cancela (se borra)
/// y se crea una nueva. Esto mantiene el modelo simple y evita el
/// caso ambiguo de "editar" una inscripción para que apunte a otro
/// miembro u otra clase.
class Enrollment {
  final String id;
  final String memberId;
  final String classId;
  final DateTime enrolledAt;
  final DateTime createdAt;

  const Enrollment({
    required this.id,
    required this.memberId,
    required this.classId,
    required this.enrolledAt,
    required this.createdAt,
  });

  factory Enrollment.draft({
    required String memberId,
    required String classId,
  }) {
    final now = DateTime.now();
    return Enrollment(
      id: '',
      memberId: memberId,
      classId: classId,
      enrolledAt: now,
      createdAt: now,
    );
  }

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      id: map['id'] as String,
      memberId: map['member_id'] as String,
      classId: map['class_id'] as String,
      enrolledAt: DateTime.parse(map['enrolled_at'] as String).toLocal(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'member_id': memberId,
      'class_id': classId,
    };
  }
}
