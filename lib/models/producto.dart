class Producto {
  final String id;
  final String nombre;
  final String precio;

  Producto({required this.id, required this.nombre, required this.precio});

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(id: map['id'].toString(), nombre: map['nombre'] as String, precio: map['precio_venta'].toString());
  }
}
