import 'package:flutter/material.dart';
import 'inventario_screen.dart';
import 'ventas_screen.dart';
import 'reportes_screen.dart';

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

enum MenuOption { inicio, inventario, ventas, reportes }

class _HomeScreenState extends State<HomeScreen> {
  MenuOption _selectedOption = MenuOption.inventario;

  void _onMenuItemSelected(MenuOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? menuSelectedColor.withValues(alpha: 0.15) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: menuSelectedColor.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? menuSelectedColor : menuIconColor,
          size: 24,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? menuSelectedColor : menuTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
      return const SizedBox.shrink(); // Vista en blanco
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.cosmicBackground,
      body: Container(
        color: AppTheme.cosmicBackground,
        child: Row(
          children: [
            // Menú lateral
            Container(
              width: 250,
              color: menuBackgroundColor,
              child: Column(
                children: [
                  // Encabezado del menú
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cosmicSurface.withValues(alpha: 0.8),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: menuSelectedColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.black26,
                            backgroundImage: AssetImage('assets/images/logo.png'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'La casa de los papelitos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: menuTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Administrador',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: menuIconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Opciones del menú
                  _buildMenuItem(
                    context,
                    icon: Icons.home,
                    title: 'Inicio',
                    isSelected: _selectedOption == MenuOption.inicio,
                    onTap: () => _onMenuItemSelected(MenuOption.inicio),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.inventory,
                    title: 'Inventario',
                    isSelected: _selectedOption == MenuOption.inventario,
                    onTap: () => _onMenuItemSelected(MenuOption.inventario),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.point_of_sale,
                    title: 'Ventas',
                    isSelected: _selectedOption == MenuOption.ventas,
                    onTap: () => _onMenuItemSelected(MenuOption.ventas),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Reportes',
                    isSelected: _selectedOption == MenuOption.reportes,
                    onTap: () => _onMenuItemSelected(MenuOption.reportes),
                  ),
                  const Spacer(),
                  // Pie de página del menú
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: menuIconColor,
                          ),
                    ),
                  ),
                ],
              ),
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
