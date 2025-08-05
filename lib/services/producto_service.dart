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

  Future<void> actualizarStock({
    required String productoId,
    required int cantidad,
  }) async {
    await _supabase
        .from('inventario')
        .update({'stock': cantidad})
        .eq('producto_id', productoId);
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
      return null;
    }
  }

  // Guardar un nuevo producto
  Future<Map<String, dynamic>> guardarProducto({
    required String nombre,
    required String codigoBarras,
    required double valorCompra,
    required double valorVenta,
    required double iva19,
    required double iva30,
    required double precioRecomendadoVenta,
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
            'precio_compra_unidad': valorCompra,
            'precio_venta': valorVenta.toInt(),
            'iva_19': iva19,
            'iva_30': iva30,
            'precio_recomendado': precioRecomendadoVenta,
            'margen_ganancia': valorVenta - valorCompra,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Actualizar los datos de un producto existente
  Future<void> actualizarProducto({
    required String productoId,
    String? nombre,
    double? precioVenta,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (nombre != null) {
        updateData['nombre'] = nombre;
      }
      
      if (precioVenta != null) {
        updateData['precio_venta'] = precioVenta.toInt();
        // Recalcular margen de ganancia basado en el nuevo precio
        final producto = await _supabase
            .from('productos')
            .select('precio_compra_unidad')
            .eq('id', productoId)
            .single();
            
        if (producto['precio_compra_unidad'] != null) {
          final double precioCompra = (producto['precio_compra_unidad'] as num).toDouble();
          updateData['margen_ganancia'] = precioVenta - precioCompra;
        }
      }
      
      if (updateData.isNotEmpty) {
        await _supabase
            .from('productos')
            .update(updateData)
            .eq('id', productoId);
      }
    } catch (e) {
      rethrow;
    }
  }
}
