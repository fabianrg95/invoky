import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/venta.dart';
import '../models/venta_producto.dart';
import 'dart:developer' as developer;

class VentaService {
  final _supabase = Supabase.instance.client;
  
  // Crear una nueva venta
  Future<Venta> crearVenta({
    required List<Map<String, dynamic>> productos,
    required int medioPagoId,
    double? valorPagoTarjeta,
  }) async {
    try {
      // Iniciar transacción
      await _supabase.rpc('begin');
      
      // 1. Crear la venta
      final ventaData = await _supabase
          .from('ventas')
          .insert({
            'fecha': DateTime.now().toIso8601String(),
            'medio_pago_id': medioPagoId,
            'valor_pago_tarjeta': valorPagoTarjeta,
            'usuario_id': _supabase.auth.currentUser?.id,
          })
          .select()
          .single();
      
      final ventaId = ventaData['id'] as int;
      final List<VentaProducto> ventaProductos = [];
      
      // 2. Registrar los productos de la venta y actualizar inventario
      for (final producto in productos) {
        final productoId = producto['producto_id'] as int;
        final cantidad = producto['cantidad'] as int;
        final precioVenta = producto['precio_venta'] as double;
        final esVentaUnitaria = producto['es_venta_unitaria'] as bool? ?? false;
        
        // Registrar el producto en la venta
        final ventaProductoData = await _supabase
            .from('venta_productos')
            .insert({
              'venta_id': ventaId,
              'producto_id': productoId,
              'cantidad': cantidad,
              'precio_venta': precioVenta,
              'es_venta_unitaria': esVentaUnitaria,
            })
            .select()
            .single();
            
        ventaProductos.add(VentaProducto.fromJson(ventaProductoData));
        
        // Actualizar el inventario
        await _supabase.rpc('actualizar_inventario', params: {
          'p_producto_id': productoId,
          'p_cantidad': -cantidad, // Restar del inventario
          'p_es_venta_unitaria': esVentaUnitaria,
        });
      }
      
      // Confirmar la transacción
      await _supabase.rpc('commit');
      
      // Obtener los datos completos de la venta
      final ventaCompleta = await _obtenerVentaPorId(ventaId);
      return ventaCompleta!;
      
    } catch (e) {
      // En caso de error, hacer rollback
      await _supabase.rpc('rollback');
      rethrow;
    }
  }
  
  // Obtener una venta por su ID
  Future<Venta?> _obtenerVentaPorId(int ventaId) async {
    try {
      final response = await _supabase
          .from('ventas')
          .select('''
            *,
            medio_pago:medios_pago(*),
            productos:venta_productos(
              *,
              producto:productos(*)
            )
          ''')
          .eq('id', ventaId)
          .single();
      
      return Venta.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Obtener historial de ventas
  Future<List<Venta>> obtenerHistorialVentas({DateTime? fechaInicio, DateTime? fechaFin}) async {
    try {
      String query = '''
        *,
        medio_pago:medios_pago(*),
        productos:venta_productos(
          *,
          producto:productos(*)
        )
      ''';
      
      // Construir la consulta manualmente
      String url = 'ventas?select=$query&order=fecha.desc';
      
      if (fechaInicio != null) {
        final fechaInicioStr = fechaInicio.toIso8601String();
        url += '&fecha=gte.$fechaInicioStr';
      }
      
      if (fechaFin != null) {
        final fechaFinAjustada = fechaFin.add(const Duration(days: 1));
        final fechaFinStr = fechaFinAjustada.toIso8601String();
        url += '&fecha=lt.$fechaFinStr';
      }
      
      final response = await _supabase.rpc('rpc', params: {
        'function_name': 'execute_sql',
        'args': {'query': 'SELECT * FROM $url'}
      });
      
      if (response != null && response is List) {
        return response.map((json) => Venta.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      developer.log('Error al cargar historial de ventas', error: e);
      throw Exception('Error al cargar el historial de ventas: $e');
    }
  }

  // Obtener detalles de una venta específica
  Future<Venta> obtenerDetalleVenta(int ventaId) async {
    try {
      final venta = await _obtenerVentaPorId(ventaId);
      if (venta != null) {
        return venta;
      } else {
        throw Exception('Venta no encontrada');
      }
    } catch (e) {
      throw Exception('Error al cargar el detalle de la venta: $e');
    }
  }
}
