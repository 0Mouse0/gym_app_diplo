/// Una membresía concreta de un miembro (con vigencia).
///
/// Cada renovación se modela como una fila nueva (no se "estira" la
/// fecha de fin de la anterior): así queda un historial de membresías
/// por miembro, útil para reportes ("membresías por vencer",
/// "ingresos por período", etc.).
class Membership {
  final String id;
  final String memberId;
  final String membershipTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Membership({
    required this.id,
    required this.memberId,
    required this.membershipTypeId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Vencida si la fecha de fin ya pasó (comparando solo la fecha,
  /// sin horas, para que "vence hoy" no cuente como vencida).
  bool get isExpired {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
    return endDateOnly.isBefore(todayDate);
  }

  /// Todavía no arrancó (fecha de inicio en el futuro). Una membresía
  /// puede estar "programada" cuando se crea una renovación que
  /// empieza justo cuando termina la actual.
  bool get isFuture {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    return startDateOnly.isAfter(todayDate);
  }

  /// Vigente de verdad, HOY: ni desactivada manualmente, ni vencida
  /// por fecha, ni programada para el futuro. Esta es la regla que
  /// usa el módulo de Inscripciones para decidir si un miembro puede
  /// anotarse a una clase.
  bool get isCurrentlyValid => isActive && !isExpired && !isFuture;

  int get daysUntilExpiration => endDate.difference(DateTime.now()).inDays;

  /// Crea una membresía nueva calculando la fecha de fin a partir de
  /// la fecha de inicio + la duración del tipo elegido. Este cálculo
  /// vive acá (dominio), nunca en el formulario.
  factory Membership.fromTypeSelection({
    required String memberId,
    required String membershipTypeId,
    required int typeDurationDays,
    required DateTime startDate,
  }) {
    final now = DateTime.now();
    return Membership(
      id: '',
      memberId: memberId,
      membershipTypeId: membershipTypeId,
      startDate: startDate,
      endDate: startDate.add(Duration(days: typeDurationDays)),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  Membership copyWith({
    String? id,
    String? memberId,
    String? membershipTypeId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Membership(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      membershipTypeId: membershipTypeId ?? this.membershipTypeId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Lee solo las columnas propias de `memberships`, ignorando
  /// cualquier dato embebido de member_id/membership_type_id (eso lo
  /// arma MembershipDetails a partir del mismo map).
  factory Membership.fromMap(Map<String, dynamic> map) {
    return Membership(
      id: map['id'] as String,
      memberId: map['member_id'] as String,
      membershipTypeId: map['membership_type_id'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'member_id': memberId,
      'membership_type_id': membershipTypeId,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'is_active': isActive,
    };
  }
}
