import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../models/producto_editable.dart';
import '../services/codigo_barras_service.dart';
import '../services/producto_service.dart';

Future<T?> showLoadingDialog<T>({required BuildContext context, required Future<T> future, String message = 'Cargando...'}) async {
  bool isDialogOpen = true;

  // Cerrar el diálogo automáticamente después de un tiempo como medida de seguridad
  Future.delayed(const Duration(seconds: 30), () {
    if (isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('La operación está tomando más tiempo de lo esperado'), duration: Duration(seconds: 2)));
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
            content: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(message)]),
          ),
        );
      },
    );
  } finally {
    isDialogOpen = false;
  }
}

void mostrarDetalleProducto(BuildContext context, Producto producto) {
  final productoEditable = ProductoEditable.fromProducto(producto);
  final codigoBarrasService = CodigoBarrasService();
  final productoService = ProductoService();

  showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider.value(
      value: productoEditable,
      child: Consumer<ProductoEditable>(
        builder: (context, producto, _) {
          return AlertDialog(
            title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sección de precios
                  _buildInfoRow('Precio base:', '\$${producto.precio.toStringAsFixed(2)}'),
                  const Divider(),

                  _buildInfoRow('IVA 19%:', '\$${producto.iva19.toStringAsFixed(2)}'),

                  const SizedBox(height: 8),
                  _buildInfoRow('IVA 30%:', '\$${producto.iva30.toStringAsFixed(2)}'),

                  const Divider(),
                  _buildInfoRow('Stock disponible:', '${producto.stock} unidades', color: producto.stock > 0 ? Colors.blue : Colors.red),

                  // Sección de códigos de barras
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Códigos de barras:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () async {
                          final codigoController = TextEditingController();
                          final formKey = GlobalKey<FormState>();

                          // Variable para controlar si ya se está procesando un código
                          bool isProcessing = false;
                          
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) {
                                // Referencia para el foco
                                final focusNode = FocusNode();
                                
                                // Enfocar automáticamente al mostrar el diálogo
                                Future.delayed(Duration.zero, () {
                                  focusNode.requestFocus();
                                });
                                
                                return AlertDialog(
                                  title: const Text('Agregar código de barras'),
                                  content: Form(
                                    key: formKey,
                                    child: TextFormField(
                                      controller: codigoController,
                                      focusNode: focusNode,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Código de barras', 
                                        border: OutlineInputBorder(),
                                        hintText: 'Escanee el código de barras',
                                      ),
                                      keyboardType: TextInputType.number,
                                      // Validar automáticamente al cambiar el texto
                                      onFieldSubmitted: (value) async {
                                          if (value.isNotEmpty) {
                                          isProcessing = true;
                                          
                                          if (formKey.currentState!.validate() && context.mounted) {
                                            final scaffold = ScaffoldMessenger.of(context);
                                            try {
                                              // Mostrar diálogo de carga
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return const AlertDialog(
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        CircularProgressIndicator(),
                                                        SizedBox(height: 16),
                                                        Text('Agregando código de barras...'),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );

                                              await codigoBarrasService.agregarCodigoBarras(
                                                productoId: producto.id, 
                                                codigo: value
                                              );
                                              
                                              if (context.mounted) {
                                                Navigator.pop(context); // Cerrar diálogo de carga
                                                Navigator.pop(context, true); // Cerrar diálogo de agregar
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                Navigator.pop(context); // Cerrar diálogo de carga si está abierto
                                                scaffold.showSnackBar(
                                                  SnackBar(content: Text(e.toString()))
                                                );
                                                // Volver a enfocar el campo
                                                focusNode.requestFocus();
                                              }
                                              isProcessing = false;
                                            }
                                          } else {
                                            isProcessing = false;
                                          }
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingrese un código';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false), 
                                      child: const Text('Cancelar')
                                    ),
                                  ],
                                );
                              },
                            )
                          );

                          if (result == true) {
                            // Actualizar la lista de códigos de barras
                            final productoActualizado = await productoService.obtenerProductoDetallado(producto.id);
                            if (productoActualizado != null && context.mounted) {
                              producto.actualizarCodigosBarras(productoActualizado.codigosBarras);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (producto.codigosBarras.isNotEmpty) ...[
                    ...producto.codigosBarras
                        .map(
                          (codigo) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.qr_code),
                            title: Text(codigo, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () async {
                                final scaffold = ScaffoldMessenger.of(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar código'),
                                    content: const Text('¿Está seguro de eliminar este código de barras?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false), 
                                        child: const Text('Cancelar')
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && context.mounted) {
                                  // Mostrar diálogo de carga
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text('Eliminando código de barras...'),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  try {
                                    await _eliminarCodigoBarras(context, producto, codigo, codigoBarrasService, productoService);
                                    
                                    if (context.mounted) {
                                      Navigator.pop(context); // Cerrar diálogo de carga
                                      
                                      // Actualizar la lista de códigos de barras
                                      final productoActualizado = await productoService.obtenerProductoDetallado(producto.id);
                                      if (productoActualizado != null && context.mounted) {
                                        producto.actualizarCodigosBarras(productoActualizado.codigosBarras);
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context); // Cerrar diálogo de carga
                                      scaffold.showSnackBar(
                                        SnackBar(
                                          content: Text('Error al eliminar: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          )
                        )
                        .toList(),
                  ],
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
          );
        },
      ),
    ),
  );
}

Future<bool> _eliminarCodigoBarras(
  BuildContext context,
  ProductoEditable producto,
  String codigo,
  CodigoBarrasService codigoBarrasService,
  ProductoService productoService,
) async {
  try {
    // Obtener el ID del código de barras
    final codigos = await codigoBarrasService.obtenerPorProducto(producto.id);
    final codigoAEliminar = codigos.firstWhere(
      (cb) => cb.codigoBarras == codigo,
      orElse: () => throw Exception('Código de barras no encontrado'),
    );

    await codigoBarrasService.eliminarCodigoBarras(codigoAEliminar.id);
    return true;
  } catch (e) {
    rethrow;
  }
}

Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color),
        ),
      ],
    ),
  );
}
