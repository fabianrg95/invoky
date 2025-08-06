import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// Eliminando importación no utilizada
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

Future<void> mostrarDetalleProducto({
  required BuildContext context,
  required ProductoEditable producto,
  required ProductoService productoService,
  required CodigoBarrasService codigoBarrasService,
  required VoidCallback onStockActualizado,
}) async {
  // Controllers para los campos del formulario
  // Controllers para el formulario (comentados hasta que se implemente el formulario)
  // final nombreController = TextEditingController(text: producto.nombre);
  // final precioController = TextEditingController(text: producto.precio.toStringAsFixed(2));
  // final iva19Controller = TextEditingController(text: producto.iva19.toStringAsFixed(2));
  // final iva30Controller = TextEditingController(text: producto.iva30.toStringAsFixed(2));
  // final formKey = GlobalKey<FormState>();

  // Cargar el código de barras actual si existe
  if (producto.codigoBarras == null) {
    try {
      final codigo = await codigoBarrasService.obtenerPorProducto(producto.id);
      if (codigo != null) {
        producto.codigoBarras = codigo;
      }
    } catch (e) {
      debugPrint('Error al cargar código de barras: $e');
    }
  }

  showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider.value(
      value: producto,
      child: Consumer<ProductoEditable>(
        builder: (context, producto, _) {
          return AlertDialog(
            title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sección de nombre del producto
                    Row(
                      children: [
                        const Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(producto.nombre)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final nombreController = TextEditingController(text: producto.nombre);
                            final formKey = GlobalKey<FormState>();
                            bool isProcessing = false;

                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: const Text('Editar nombre del producto'),
                                    content: Form(
                                      key: formKey,
                                      child: TextFormField(
                                        controller: nombreController,
                                        decoration: const InputDecoration(
                                          labelText: 'Nuevo nombre',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor ingrese un nombre';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: isProcessing
                                            ? null
                                            : () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: isProcessing
                                            ? null
                                            : () async {
                                                if (formKey.currentState!.validate()) {
                                                  setState(() => isProcessing = true);
                                                  try {
                                                    await productoService.actualizarProducto(
                                                      productoId: producto.id,
                                                      nombre: nombreController.text,
                                                    );
                                                    producto.actualizarNombre(nombreController.text);
                                                    Navigator.pop(context, true);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Error al actualizar: $e'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                    setState(() => isProcessing = false);
                                                  }
                                                }
                                              },
                                        child: isProcessing
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text('Guardar'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                            
                            if (result == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nombre actualizado correctamente')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Sección de precios
                    Row(
                      children: [
                        const Text('Precio base:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('\$${producto.precio.toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final precioController = TextEditingController(
                              text: producto.precio.toStringAsFixed(2),
                            );
                            final formKey = GlobalKey<FormState>();
                            bool isProcessing = false;

                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: const Text('Actualizar precio'),
                                    content: Form(
                                      key: formKey,
                                      child: TextFormField(
                                        controller: precioController,
                                        decoration: const InputDecoration(
                                          labelText: 'Nuevo precio',
                                          prefixText: '\$ ',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor ingrese un precio';
                                          }
                                          final precio = double.tryParse(value);
                                          if (precio == null || precio <= 0) {
                                            return 'Ingrese un precio válido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: isProcessing
                                            ? null
                                            : () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: isProcessing
                                            ? null
                                            : () async {
                                                if (formKey.currentState!.validate()) {
                                                  setState(() => isProcessing = true);
                                                  try {
                                                    final nuevoPrecio = double.parse(precioController.text);
                                                    await productoService.actualizarProducto(
                                                      productoId: producto.id,
                                                      precioVenta: nuevoPrecio,
                                                    );
                                                    producto.actualizarPrecio(nuevoPrecio);
                                                    Navigator.pop(context, true);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Error al actualizar: $e'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                    setState(() => isProcessing = false);
                                                  }
                                                }
                                              },
                                        child: isProcessing
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text('Guardar'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                            
                            if (result == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Precio actualizado correctamente')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
              
                    _buildInfoRow('precio compra unidad:', '\$${producto.precioCompraUnidad.toStringAsFixed(2)}'),
              
                    const SizedBox(height: 8),
                    _buildInfoRow('IVA 19%:', '\$${producto.iva19.toStringAsFixed(2)}'),
              
                    const SizedBox(height: 8),
                    _buildInfoRow('IVA 30%:', '\$${producto.iva30.toStringAsFixed(2)}'),
              
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Stock disponible:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        Row(
                          children: [
                            Text(
                              '${producto.stock} unidad(es)',
                              style: const TextStyle(color: Colors.blue),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async {
                                final cantidadController = TextEditingController(text: producto.stock.toString());
                                final formKey = GlobalKey<FormState>();
                                bool isProcessing = false;
              
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: const Text('Actualizar stock'),
                                        content: Form(
                                          key: formKey,
                                          child: TextFormField(
                                            controller: cantidadController,
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              labelText: 'Cantidad en stock',
                                              border: OutlineInputBorder(),
                                              hintText: 'Ingrese la cantidad',
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Por favor ingrese una cantidad';
                                              }
                                              final cantidad = int.tryParse(value);
                                              if (cantidad == null || cantidad < 0) {
                                                return 'Ingrese un número válido';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: isProcessing ? null : () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: isProcessing
                                                ? null
                                                : () async {
                                                    if (formKey.currentState!.validate()) {
                                                      setState(() => isProcessing = true);
                                                      try {
                                                        final nuevaCantidad = int.parse(cantidadController.text);
                                                        await productoService.actualizarStock(
                                                          productoId: producto.id,
                                                          cantidad: nuevaCantidad,
                                                        );
                                                        if (context.mounted) {
                                                          producto.actualizarStock(nuevaCantidad);
                                                          onStockActualizado();

                                                          Navigator.pop(context, true);
                                                        }
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                                          );
                                                        }
                                                        setState(() => isProcessing = false);
                                                      }
                                                    }
                                                  },
                                            child: isProcessing
                                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                                : const Text('Actualizar'),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
              
                                if (result == true && context.mounted) {
                                  try {
                                    // Actualizar el producto localmente
                                    producto.actualizarStock(int.parse(cantidadController.text));
                                    // Notificar que el stock fue actualizado
                                    onStockActualizado();
                                    // Actualizar la UI
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Stock actualizado correctamente'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error al actualizar el stock: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
              
                    // Sección de código de barras
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Código de barras:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        if (producto.codigoBarras != null && producto.codigoBarras!.isNotEmpty) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.qr_code),
                            title: Text(producto.codigoBarras!, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () async {
                                    final codigoController = TextEditingController(text: producto.codigoBarras ?? '');
                                    final formKey = GlobalKey<FormState>();
                                    bool isProcessing = false;
              
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('Editar código de barras'),
                                            content: Form(
                                              key: formKey,
                                              child: TextFormField(
                                                controller: codigoController,
                                                autofocus: true,
                                                decoration: const InputDecoration(
                                                  labelText: 'Código de barras',
                                                  border: OutlineInputBorder(),
                                                  hintText: 'Escanee el código de barras',
                                                ),
                                                keyboardType: TextInputType.number,
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
                                                onPressed: isProcessing ? null : () => Navigator.pop(context, false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: isProcessing
                                                    ? null
                                                    : () async {
                                                        if (formKey.currentState!.validate()) {
                                                          setState(() => isProcessing = true);
                                                          try {
                                                            await codigoBarrasService.crearOActualizar(
                                                              productoId: producto.id,
                                                              codigo: codigoController.text,
                                                            );
                                                            if (context.mounted) {
                                                              Navigator.pop(context, true);
                                                            }
                                                          } catch (e) {
                                                            if (context.mounted) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                                                            }
                                                            setState(() => isProcessing = false);
                                                          }
                                                        }
                                                      },
                                                child: isProcessing
                                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                                    : const Text('Guardar'),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    );
              
                                    if (result == true && context.mounted) {
                                      try {
                                        // Actualizar el producto localmente
                                        producto.actualizarCodigoBarras(codigoController.text);
              
                                        // Mostrar mensaje de éxito
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Código de barras actualizado correctamente'), backgroundColor: Colors.green),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red));
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          TextButton.icon(
                            onPressed: () async {
                              final codigoController = TextEditingController();
                              final formKey = GlobalKey<FormState>();
                              bool isProcessing = false;
              
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text('Agregar código de barras'),
                                      content: Form(
                                        key: formKey,
                                        child: TextFormField(
                                          controller: codigoController,
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Código de barras',
                                            border: OutlineInputBorder(),
                                            hintText: 'Escanee el código de barras',
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Por favor ingrese un código';
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: (value) async {
                                                    if (formKey.currentState!.validate()) {
                                                      setState(() => isProcessing = true);
                                                      try {
                                                        await codigoBarrasService.crearOActualizar(
                                                          productoId: producto.id,
                                                          codigo: codigoController.text,
                                                        );
                                                        if (context.mounted) {
                                                          Navigator.pop(context, true);
                                                        }
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                                                        }
                                                        setState(() => isProcessing = false);
                                                      }
                                                    }
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(onPressed: isProcessing ? null : () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                        TextButton(
                                          onPressed: isProcessing
                                              ? null
                                              : () async {
                                                  if (formKey.currentState!.validate()) {
                                                    setState(() => isProcessing = true);
                                                    try {
                                                      await codigoBarrasService.crearOActualizar(
                                                        productoId: producto.id,
                                                        codigo: codigoController.text,
                                                      );
                                                      if (context.mounted) {
                                                        Navigator.pop(context, true);
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                                                      }
                                                      setState(() => isProcessing = false);
                                                    }
                                                  }
                                                },
                                          child: isProcessing
                                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                              : const Text('Agregar'),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
              
                              if (result == true && context.mounted) {
                                try {
                                  // Actualizar el producto localmente
                                  producto.actualizarCodigoBarras(codigoController.text);
              
                                  // Mostrar mensaje de éxito
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Código de barras agregado correctamente'), backgroundColor: Colors.green),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red));
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Agregar código de barras'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
          );
        },
      ),
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
