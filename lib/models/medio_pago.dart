class MedioPago {
  final int? id;
  final DateTime createdAt;
  final String? medioPago;

  MedioPago({
    this.id,
    DateTime? createdAt,
    this.medioPago,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MedioPago.fromJson(Map<String, dynamic> json) {
    return MedioPago(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      medioPago: json['medio_pago'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'medio_pago': medioPago,
    };
  }

  MedioPago copyWith({
    int? id,
    DateTime? createdAt,
    String? medioPago,
  }) {
    return MedioPago(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      medioPago: medioPago ?? this.medioPago,
    );
  }
}
