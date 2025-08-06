class VentaProducto {
  final int? id;
  final int? ventaId;
  final int? productoId;
  final int cantidad;
  final double valor;

  VentaProducto({
    this.id,
    this.ventaId,
    this.productoId,
    required this.cantidad,
    required this.valor,
  });

  factory VentaProducto.fromJson(Map<String, dynamic> json) {
    return VentaProducto(
      id: json['id'] as int?,
      ventaId: json['venta_id'] as int?,
      productoId: json['producto_id'] as int?,
      cantidad: (json['cantidad'] as int?) ?? 0,
      valor: json['valor'] != null 
          ? double.tryParse(json['valor'].toString()) ?? 0.0 
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venta_id': ventaId,
      'producto_id': productoId,
      'cantidad': cantidad,
      'valor': valor,
    };
  }

  VentaProducto copyWith({
    int? id,
    int? ventaId,
    int? productoId,
    int? cantidad,
    double? valor,
  }) {
    return VentaProducto(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      valor: valor ?? this.valor,
    );
  }
}
