import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';

class ProductoService {
  final _supabase = Supabase.instance.client;

  // Consulta ligera para listar productos (sin códigos de barras)
  Future<List<Producto>> listarProductos() async {
    final response = await _supabase
        .from('productos_con_inventario')
        .select('''
          id, 
          nombre, 
          precio_venta,
          stock
        ''')
        .order('nombre', ascending: true);

    return response.map<Producto>((map) {          
      return Producto(
        id: map['id'].toString(),
        nombre: map['nombre'] as String,
        precio: map['precio_venta'] is double ? map['precio_venta'] : 
               (map['precio_venta'] as num).toDouble(),
        stock: map['stock'] as int,
      );
    }).toList();
  }

  // Consulta detallada para ver un producto específico (con códigos de barras)
  Future<Producto> obtenerProductoDetallado(String productoId) async {
    // Primero obtenemos los datos del producto
    final productoResponse = await _supabase
        .from('productos')
        .select()
        .eq('id', productoId)
        .single();

    final stock = await _supabase
        .from('inventario')
        .select('stock')
        .eq('producto_id', productoId)
        .single();
    
    // Combinamos los datos del producto con los códigos de barras
    return Producto.fromMap(productoResponse, stock: stock['stock']);
  }

  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    try {
      // Primero buscamos el código de barras para obtener el ID del producto
      final productoResponse = await _supabase
          .from('productos')
          .select()
          .eq('codigo_barras', codigo)
          .maybeSingle();

      return productoResponse != null ? Producto.fromMap(productoResponse) : null;
    } catch (e) {
      print('Error al buscar producto por código: $e');
      return null;
    }
  }

  // Guardar un nuevo producto
  Future<Map<String, dynamic>> guardarProducto({
    required String nombre,
    required String codigoBarras,
    required double valorCompra,
    required double valorVenta,
  }) async {
    try {
      // Verificar si el producto ya existe
      final productoExistente = await _supabase
          .from('productos')
          .select()
          .eq('codigo_barras', codigoBarras)
          .maybeSingle();

      if (productoExistente != null) {
        throw Exception('Ya existe un producto con este código de barras');
      }

      // Insertar el nuevo producto
      final response = await _supabase
          .from('productos')
          .insert({
            'nombre': nombre,
            'codigo_barras': codigoBarras,
            'precio_compra': valorCompra,
            'precio_venta': valorVenta,
            'fecha_creacion': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error al guardar producto: $e');
      rethrow;
    }
  }
}
