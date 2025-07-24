import 'package:flutter/material.dart';
import 'producto.dart';

/// Versión mutable de la clase Producto para usar en la interfaz de usuario
class ProductoEditable with ChangeNotifier {
  String id;
  String nombre;
  double precio;
  double iva19;
  double iva30;
  String? codigoBarras;
  int stock;
  
  ProductoEditable({
    required this.id,
    required this.nombre,
    required this.precio,
    this.iva19 = 0.0,
    this.iva30 = 0.0,
    this.codigoBarras,
    required this.stock,
  });
  
  // Constructor de copia
  factory ProductoEditable.fromProducto(Producto producto) {
    return ProductoEditable(
      id: producto.id,
      nombre: producto.nombre,
      precio: producto.precio,
      iva19: producto.iva19,
      iva30: producto.iva30,
      codigoBarras: producto.codigoBarras,
      stock: producto.stock,
    );
  }
  

  
  // Actualizar código de barras
  void actualizarCodigoBarras(String? codigo) {
    codigoBarras = codigo;
    notifyListeners();
  }
  
  // Actualizar stock
  void actualizarStock(int nuevaCantidad) {
    stock = nuevaCantidad;
    notifyListeners();
  }

}
