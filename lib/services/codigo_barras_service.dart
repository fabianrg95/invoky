import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/codigo_barras.dart';

class CodigoBarrasService {
  final _supabase = Supabase.instance.client;

  // Obtener todos los códigos de barras de un producto
  Future<List<CodigoBarras>> obtenerPorProducto(String productoId) async {
    final response = await _supabase
        .from('codigo_barras')
        .select()
        .eq('producto_id', productoId);

    return response
        .map<CodigoBarras>((map) => CodigoBarras.fromMap(map))
        .toList();
  }

  // Agregar un nuevo código de barras
  Future<CodigoBarras> agregarCodigoBarras({
    required String productoId,
    required String codigo,
  }) async {
    // Verificar si el código ya existe
    final codigoExistente = await _supabase
        .from('codigo_barras')
        .select()
        .eq('codigo_barras', codigo)
        .maybeSingle();

    if (codigoExistente != null) {
      throw Exception('El código de barras ya está en uso');
    }

    final response = await _supabase
        .from('codigo_barras')
        .insert({
          'producto_id': productoId,
          'codigo_barras': codigo,
        })
        .select()
        .single();

    return CodigoBarras.fromMap(response);
  }

  // Eliminar un código de barras
  Future<void> eliminarCodigoBarras(String id) async {
    await _supabase.from('codigo_barras').delete().eq('id', id);
  }

  // Verificar si un código de barras ya existe
  Future<bool> existeCodigo(String codigo) async {
    final response = await _supabase
        .from('codigo_barras')
        .select('id')
        .eq('codigo_barras', codigo)
        .maybeSingle();

    return response != null;
  }
}
