import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventario.dart';
import '../models/producto.dart';

class InventarioService {
  final _supabase = Supabase.instance.client;

  // Obtener el inventario de un producto
  Future<Inventario?> obtenerInventarioProducto(int productoId) async {
    try {
      final response = await _supabase
          .from('inventario')
          .select()
          .eq('producto_id', productoId)
          .maybeSingle();

      return response != null ? Inventario.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  // Actualizar o crear registro de inventario
  Future<Inventario> actualizarInventario({
    required int productoId,
    required int cantidad,
    bool esNuevo = false,
    required int stockUnitario,
  }) async {
    try {
      // Si es un producto nuevo, creamos el registro de inventario
      if (esNuevo) {
        final response = await _supabase
            .from('inventario')
            .insert({
              'producto_id': productoId,
              'stock': cantidad,
              'stock_unitario': stockUnitario,
            })
            .select()
            .single();

        return Inventario.fromJson(response);
      } else {
        // Si el producto ya existe, actualizamos el inventario
        final response = await _supabase.from('inventario').update({'stock': cantidad}).eq('producto_id', productoId).select().single();

        return Inventario.fromJson(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Buscar producto por código de barras
  Future<Producto?> buscarProductoPorCodigo(String codigoBarras) async {
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .eq('codigo_barras', codigoBarras)
          .maybeSingle();

      return response != null ? Producto.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  // Buscar productos por nombre
  Future<List<Producto>> buscarProductos(String query) async {
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .ilike('nombre', '%$query%')
          .limit(10);

      return (response as List).map((json) => Producto.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
