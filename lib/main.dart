import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'models/producto.dart';
import 'services/producto_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Tienda',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Producto>> _productosFuture;
  final ProductoService _productoService = ProductoService();

  @override
  void initState() {
    super.initState();
    _productosFuture = _productoService.obtenerProductos();
  }

  Future<void> _abrirBusquedaPorCodigo(BuildContext context) async {
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
              Navigator.pop(context, value);
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Buscar'))],
        );
      },
    );
    if (!mounted) return;
    if (codigo != null && codigo.isNotEmpty) {
      final producto = await _productoService.obtenerProductoPorCodigo(codigo);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          if (producto == null) {
            return const AlertDialog(title: Text('No encontrado'), content: Text('No se encontró ningún producto con ese código.'));
          }
          return AlertDialog(title: Text(producto.nombre), content: Text('Precio: \\${producto.precio}'));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{LogicalKeySet(LogicalKeyboardKey.keyB): const ActivateIntent()},
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<Intent>(
            onInvoke: (Intent intent) {
              _abrirBusquedaPorCodigo(context);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Inventario Tienda'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  tooltip: 'Buscar por código de barras',
                  onPressed: () => _abrirBusquedaPorCodigo(context),
                ),
              ],
            ),
            body: FutureBuilder<List<Producto>>(
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
                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return ListTile(title: Text(producto.nombre), subtitle: Text('Precio: \\${producto.precio}'));
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
