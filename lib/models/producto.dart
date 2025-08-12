class Producto {
  final String id;
  final String nombre;
  final double precioCompraUnidad;
  final double precioVenta;
  final double iva19;
  final double iva30;
  final String? codigoBarras;
  final int stock;
  final bool permiteVentaUnitaria;
  final double? precioVentaUnidad; // Precio cuando se vende por unidad

  Producto({
    required this.id, 
    required this.nombre, 
    this.precioCompraUnidad = 0.0,
    required this.precioVenta,
    this.iva19 = 0.0,
    this.iva30 = 0.0,
    this.codigoBarras,
    required this.stock,
    this.permiteVentaUnitaria = false,
    this.precioVentaUnidad,
  });

  // Para compatibilidad con código existente
  double get precio => precioVenta;

  factory Producto.fromMap(Map<String, dynamic> map, {int stock = 0}) {
    return Producto(
      id: map['id'].toString(), 
      nombre: map['nombre'] as String, 
      precioCompraUnidad: map['precio_compra_unidad'] is double ? map['precio_compra_unidad'] : 
             (map['precio_compra_unidad'] as num).toDouble(),
      precioVenta: map['precio_venta'] is double ? map['precio_venta'] : 
             (map['precio_venta'] as num?)?.toDouble() ?? 0.0,
      iva19: (map['iva_19'] as num?)?.toDouble() ?? 0.0,
      iva30: (map['iva_30'] as num?)?.toDouble() ?? 0.0,
      codigoBarras: map['codigo_barras']?.toString(),
      stock: stock,
      permiteVentaUnitaria: map['permite_venta_unitaria'] as bool? ?? false,
      precioVentaUnidad: (map['precio_venta_unidad'] as num?)?.toDouble(),
    );
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'].toString(),
      nombre: json['nombre'] as String,
      precioCompraUnidad: (json['precio_compra_unidad'] as num?)?.toDouble() ?? 0.0,
      precioVenta: (json['precio_venta'] as num?)?.toDouble() ?? 0.0,
      iva19: (json['iva_19'] as num?)?.toDouble() ?? 0.0,
      iva30: (json['iva_30'] as num?)?.toDouble() ?? 0.0,
      codigoBarras: json['codigo_barras']?.toString(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      permiteVentaUnitaria: json['permite_venta_unitaria'] as bool? ?? false,
      precioVentaUnidad: (json['precio_venta_unidad'] as num?)?.toDouble(),
    );
  }

  double calcularIva19(int cantidad){
    return cantidad * 0.19;
  }

  double calcularIva30(int cantidad){
    return cantidad * 0.30;
  }
}
