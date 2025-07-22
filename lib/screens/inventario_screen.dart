import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

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
    _productosFuture = _productoService.obtenerProductos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Producto>>(
      future: _productosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
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
                decoration: const InputDecoration(labelText: 'Filtrar por nombre', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
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
                  return ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text('Precio: \\${producto.precio}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Detalle del producto'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [Text('ID: \\${producto.id}'), Text('Nombre: \\${producto.nombre}'), Text('Precio: ${producto.precio}')],
                              ),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                            );
                          },
                        );
                      },
                      child: const Text('Ver detalle'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
