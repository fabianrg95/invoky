import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';

Future<T?> showLoadingDialog<T>({
  required BuildContext context,
  required Future<T> future,
  String message = 'Cargando...',
}) async {
  bool isDialogOpen = true;
  
  // Cerrar el diálogo automáticamente después de un tiempo como medida de seguridad
  Future.delayed(const Duration(seconds: 30), () {
    if (isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La operación está tomando más tiempo de lo esperado'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  });

  try {
    return await showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  } finally {
    isDialogOpen = false;
  }
}

void mostrarDetalleProducto(BuildContext context, Producto producto) {
  final precio = producto.precio;
  final iva19 = producto.iva19;
  final iva30 = producto.iva30;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        producto.nombre,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sección de precios
            _buildInfoRow('Precio base:', '\$${precio.toStringAsFixed(2)}'),
            const Divider(),
            
            _buildInfoRow('IVA 19%:', '\$${iva19.toStringAsFixed(2)}'),
            
            const SizedBox(height: 8),
            _buildInfoRow('IVA 30%:', '\$${iva30.toStringAsFixed(2)}'),
            
            const Divider(),
            _buildInfoRow('Stock disponible:', '${producto.stock} unidades',
                color: producto.stock > 0 ? Colors.blue : Colors.red),
            
            // Sección de códigos de barras
            if (producto.codigosBarras.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Códigos de barras:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...producto.codigosBarras.map((codigo) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '• $codigo',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              )).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    ),
  );
}
