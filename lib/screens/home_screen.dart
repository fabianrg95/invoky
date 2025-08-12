import 'package:Invoky/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'inventario_screen.dart';
import 'ventas_screen.dart';
import 'reportes_screen.dart';
import '../widgets/menu.dart';
import '../models/menu_options.dart';
import '../theme/app_theme.dart';

// Colores del tema
const Color menuBackgroundColor = AppTheme.cosmicSurface;
const Color menuTextColor = AppTheme.cosmicText;
const Color menuIconColor = AppTheme.cosmicTextSecondary;
const Color menuSelectedColor = AppTheme.cosmicPrimary;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MenuOption _selectedOption = MenuOption.inicio;

  void _onMenuItemSelected(MenuOption option) {
    setState(() {
      _selectedOption = option;
    });
  }


  Widget _getBody() {
    switch (_selectedOption) {
      case MenuOption.inventario:
        return const InventarioScreen();
      case MenuOption.ventas:
        return const VentasScreen();
      case MenuOption.reportes:
        return const ReportesScreen();
      case MenuOption.inicio:
        return const DashboardScreen(); // Vista en blanco
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppTheme.cosmicBackground,
      body: Container(
        color: AppTheme.cosmicBackground,
        child: Row(
          children: [
            // Menú lateral
            SideMenu(
              selectedOption: _selectedOption,
              onMenuSelected: _onMenuItemSelected,
            ),
            // Contenido principal
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cosmicSurface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _getBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
