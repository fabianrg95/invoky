import 'package:intl/intl.dart';

enum TipoCaja { apertura, cierre, conteo }

class Caja {
  final DateTime createdAt;
  final TipoCaja? tipoCaja;
  final int cantidadBillete100000;
  final int cantidadBillete50000;
  final int cantidadBillete20000;
  final int cantidadBillete10000;
  final int cantidadBillete5000;
  final int cantidadBillete2000;
  final int cantidadMoneda1000;
  final int cantidadMoneda500;
  final int cantidadMoneda200;
  final int cantidadMoneda100;
  final int cantidadMoneda50;
  final int valorTotal;
  final int? valorTotalVentas;

  Caja({
    DateTime? createdAt,
    this.tipoCaja,
    this.cantidadBillete100000 = 0,
    this.cantidadBillete50000 = 0,
    this.cantidadBillete20000 = 0,
    this.cantidadBillete10000 = 0,
    this.cantidadBillete5000 = 0,
    this.cantidadBillete2000 = 0,
    this.cantidadMoneda1000 = 0,
    this.cantidadMoneda500 = 0,
    this.cantidadMoneda200 = 0,
    this.cantidadMoneda100 = 0,
    this.cantidadMoneda50 = 0,
    this.valorTotal = 0,
    this.valorTotalVentas = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Caja.fromJson(Map<String, dynamic> json) {
    return Caja(
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      tipoCaja: _parseTipoCaja(json['tipo_caja'] as String?),
      cantidadBillete100000: (json['cantidad_billete_100000'] as int?) ?? 0,
      cantidadBillete50000: (json['cantidad_billete_50000'] as int?) ?? 0,
      cantidadBillete20000: (json['cantidad_billete_20000'] as int?) ?? 0,
      cantidadBillete10000: (json['cantidad_billete_10000'] as int?) ?? 0,
      cantidadBillete5000: (json['cantidad_billete_5000'] as int?) ?? 0,
      cantidadBillete2000: (json['cantidad_billete_2000'] as int?) ?? 0,
      cantidadMoneda1000: (json['cantidad_moneda_1000'] as int?) ?? 0,
      cantidadMoneda500: (json['cantidad_moneda_500'] as int?) ?? 0,
      cantidadMoneda200: (json['cantidad_moneda_200'] as int?) ?? 0,
      cantidadMoneda100: (json['cantidad_moneda_100'] as int?) ?? 0,
      cantidadMoneda50: (json['cantidad_moneda_50'] as int?) ?? 0,
      valorTotal: json['valor_total'] as int,
      valorTotalVentas: json['valor_total_ventas'] as int,
    );
  }

  static TipoCaja? _parseTipoCaja(String? tipo) {
    if (tipo == null) return null;
    return TipoCaja.values.firstWhere(
      (e) => e.toString().split('.').last == tipo,
      orElse: () => throw Exception('Tipo de caja no válido: $tipo'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'tipo_caja': tipoCaja?.toString().split('.').last,
      'cantidad_billete_100000': cantidadBillete100000,
      'cantidad_billete_50000': cantidadBillete50000,
      'cantidad_billete_20000': cantidadBillete20000,
      'cantidad_billete_10000': cantidadBillete10000,
      'cantidad_billete_5000': cantidadBillete5000,
      'cantidad_billete_2000': cantidadBillete2000,
      'cantidad_moneda_1000': cantidadMoneda1000,
      'cantidad_moneda_500': cantidadMoneda500,
      'cantidad_moneda_200': cantidadMoneda200,
      'cantidad_moneda_100': cantidadMoneda100,
      'cantidad_moneda_50': cantidadMoneda50,
      'valor_total': valorTotal,
      'valor_total_ventas': valorTotalVentas,
    };
  }

  // Método para calcular el valor total basado en las cantidades
  int calcularValorTotal() {
    return (cantidadBillete100000 * 100000) +
           (cantidadBillete50000 * 50000) +
           (cantidadBillete20000 * 20000) +
           (cantidadBillete10000 * 10000) +
           (cantidadBillete5000 * 5000) +
           (cantidadBillete2000 * 2000) +
           (cantidadMoneda1000 * 1000) +
           (cantidadMoneda500 * 500) +
           (cantidadMoneda200 * 200) +
           (cantidadMoneda100 * 100) +
           (cantidadMoneda50 * 50);
  }

  // Método para formatear la fecha
  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  // Método para obtener el nombre del tipo de caja
  String? get nombreTipoCaja {
    if (tipoCaja == null) return null;
    switch (tipoCaja!) {
      case TipoCaja.apertura:
        return 'Apertura';
      case TipoCaja.cierre:
        return 'Cierre';
      case TipoCaja.conteo:
        return 'Conteo';
    }
  }

  // Método para crear una copia del modelo con algunos valores actualizados
  Caja copyWith({
    int? id,
    DateTime? createdAt,
    TipoCaja? tipoCaja,
    int? cantidadBillete100000,
    int? cantidadBillete50000,
    int? cantidadBillete20000,
    int? cantidadBillete10000,
    int? cantidadBillete5000,
    int? cantidadBillete2000,
    int? cantidadMoneda1000,
    int? cantidadMoneda500,
    int? cantidadMoneda200,
    int? cantidadMoneda100,
    int? cantidadMoneda50,
    int? valorTotal,
    int? valorTotalVentas,
  }) {
    return Caja(
      createdAt: createdAt ?? this.createdAt,
      tipoCaja: tipoCaja ?? this.tipoCaja,
      cantidadBillete100000: cantidadBillete100000 ?? this.cantidadBillete100000,
      cantidadBillete50000: cantidadBillete50000 ?? this.cantidadBillete50000,
      cantidadBillete20000: cantidadBillete20000 ?? this.cantidadBillete20000,
      cantidadBillete10000: cantidadBillete10000 ?? this.cantidadBillete10000,
      cantidadBillete5000: cantidadBillete5000 ?? this.cantidadBillete5000,
      cantidadBillete2000: cantidadBillete2000 ?? this.cantidadBillete2000,
      cantidadMoneda1000: cantidadMoneda1000 ?? this.cantidadMoneda1000,
      cantidadMoneda500: cantidadMoneda500 ?? this.cantidadMoneda500,
      cantidadMoneda200: cantidadMoneda200 ?? this.cantidadMoneda200,
      cantidadMoneda100: cantidadMoneda100 ?? this.cantidadMoneda100,
      cantidadMoneda50: cantidadMoneda50 ?? this.cantidadMoneda50,
      valorTotal: valorTotal ?? this.valorTotal,
      valorTotalVentas: valorTotalVentas ?? this.valorTotalVentas,
    );
  }
}
