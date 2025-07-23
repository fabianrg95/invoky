import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../services/codigo_barras_service.dart';
import '../models/producto_editable.dart';
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
    final productoService = ProductoService();
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text), 
              child: const Text('Buscar')
            )
          ],
        );
      },
    );
    
    if (!mounted || codigo == null || codigo.isEmpty) return;
    
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    
    try {
      // Buscar el producto
      final producto = await productoService.obtenerProductoPorCodigo(codigo);
      
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      // Cargar detalles del producto
      final productoDetallado = await productoService.obtenerProductoDetallado(producto.id);
      
      if (!mounted) return;
      
      // Cerrar el diálogo de carga
      Navigator.of(context).pop();
      
      if (productoDetallado != null) {
        final productoEditable = ProductoEditable(
          id: productoDetallado.id,
          nombre: productoDetallado.nombre,
          precio: productoDetallado.precio,
          iva19: productoDetallado.iva19,
          iva30: productoDetallado.iva30,
          codigoBarras: productoDetallado.codigoBarras,
        );
        await mostrarDetalleProducto(
          context: context,
          producto: productoEditable,
          productoService: ProductoService(),
          codigoBarrasService: CodigoBarrasService(),
        );
      }
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.keyB): const ActivateIntent(),
      },
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
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _abrirBusquedaPorCodigo,
            tooltip: 'Escanear código de barras',
          ),
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
            return const Center(child: Text('No hay productos registrados.'));
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
                    border: OutlineInputBorder()
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
                    final precioConIva = precio * (1 + (producto.iva19 / 100));
                    final hasStock = false;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: CircleAvatar(
                          backgroundColor: hasStock ? Colors.green[100] : Colors.grey[200],
                          child: Icon(
                            hasStock ? Icons.inventory_2 : Icons.inventory_outlined,
                            color: hasStock ? Colors.green : Colors.grey,
                          ),
                        ),
                        title: Text(
                          producto.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Precio: \$${precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  hasStock ? Icons.check_circle : Icons.cancel,
                                  size: 16,
                                  color: hasStock ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasStock ? 'Disponible' : 'Sin stock',
                                  style: TextStyle(
                                    color: hasStock ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          
                          try {
                            // Obtener los detalles del producto
                            final productoDetallado = await _productoService.obtenerProductoDetallado(producto.id);
                            
                            // Cerrar el diálogo de carga
                            if (mounted) {
                              Navigator.of(context).pop();
                              if (productoDetallado != null) {
final productoEditable = ProductoEditable(
                                  id: productoDetallado.id,
                                  nombre: productoDetallado.nombre,
                                  precio: productoDetallado.precio,
                                  iva19: productoDetallado.iva19,
                                  iva30: productoDetallado.iva30,
                                  codigoBarras: productoDetallado.codigoBarras,
                                );
                                await mostrarDetalleProducto(
                                  context: context,
                                  producto: productoEditable,
                                  productoService: ProductoService(),
                                  codigoBarrasService: CodigoBarrasService(),
                                );
                              } else {
                                _mostrarMensajeError('No se pudieron cargar los detalles del producto');
                              }
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
          ),
        ),
      ),
    );
  }
}
