import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/caja.dart';

class CajaService {
  final _supabase = Supabase.instance.client;
  static const String _tableName = 'caja';

  Future<bool> verificarCajaAbierta() async {
    try {
      final fechaHoy = DateTime.now().toIso8601String().split('T').first;
      final response = await _supabase
          .from(_tableName)
          .select("id")
          .eq("tipo_caja", "apertura")
          .gte("created_at", fechaHoy)
          .order('created_at', ascending: false)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Error al verificar la existencia de un registro de caja: $e');
    }
  }

  Future<Caja?> obtenerCajaAbierta() async {
    try {
      final fechaHoy = DateTime.now().toIso8601String().split('T').first;
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq("tipo_caja", "apertura")
          .gte("created_at", fechaHoy)
          .order('created_at', ascending: false)
          .limit(1);
      return response.isNotEmpty ? Caja.fromJson(response.first) : null;
    } catch (e) {
      throw Exception('Error al obtener el registro de caja abierta: $e');
    }
  }

  // Crear una nueva caja (apertura, cierre o conteo)
  Future<Caja> crearRegistroCaja(Caja caja) async {
    try {
      final response = await _supabase.from(_tableName).insert(caja.toJson()).select().single();

      return Caja.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear el registro de caja: $e');
    }
  }

  // Obtener el historial de caja en un rango de fechas
  Future<List<Caja>> obtenerHistorialCaja({required DateTime fechaInicio, required DateTime fechaFin}) async {
    try {
      final response = await _supabase.from(_tableName).select().order('created_at', ascending: false);

      return response.map<Caja>((json) => Caja.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener el historial de caja: $e');
    }
  }

  // Obtener el resumen de caja del día actual
  Future<Map<String, dynamic>> obtenerResumenCajaDia() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Obtener registros de caja del día actual
      final registros = await obtenerHistorialCaja(fechaInicio: startOfDay, fechaFin: now);

      if (registros.isEmpty) {
        return {'totalVentas': 0, 'totalEfectivo': 0, 'totalTarjeta': 0, 'saldoInicial': 0, 'saldoFinal': 0, 'registros': []};
      }

      // Obtener el registro de apertura de caja (si existe)
      final apertura = registros.firstWhere((c) => c.tipoCaja == TipoCaja.apertura, orElse: () => Caja());

      // Obtener el registro de cierre de caja (si existe)
      final cierre = registros.firstWhere((c) => c.tipoCaja == TipoCaja.cierre, orElse: () => Caja());

      // Calcular totales (esto es un ejemplo, ajusta según tu lógica de negocio)
      double totalVentas = 0;
      double totalEfectivo = 0;
      double totalTarjeta = 0;

      return {
        'totalVentas': totalVentas,
        'totalEfectivo': totalEfectivo,
        'totalTarjeta': totalTarjeta,
        'saldoInicial': apertura.valorTotal,
        'saldoFinal': cierre.valorTotal,
        'registros': registros,
      };
    } catch (e) {
      throw Exception('Error al obtener el resumen de caja: $e');
    }
  }
}
