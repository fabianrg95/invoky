import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';

class ProductoService {
  final _supabase = Supabase.instance.client;

  // Consulta ligera para listar productos (sin códigos de barras)
  Future<List<Producto>> listarProductos() async {
    final response = await _supabase
        .from('productos')
        .select('id, nombre, precio_venta')
        .order('nombre', ascending: true);

    return response.map<Producto>((map) => Producto.fromMap(map)).toList();
  }

  // Consulta detallada para ver un producto específico (con códigos de barras)
  Future<Producto> obtenerProductoDetallado(String productoId) async {
    // Primero obtenemos los datos del producto
    final productoResponse = await _supabase
        .from('productos')
        .select()
        .eq('id', productoId)
        .single();
    
    // Combinamos los datos del producto con los códigos de barras
    return Producto.fromMap(productoResponse);
  }

  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    // Primero buscamos el código de barras para obtener el ID del producto
    final productoResponse = await _supabase
        .from('productos')
        .select()
        .eq('codigo_barras', codigo)
        .single();

    // Combinamos los datos del producto con los códigos de barras
    return Producto.fromMap(productoResponse);
  }
}
