import 'package:intl/intl.dart';

class Venta {
  final int? id;
  final DateTime createdAt;
  final double? valorTotalVenta;
  final int? medioPagoId;
  final double? valorPagoTarjetaCredito;
  final int? cantidadProductos;

  Venta({
    this.id,
    DateTime? createdAt,
    this.valorTotalVenta,
    this.medioPagoId,
    this.valorPagoTarjetaCredito,
    this.cantidadProductos,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      valorTotalVenta: json['valor_total_venta'] != null 
          ? double.tryParse(json['valor_total_venta'].toString()) 
          : null,
      medioPagoId: json['medio_pago_id'] as int?,
      valorPagoTarjetaCredito: json['valor_pago_tarjeta_credito'] != null 
          ? double.tryParse(json['valor_pago_tarjeta_credito'].toString()) 
          : null,
      cantidadProductos: json['cantidad_productos'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'valor_total_venta': valorTotalVenta,
      'medio_pago_id': medioPagoId,
      'valor_pago_tarjeta_credito': valorPagoTarjetaCredito,
      'cantidad_productos': cantidadProductos,
    };
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  Venta copyWith({
    int? id,
    DateTime? createdAt,
    double? valorTotalVenta,
    int? medioPagoId,
    double? valorPagoTarjetaCredito,
    int? cantidadProductos,
  }) {
    return Venta(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      valorTotalVenta: valorTotalVenta ?? this.valorTotalVenta,
      medioPagoId: medioPagoId ?? this.medioPagoId,
      valorPagoTarjetaCredito: valorPagoTarjetaCredito ?? this.valorPagoTarjetaCredito,
      cantidadProductos: cantidadProductos ?? this.cantidadProductos,
    );
  }
}
