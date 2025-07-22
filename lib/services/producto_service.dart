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

    // Luego obtenemos los códigos de barras asociados
    final codigosResponse = await _supabase
        .from('codigo_barras')
        .select('codigo_barras')
        .eq('producto_id', productoId);

    // Mapeamos los códigos de barras a una lista de strings
    final codigosBarras = (codigosResponse as List<dynamic>)
        .map((e) => e['codigo_barras'].toString())
        .toList();
    
    // Combinamos los datos del producto con los códigos de barras
    return Producto.fromMap({
      ...productoResponse,
      'codigos_barras': codigosBarras,
    });
  }

  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    // Primero buscamos el código de barras para obtener el ID del producto
    final codigoBarrasResponse = await _supabase
        .from('codigo_barras')
        .select('producto_id')
        .eq('codigo_barras', codigo)
        .maybeSingle();

    if (codigoBarrasResponse == null) return null;
    
    final productoId = codigoBarrasResponse['producto_id'].toString();
    
    // Usamos el ID del producto para obtener sus detalles completos
    return await obtenerProductoDetallado(productoId);
  }
}
