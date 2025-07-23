class Producto {
  final String id;
  final String nombre;
  final double precio;
  final double iva19;
  final double iva30;
  final String? codigoBarras;
  final int stock;

  Producto({
    required this.id, 
    required this.nombre, 
    required this.precio,
    this.iva19 = 0.0,
    this.iva30 = 0.0,
    this.codigoBarras,
    required this.stock,
  });

  factory Producto.fromMap(Map<String, dynamic> map, {int stock = 0}) {
    return Producto(
      id: map['id'].toString(), 
      nombre: map['nombre'] as String, 
      precio: map['precio_venta'] is double ? map['precio_venta'] : 
             (map['precio_venta'] as num).toDouble(),
      iva19: (map['iva_19'] as num?)?.toDouble() ?? 0.0,
      iva30: (map['iva_30'] as num?)?.toDouble() ?? 0.0,
      codigoBarras: map['codigo_barras']?.toString(),
      stock: stock,
    );
  }

  double calcularIva19(int cantidad){
    return cantidad * 0.19;
  }

  double calcularIva30(int cantidad){
    return cantidad * 0.30;
  }
}
