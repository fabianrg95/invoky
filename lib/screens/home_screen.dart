import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import 'inventario_screen.dart';
import 'ventas_screen.dart';
import 'reportes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum MenuOption { inicio, inventario, ventas, reportes }

class _HomeScreenState extends State<HomeScreen> {
  MenuOption _selectedOption = MenuOption.inicio;

  Future<void> _abrirBusquedaPorCodigo(BuildContext context) async {
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
              Navigator.pop(context, value);
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Buscar'))],
        );
      },
    );
    if (!mounted) return;
    if (codigo != null && codigo.isNotEmpty) {
      final producto = await productoService.obtenerProductoPorCodigo(codigo);
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

  Widget _getBody() {
    switch (_selectedOption) {
      case MenuOption.inventario:
        return InventarioScreen();
      case MenuOption.ventas:
        return const VentasScreen();
      case MenuOption.reportes:
        return const ReportesScreen();
      case MenuOption.inicio:
      default:
        return const SizedBox.shrink(); // Vista en blanco
    }
  }

  int _menuIndex(MenuOption option) {
    switch (option) {
      case MenuOption.inicio:
        return 0;
      case MenuOption.inventario:
        return 1;
      case MenuOption.ventas:
        return 2;
      case MenuOption.reportes:
        return 3;
    }
  }

  MenuOption _optionFromIndex(int index) {
    switch (index) {
      case 0:
        return MenuOption.inicio;
      case 1:
        return MenuOption.inventario;
      case 2:
        return MenuOption.ventas;
      case 3:
        return MenuOption.reportes;
      default:
        return MenuOption.inicio;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _selectedOption == MenuOption.inventario
          ? <LogicalKeySet, Intent>{LogicalKeySet(LogicalKeyboardKey.keyB): const ActivateIntent()}
          : const <LogicalKeySet, Intent>{},
      child: Actions(
        actions: _selectedOption == MenuOption.inventario
            ? <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<Intent>(
                  onInvoke: (Intent intent) {
                    _abrirBusquedaPorCodigo(context);
                    return null;
                  },
                ),
              }
            : const <Type, Action<Intent>>{},
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Inventario Tienda'),
              actions: _selectedOption == MenuOption.inventario
                  ? [
                      IconButton(
                        icon: const Icon(Icons.qr_code),
                        tooltip: 'Buscar por código de barras',
                        onPressed: () => _abrirBusquedaPorCodigo(context),
                      ),
                    ]
                  : null,
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _menuIndex(_selectedOption),
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedOption = _optionFromIndex(index);
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Inicio')),
                    NavigationRailDestination(icon: Icon(Icons.inventory), label: Text('Inventario')),
                    NavigationRailDestination(icon: Icon(Icons.point_of_sale), label: Text('Ventas')),
                    NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Reportes')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _getBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
