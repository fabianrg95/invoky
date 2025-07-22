import 'package:flutter/material.dart';
import 'producto.dart';

/// Versión mutable de la clase Producto para usar en la interfaz de usuario
class ProductoEditable with ChangeNotifier {
  String id;
  String nombre;
  double precio;
  int stock;
  double iva19;
  double iva30;
  List<String> codigosBarras;
  
  ProductoEditable({
    required this.id,
    required this.nombre,
    required this.precio,
    this.stock = 0,
    this.iva19 = 0.0,
    this.iva30 = 0.0,
    List<String>? codigosBarras,
  }) : codigosBarras = codigosBarras ?? [];
  
  // Constructor de copia
  factory ProductoEditable.fromProducto(Producto producto) {
    return ProductoEditable(
      id: producto.id,
      nombre: producto.nombre,
      precio: producto.precio,
      stock: producto.stock,
      iva19: producto.iva19,
      iva30: producto.iva30,
      codigosBarras: List<String>.from(producto.codigosBarras),
    );
  }
  

  
  // Actualizar códigos de barras
  void actualizarCodigosBarras(List<String> nuevosCodigos) {
    codigosBarras = List<String>.from(nuevosCodigos);
    notifyListeners();
  }
  
  // Agregar un código de barras
  void agregarCodigoBarras(String codigo) {
    if (!codigosBarras.contains(codigo)) {
      codigosBarras.add(codigo);
      notifyListeners();
    }
  }
  
  // Eliminar un código de barras
  void eliminarCodigoBarras(String codigo) {
    codigosBarras.remove(codigo);
    notifyListeners();
  }
  

}
