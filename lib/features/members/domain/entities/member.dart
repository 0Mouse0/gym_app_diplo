/// Entidad de dominio: un miembro del gimnasio.
///
/// Clase inmutable armada a mano (sin freezed/codegen), siguiendo la
/// decisión de mantener el proyecto sin build_runner.
class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String documentId;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.documentId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.phone,
    this.birthDate,
    this.address,
  });

  /// Nombre completo, calculado (no se guarda como tal en la base).
  /// Útil para mostrar en listas, títulos, etc.
  String get fullName => '$firstName $lastName';

  /// "Apellido, Nombre" — formato típico de directorio/listado alfabético.
  String get displayNameLastFirst => '$lastName, $firstName';

  /// Constructor para un miembro nuevo, todavía sin guardar (sin id
  /// definitivo ni timestamps, que los pone la base de datos).
  factory Member.draft({
    required String firstName,
    required String lastName,
    required String documentId,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? address,
  }) {
    final now = DateTime.now();
    return Member(
      id: '',
      firstName: firstName,
      lastName: lastName,
      documentId: documentId,
      email: email,
      phone: phone,
      birthDate: birthDate,
      address: address,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  Member copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? documentId,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      documentId: documentId ?? this.documentId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Arma un Member a partir de una fila devuelta por Supabase
  // (Map<String, dynamic> con las columnas en snake_case).
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      documentId: map['document_id'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      birthDate: map['birth_date'] == null
          ? null
          : DateTime.parse(map['birth_date'] as String),
      address: map['address'] as String?,
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convierte a Map para insertar/actualizar en Supabase.
  /// No incluye id/created_at/updated_at: esos los maneja la base de datos.
  Map<String, dynamic> toInsertMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'document_id': documentId,
      'email': email,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'address': address,
      'is_active': isActive,
    };
  }
}
