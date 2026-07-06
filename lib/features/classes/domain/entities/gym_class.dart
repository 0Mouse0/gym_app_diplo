/// Una clase concreta del gimnasio: una sesión con fecha/hora fija y
/// un cupo máximo. Se llama `GymClass` (no `Class`) para no chocar
/// con la palabra reservada `class` de Dart.
class GymClass {
  final String id;
  final String name;
  final String? instructor;
  final DateTime scheduledAt;
  final int durationMinutes;
  final int capacity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GymClass({
    required this.id,
    required this.name,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.capacity,
    required this.createdAt,
    required this.updatedAt,
    this.instructor,
  });

  /// Ya pasó (la sesión ya ocurrió). Útil para no dejar inscribir a
  /// una clase que ya sucedió, y para distinguirla visualmente en el
  /// listado.
  bool get isPast => scheduledAt.isBefore(DateTime.now());

  factory GymClass.draft({
    required String name,
    required DateTime scheduledAt,
    required int durationMinutes,
    required int capacity,
    String? instructor,
  }) {
    final now = DateTime.now();
    return GymClass(
      id: '',
      name: name,
      instructor: instructor,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      capacity: capacity,
      createdAt: now,
      updatedAt: now,
    );
  }

  GymClass copyWith({
    String? id,
    String? name,
    String? instructor,
    DateTime? scheduledAt,
    int? durationMinutes,
    int? capacity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GymClass(
      id: id ?? this.id,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GymClass.fromMap(Map<String, dynamic> map) {
    return GymClass(
      id: map['id'] as String,
      name: map['name'] as String,
      instructor: map['instructor'] as String?,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String).toLocal(),
      durationMinutes: map['duration_minutes'] as int,
      capacity: map['capacity'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'instructor': instructor,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'capacity': capacity,
    };
  }
}
