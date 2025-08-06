import 'package:supabase_flutter/supabase_flutter.dart';

class CodigoBarrasService {
  final _supabase = Supabase.instance.client;

  // Obtener el código de barras de un producto
  Future<String?> obtenerPorProducto(String productoId) async {
    final response = await _supabase
        .from('productos')
        .select('codigo_barras')
        .eq('id', productoId)
        .single();

    return response['codigo_barras']?.toString();
  }

  // Crear o actualizar el código de barras de un producto
  Future<void> crearOActualizar({
    required String productoId,
    required String codigo,
  }) async {

    if (await existe(codigo)) {
      throw Exception('El código de barras ya está en uso por otro producto');
    }

    await _supabase
        .from('productos')
        .update({'codigo_barras': codigo})
        .eq('id', productoId);
  }

  // Eliminar el código de barras de un producto
  Future<void> eliminar(String productoId) async {
    await _supabase
        .from('productos')
        .update({'codigo_barras': null})
        .eq('id', productoId);
  }

  // Verificar si un código de barras ya existe
  Future<bool> existe(String codigo) async {
    final response = await _supabase
        .from('productos')
        .select('id')
        .eq('codigo_barras', codigo)
        .maybeSingle();

    return response != null;
  }
}
