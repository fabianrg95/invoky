import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:inventario_tienda/models/producto_editable.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../services/codigo_barras_service.dart';
import '../services/inventario_service.dart';
import '../utils/dialog_utils.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  late Future<List<Producto>> _productosFuture;
  final ProductoService _productoService = ProductoService();
  String _filtroNombre = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _productosFuture = _productoService.listarProductos();
    });
  }

  Future<void> _abrirBusquedaPorCodigo() async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Buscar producto por código de barras'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Escanea el código de barras'),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.pop(context, value);
              }
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Buscar'))],
        );
      },
    );

    if (!mounted || codigo == null || codigo.isEmpty) return;

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Buscar el producto
      final producto = await _productoService.obtenerProductoPorCodigo(codigo);

      if (!mounted) return;

      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      if (producto == null) {
        _mostrarMensajeError('No se encontró ningún producto con ese código.');
        return;
      }

      // Mostrar diálogo de carga para detalles
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Cargar detalles del producto
      final productoDetallado = await _productoService.obtenerProductoDetallado(producto.id);

      if (!mounted) return;

      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      final productoEditable = ProductoEditable(
        id: productoDetallado.id,
        nombre: productoDetallado.nombre,
        precio: productoDetallado.precio,
        iva19: productoDetallado.iva19,
        iva30: productoDetallado.iva30,
        codigoBarras: productoDetallado.codigoBarras,
        stock: productoDetallado.stock,
      );
      await mostrarDetalleProducto(
        context: context,
        producto: productoEditable,
        productoService: ProductoService(),
        codigoBarrasService: CodigoBarrasService(),
      );
    } catch (e) {
      if (mounted) {
        // Cerrar cualquier diálogo de carga abierto
        Navigator.of(context, rootNavigator: true).pop();
        _mostrarMensajeError('Error al buscar el producto: $e');
      }
    }
  }

  void _mostrarMensajeError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar'))],
      ),
    );
  }

  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _mostrarModalNuevoProducto() async {
    final codigoBarrasController = TextEditingController();
    final nombreController = TextEditingController();
    final valorCompraController = TextEditingController();
    final valorVentaController = TextEditingController();
    final cantidadStockController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();
    bool guardando = false;
    bool ivaIncluido = false;
    double iva19 = 0.0;
    double iva30 = 0.0;
    final productoService = ProductoService();
    final inventarioService = InventarioService();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 24, right: 24, top: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nuevo Producto',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    campoTexto(nombreController, theme, 'Nombre', 'Por favor ingrese un nombre'),
                    const SizedBox(height: 20),
                    campoTexto(codigoBarrasController, theme, 'Código de barras', 'Por favor ingrese un código de barras'),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: campoTexto(
                            valorCompraController,
                            theme,
                            'Valor de compra por unidad',
                            'Por favor ingrese un valor de compra por unidad',
                            onChanged: (value) {
                              if (value != null && value.isNotEmpty) {
                                setModalState(() {
                                  final valor = double.parse(value);
                                  iva19 = valor * 0.19;
                                  iva30 = valor * 0.3;

                                  if (ivaIncluido) {
                                    valorVentaController.text = (valor + iva30).toStringAsFixed(2);
                                  } else {
                                    valorVentaController.text = (valor + iva19 + iva30).toStringAsFixed(2);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Checkbox(
                                value: ivaIncluido,
                                onChanged: (value) {
                                  setModalState(() {
                                    ivaIncluido = value ?? false;
                                    // Actualizar los cálculos cuando se cambia el checkbox
                                    if (valorCompraController.text.isNotEmpty) {
                                      final valor = double.parse(valorCompraController.text);
                                      iva19 = valor * 0.19;
                                      iva30 = valor * 0.3;

                                      if (ivaIncluido) {
                                        valorVentaController.text = (valor + iva30).toStringAsFixed(2);
                                      } else {
                                        valorVentaController.text = (valor + iva19 + iva30).toStringAsFixed(2);
                                      }
                                    }
                                  });
                                },
                              ),
                              const Text('IVA 19%\nincluido', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long, size: 18, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Text(
                                    'CÁLCULO DE IMPUESTOS',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow('Subtotal', '\$${valorCompraController.text.isEmpty ? '0.00' : valorCompraController.text}'),
                              _buildInfoRow('IVA 19%', '\$${iva19.toStringAsFixed(2)}', isHighlighted: true),
                              _buildInfoRow('IVA 30%', '\$${iva30.toStringAsFixed(2)}', isHighlighted: true),
                              const Divider(height: 20, thickness: 1),
                              _buildInfoRow(
                                'Total',
                                '\$${valorVentaController.text.isEmpty ? '0.00' : valorVentaController.text}',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: valorVentaController,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.green),
                          decoration: InputDecoration(
                            labelText: 'Precio de venta',
                            labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.green, width: 2),
                            ),
                            prefixText: '\$ ',
                            prefixStyle: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.w500),
                            hintText: '0.00',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el valor de venta';
                            }
                            final valor = double.tryParse(value);
                            if (valor == null || valor <= 0) {
                              return 'Ingrese un valor válido mayor a cero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        campoTexto(cantidadStockController, theme, 'Cantidad en stock', 'Por favor ingrese una cantidad en stock'),
                        const SizedBox(height: 20),
                      ],
                    ),
                    // Botones de acción
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Colors.blueGrey),
                            ),
                            child: guardando
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    'CANCELAR',
                                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                          ),
                        ),
                        ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: guardando
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setModalState(() {
                                          guardando = true;
                                        });

                                        try {
                                          // Guardar el producto
                                          final productoGuardado = await productoService.guardarProducto(
                                            nombre: nombreController.text,
                                            codigoBarras: codigoBarrasController.text,
                                            valorCompra: double.tryParse(valorCompraController.text) ?? 0.0,
                                            valorVenta: double.tryParse(valorVentaController.text) ?? 0.0,
                                          );

                                          // Actualizar el inventario
                                          final cantidad = int.tryParse(cantidadStockController.text) ?? 0;
                                          if (cantidad > 0) {
                                            await inventarioService.actualizarInventario(
                                              productoId: productoGuardado['id'],
                                              cantidad: cantidad,
                                              esNuevo: true,
                                            );
                                          }

                                          // Cerrar el modal y mostrar mensaje de éxito
                                          if (mounted) {
                                            Navigator.of(context).pop(true);
                                            _mostrarMensajeExito('Producto registrado exitosamente');
                                            // Recargar la lista de productos
                                            _cargarProductos();
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Error'),
                                                content: Text(e.toString()),
                                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar'))],
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setModalState(() {
                                              guardando = false;
                                            });
                                          }
                                        }
                                      }
                                    },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              child: const Text('GUARDAR PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  TextFormField campoTexto(TextEditingController controller, ThemeData theme, String label, String validatorMessage, {Function(String?)? onChanged}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(labelText: label, fillColor: theme.colorScheme.surfaceContainerHighest),
      validator: (value) {
        return value?.isNotEmpty == true ? null : validatorMessage;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? Colors.blue[800] : Colors.blueGrey[700],
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.green[700] : (isHighlighted ? Colors.blue[800] : Colors.blueGrey[700]),
              fontWeight: isTotal ? FontWeight.bold : (isHighlighted ? FontWeight.w600 : FontWeight.normal),
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{LogicalKeySet(LogicalKeyboardKey.keyB): const ActivateIntent()},
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              _abrirBusquedaPorCodigo();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Inventario'),
              actions: [
                IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _abrirBusquedaPorCodigo, tooltip: 'Escanear código de barras'),
              ],
            ),
            body: FutureBuilder<List<Producto>>(
              future: _productosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No hay productos registrados.'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _mostrarModalNuevoProducto,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Producto'),
                        ),
                      ],
                    ),
                  );
                }

                final productos = snapshot.data!;
                final productosMostrar = _filtroNombre.isEmpty
                    ? productos
                    : productos.where((p) => p.nombre.toLowerCase().contains(_filtroNombre.toLowerCase())).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por nombre',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _filtroNombre = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: productosMostrar.length,
                        itemBuilder: (context, index) {
                          final producto = productosMostrar[index];
                          final precio = producto.precio;
                          final hasStock = producto.stock > 0;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              leading: CircleAvatar(
                                backgroundColor: hasStock ? Colors.green[100] : Colors.grey[200],
                                child: Icon(hasStock ? Icons.inventory_2 : Icons.inventory_outlined, color: hasStock ? Colors.green : Colors.grey),
                              ),
                              title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Precio: \$${precio.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(hasStock ? Icons.check_circle : Icons.cancel, size: 16, color: hasStock ? Colors.green : Colors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasStock ? 'Disponible' : 'Sin stock',
                                        style: TextStyle(color: hasStock ? Colors.green : Colors.red, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () async {
                                // Mostrar diálogo de carga
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                );

                                try {
                                  // Obtener los detalles del producto
                                  final productoDetallado = await _productoService.obtenerProductoDetallado(producto.id);

                                  // Cerrar el diálogo de carga
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    final productoEditable = ProductoEditable(
                                      id: productoDetallado.id,
                                      nombre: productoDetallado.nombre,
                                      precio: productoDetallado.precio,
                                      iva19: productoDetallado.iva19,
                                      iva30: productoDetallado.iva30,
                                      codigoBarras: productoDetallado.codigoBarras,
                                      stock: productoDetallado.stock,
                                    );
                                    await mostrarDetalleProducto(
                                      context: context,
                                      producto: productoEditable,
                                      productoService: ProductoService(),
                                      codigoBarrasService: CodigoBarrasService(),
                                    );
                                  }
                                } catch (e) {
                                  // Cerrar el diálogo de carga en caso de error
                                  if (mounted) {
                                    Navigator.of(context, rootNavigator: true).pop();
                                    _mostrarMensajeError('Error al cargar los detalles del producto: $e');
                                  }
                                }
                              },
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _mostrarModalNuevoProducto,
              tooltip: 'Agregar nuevo producto',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
