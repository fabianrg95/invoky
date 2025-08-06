class CodigoBarras {
  final String id;
  final String productoId;
  final String codigoBarras;

  CodigoBarras({
    required this.id,
    required this.productoId,
    required this.codigoBarras,
  });

  factory CodigoBarras.fromMap(Map<String, dynamic> map) {
    return CodigoBarras(
      id: map['id'].toString(),
      productoId: map['producto_id'].toString(),
      codigoBarras: map['codigo_barras'].toString(),
    );
  }
}
