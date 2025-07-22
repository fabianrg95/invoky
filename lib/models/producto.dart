class Producto {
  final String id;
  final String nombre;
  final double precio;
  final int stock;
  final double iva19;
  final double iva30;
  final List<String> codigosBarras;

  Producto({
    required this.id, 
    required this.nombre, 
    required this.precio,
    this.stock = 0,
    this.iva19 = 0.0,
    this.iva30 = 0.0,
    List<String>? codigosBarras,
  }) : codigosBarras = codigosBarras ?? [];

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'].toString(), 
      nombre: map['nombre'] as String, 
      precio: map['precio_venta'] is double ? map['precio_venta'] : 
             (map['precio_venta'] as num).toDouble(),
      stock: map['stock'] as int? ?? 0,
      iva19: (map['iva_19'] as num?)?.toDouble() ?? 0.0,
      iva30: (map['iva_30'] as num?)?.toDouble() ?? 0.0,
      codigosBarras: (map['codigos_barras'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
