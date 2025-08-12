import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';
import '../services/venta_service.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}

class _ItemCarrito {
  final Producto producto;
  int cantidad;
  bool esVentaUnitaria;
  
  _ItemCarrito({
    required this.producto,
    required this.cantidad,
    this.esVentaUnitaria = false,
  });
  
  double get precioUnitario => esVentaUnitaria && producto.precioVentaUnidad != null
      ? producto.precioVentaUnidad!
      : producto.precioVenta;
      
  double get subtotal => cantidad * precioUnitario;
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final TextEditingController _codigoBarrasController = TextEditingController();
  final TextEditingController _busquedaController = TextEditingController();
  final FocusNode _codigoBarrasFocus = FocusNode();
  final InventarioService _inventarioService = InventarioService();
  
  List<Producto> _productosEncontrados = [];
  final List<_ItemCarrito> _carrito = [];
  bool _buscando = false;
  bool _mostrarBusqueda = false;

  @override
  void initState() {
    super.initState();
    _codigoBarrasFocus.requestFocus();
    // Configurar el listener para detectar cuando se escanea un código de barras
    _codigoBarrasController.addListener(_onCodigoBarrasChanged);
  }

  Future<void> _mostrarDialogoCantidad(Producto producto, int cantidadActual, bool esVentaUnitaria) async {
    final cantidadController = TextEditingController(text: cantidadActual.toString());
    
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar cantidad'),
        content: TextField(
          controller: cantidadController,
          decoration: const InputDecoration(
            labelText: 'Cantidad',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
          onSubmitted: (_) => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevaCantidad = int.tryParse(cantidadController.text) ?? 1;
              if (nuevaCantidad > 0) {
                _actualizarCantidad(producto, nuevaCantidad);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La cantidad debe ser mayor a 0'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('ACEPTAR'),
          ),
        ],
      ),
    );
  }
  
  void _actualizarCantidad(Producto producto, int nuevaCantidad) {
    setState(() {
      final index = _carrito.indexWhere((item) => item.producto.id == producto.id);
      if (index >= 0) {
        if (nuevaCantidad > 0) {
          _carrito[index].cantidad = nuevaCantidad;
        } else {
          _carrito.removeAt(index);
        }
      }
    });
  }

  Future<void> _mostrarDialogoPago() async {
    final medioPago = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Método de pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.blue),
              title: const Text('Tarjeta de crédito'),
              onTap: () => Navigator.pop(context, 1), // ID para tarjeta
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text('Efectivo'),
              onTap: () => Navigator.pop(context, 2), // ID para efectivo
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('CANCELAR'),
          ),
        ],
      ),
    );

    if (medioPago != null) {
      if (medioPago == 1) {
        // Pago con tarjeta
        await _procesarVenta(medioPago, _calcularTotal());
      } else {
        // Pago en efectivo
        await _procesarVenta(medioPago, null);
      }
    }
  }

  Future<void> _procesarVenta(int medioPagoId, double? valorTarjeta) async {
    if (_carrito.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final ventaService = VentaService();
      
      // Preparar los productos para la venta
      final productosVenta = _carrito.map((item) => {
        'producto_id': item.producto.id,
        'cantidad': item.cantidad,
        'precio_venta': item.precioUnitario,
        'es_venta_unitaria': item.esVentaUnitaria,
      }).toList();

      // Crear la venta
      final venta = await ventaService.crearVenta(
        productos: productosVenta,
        medioPagoId: medioPagoId,
        valorPagoTarjeta: valorTarjeta,
      );

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
        
        // Mostrar mensaje de éxito
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Venta registrada'),
            content: Text('Venta #${venta.id} registrada exitosamente.\n\nTotal: \$${venta.valorTotalVenta?.toStringAsFixed(2) ?? '0.00'}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar diálogo de éxito
                  setState(() {
                    _carrito.clear(); // Limpiar carrito
                    _codigoBarrasFocus.requestFocus(); // Volver al campo de código de barras
                  });
                },
                child: const Text('ACEPTAR'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
        
        // Mostrar mensaje de error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error al procesar la venta: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ACEPTAR'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _codigoBarrasController.dispose();
    _busquedaController.dispose();
    _codigoBarrasFocus.dispose();
    super.dispose();
  }

  void _onCodigoBarrasChanged() {
    // Cuando el campo de código de barras tiene un valor y termina con un salto de línea
    // asumimos que se ha escaneado un código de barras
    if (_codigoBarrasController.text.endsWith('\n')) {
      final codigo = _codigoBarrasController.text.trim();
      if (codigo.isNotEmpty) {
        _buscarProductoPorCodigo(codigo);
      }
    }
  }

  Future<void> _buscarProductoPorCodigo(String codigo) async {
    setState(() {
      _buscando = true;
    });

    try {
      final producto = await _inventarioService.buscarProductoPorCodigo(codigo);
      if (producto != null) {
        _agregarProductoAlCarrito(producto);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto no encontrado')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar el producto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _buscando = false;
          _codigoBarrasController.clear();
          _codigoBarrasFocus.requestFocus();
        });
      }
    }
  }

  Future<void> _buscarProductosPorNombre(String query) async {
    if (query.isEmpty) {
      setState(() {
        _productosEncontrados = [];
      });
      return;
    }

    setState(() {
      _buscando = true;
    });

    try {
      final productos = await _inventarioService.buscarProductos(query);
      setState(() {
        _productosEncontrados = productos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar productos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _buscando = false;
        });
      }
    }
  }

  void _agregarProductoAlCarrito(Producto producto) {
    setState(() {
      // Buscar si el producto ya está en el carrito
      final index = _carrito.indexWhere((item) => item.producto.id == producto.id);
      
      if (index >= 0) {
        // Si el producto ya está en el carrito, incrementar la cantidad
        _carrito[index].cantidad++;
      } else {
        // Si no está en el carrito, preguntar si es venta unitaria (si aplica)
        if (producto.permiteVentaUnitaria && producto.precioVentaUnidad != null) {
          showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tipo de venta'),
              content: const Text('¿Desea vender este producto por unidad?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sí, por unidad'),
                ),
              ],
            ),
          ).then((esVentaUnitaria) {
            if (esVentaUnitaria != null) {
              setState(() {
                _carrito.add(_ItemCarrito(
                  producto: producto,
                  cantidad: 1,
                  esVentaUnitaria: esVentaUnitaria,
                ));
                _mostrarMensajeProductoAgregado(producto, esVentaUnitaria);
              });
            }
          });
          return;
        } else {
          _carrito.add(_ItemCarrito(
            producto: producto,
            cantidad: 1,
          ));
        }
      }
      
      _mostrarMensajeProductoAgregado(producto, false);
    });
  }
  
  void _mostrarMensajeProductoAgregado(Producto producto, bool esVentaUnitaria) {
    if (!mounted) return;
    
    final precio = esVentaUnitaria && producto.precioVentaUnidad != null
        ? producto.precioVentaUnidad!
        : producto.precioVenta;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agregado: ${producto.nombre} (\$${precio.toStringAsFixed(2)})'),
      ),
    );
  }
  
  void _incrementarCantidad(int index) {
    setState(() {
      _carrito[index].cantidad++;
    });
  }
  
  void _decrementarCantidad(int index) {
    setState(() {
      if (_carrito[index].cantidad > 1) {
        _carrito[index].cantidad--;
      } else {
        _carrito.removeAt(index);
      }
    });
  }
  
  void _eliminarDelCarrito(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }
  
  void _alternarVentaUnitaria(int index) {
    setState(() {
      final item = _carrito[index];
      if (item.producto.permiteVentaUnitaria && item.producto.precioVentaUnidad != null) {
        _carrito[index] = _ItemCarrito(
          producto: item.producto,
          cantidad: item.cantidad,
          esVentaUnitaria: !item.esVentaUnitaria,
        );
      }
    });
  }
  
  double _calcularTotal() {
    return _carrito.fold(0.0, (total, item) => total + item.subtotal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        actions: [
          IconButton(
            icon: Icon(_mostrarBusqueda ? Icons.barcode_reader : Icons.search),
            onPressed: () {
              setState(() {
                _mostrarBusqueda = !_mostrarBusqueda;
                if (!_mostrarBusqueda) {
                  _busquedaController.clear();
                  _productosEncontrados = [];
                  _codigoBarrasFocus.requestFocus();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de código de barras (siempre visible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _codigoBarrasController,
              focusNode: _codigoBarrasFocus,
              decoration: InputDecoration(
                labelText: 'Código de barras',
                hintText: 'Escanea o ingresa el código de barras',
                border: const OutlineInputBorder(),
                suffixIcon: _buscando
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : null,
              ),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              autofocus: true,
            ),
          ),
          
          // Campo de búsqueda por nombre (se muestra/oculta)
          if (_mostrarBusqueda)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _busquedaController,
                decoration: InputDecoration(
                  labelText: 'Buscar producto por nombre',
                  hintText: 'Ingresa el nombre del producto',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _buscando
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : _busquedaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _busquedaController.clear();
                                _productosEncontrados = [];
                              },
                            )
                          : null,
                ),
                onChanged: _buscarProductosPorNombre,
              ),
            ),
          
          // Lista de productos encontrados
          if (_productosEncontrados.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _productosEncontrados.length,
                itemBuilder: (context, index) {
                  final producto = _productosEncontrados[index];
                  return ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text('Código: ${producto.codigoBarras ?? 'N/A'}'),
                    trailing: Text('\$${producto.precioVenta.toStringAsFixed(2)}'),
                    onTap: () {
                      _agregarProductoAlCarrito(producto);
                      setState(() {
                        _productosEncontrados = [];
                        _busquedaController.clear();
                        _codigoBarrasFocus.requestFocus();
                      });
                    },
                  );
                },
              ),
            ),
          
          // Resumen de la venta (carrito)
          Expanded(
            child: _carrito.isEmpty
                ? const Center(
                    child: Text(
                      'El carrito está vacío\nEscanea o busca productos para agregar',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Productos en el carrito',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _carrito.length,
                          itemBuilder: (context, index) {
                            final item = _carrito[index];
                            final producto = item.producto;
                            final cantidad = item.cantidad;
                            final subtotal = item.subtotal;
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                title: Text(producto.nombre),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cantidad: $cantidad'),
                                    Text(
                                      '\$${item.precioUnitario.toStringAsFixed(2)} c/u ${item.esVentaUnitaria ? '(Unidad)' : ''}',
                                      style: TextStyle(
                                        color: item.esVentaUnitaria ? Colors.green : null,
                                        fontWeight: item.esVentaUnitaria ? FontWeight.bold : null,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$${subtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => _decrementarCantidad(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _incrementarCantidad(index),
                                      tooltip: 'Aumentar cantidad',
                                    ),
                                    if (producto.permiteVentaUnitaria && producto.precioVentaUnidad != null)
                                      IconButton(
                                        icon: Icon(
                                          Icons.swap_horiz,
                                          color: item.esVentaUnitaria ? Colors.green : Colors.blue,
                                        ),
                                        onPressed: () => _alternarVentaUnitaria(index),
                                        tooltip: item.esVentaUnitaria ? 'Cambiar a venta normal' : 'Cambiar a venta por unidad',
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      onPressed: () => _mostrarDialogoCantidad(producto, cantidad, item.esVentaUnitaria),
                                      tooltip: 'Editar cantidad',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _eliminarDelCarrito(index),
                                      tooltip: 'Eliminar producto',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_calcularTotal().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          
          // Botón de finalizar venta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _carrito.isEmpty
                  ? null
                  : () {
                      // TODO: Implementar lógica de finalizar venta
                      _mostrarDialogoPago();
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _carrito.isEmpty ? Colors.grey : Theme.of(context).primaryColor,
              ),
              child: const Text(
                'FINALIZAR VENTA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
