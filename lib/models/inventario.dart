class Inventario {
  final int? id;
  final int? productoId;
  final int stock;

  Inventario({
    this.id,
    this.productoId,
    this.stock = 0,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) {
    return Inventario(
      id: json['id'] as int?,
      productoId: json['producto_id'] as int?,
      stock: (json['stock'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'stock': stock,
    };
  }

  Inventario copyWith({
    int? id,
    int? productoId,
    int? stock,
  }) {
    return Inventario(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      stock: stock ?? this.stock,
    );
  }

  // Método para aumentar el stock
  Inventario aumentarStock(int cantidad) {
    return copyWith(stock: stock + cantidad);
  }

  // Método para disminuir el stock
  Inventario disminuirStock(int cantidad) {
    final nuevoStock = stock - cantidad;
    return copyWith(stock: nuevoStock >= 0 ? nuevoStock : 0);
  }
}
