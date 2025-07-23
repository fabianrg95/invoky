import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventario.dart';

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
      print('Error al obtener inventario: $e');
      return null;
    }
  }

  // Actualizar o crear registro de inventario
  Future<Inventario> actualizarInventario({
    required int productoId,
    required int cantidad,
    bool esNuevo = false,
  }) async {
    try {
      // Si es un producto nuevo, creamos el registro de inventario
      if (esNuevo) {
        final response = await _supabase
            .from('inventario')
            .insert({
              'producto_id': productoId,
              'stock': cantidad,
            })
            .select()
            .single();

        return Inventario.fromJson(response);
      } else {
        // Si el producto ya existe, actualizamos el inventario
        final response = await _supabase.rpc('incrementar_stock', params: {
          'p_producto_id': productoId,
          'p_cantidad': cantidad,
        });

        // Si no se pudo actualizar (puede que no exista el registro), lo creamos
        if (response == null) {
          return await actualizarInventario(
            productoId: productoId,
            cantidad: cantidad,
            esNuevo: true,
          );
        }

        return Inventario.fromJson(response);
      }
    } catch (e) {
      print('Error al actualizar inventario: $e');
      rethrow;
    }
  }
}
