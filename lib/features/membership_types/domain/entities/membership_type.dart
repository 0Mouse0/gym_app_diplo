/// Un tipo/plan de membresía del catálogo (ej. "Mensual", 30 días, $25).
class MembershipType {
  final String id;
  final String name;
  final int durationDays;
  final double price;
  final DateTime createdAt;

  const MembershipType({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.createdAt,
  });

  factory MembershipType.draft({
    required String name,
    required int durationDays,
    required double price,
  }) {
    return MembershipType(
      id: '',
      name: name,
      durationDays: durationDays,
      price: price,
      createdAt: DateTime.now(),
    );
  }

  MembershipType copyWith({
    String? id,
    String? name,
    int? durationDays,
    double? price,
    DateTime? createdAt,
  }) {
    return MembershipType(
      id: id ?? this.id,
      name: name ?? this.name,
      durationDays: durationDays ?? this.durationDays,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MembershipType.fromMap(Map<String, dynamic> map) {
    return MembershipType(
      id: map['id'] as String,
      name: map['name'] as String,
      durationDays: map['duration_days'] as int,
      price: (map['price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'duration_days': durationDays,
      'price': price,
    };
  }
}
