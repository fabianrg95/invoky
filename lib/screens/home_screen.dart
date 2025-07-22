import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('La casa de los papelitos'),
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
    );
  }
}
