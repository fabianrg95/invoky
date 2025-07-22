import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';

class ProductoService {
  Future<List<Producto>> obtenerProductos() async {
    final response = await Supabase.instance.client.from('productos').select('id, nombre, precio_venta');
    return (response as List).map((item) => Producto.fromMap(item as Map<String, dynamic>)).toList();
  }

  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    final response = await Supabase.instance.client.from('productos').select('id, nombre, precio_venta').eq('codigo_barras', codigo).maybeSingle();
    if (response == null) return null;
    return Producto.fromMap(response);
  }
}
