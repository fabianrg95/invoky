import 'package:flutter/material.dart';

/// Enumerador que contiene todas las opciones disponibles en el menú de navegación
enum MenuOption {
  inicio(
    title: 'Inicio',
    icon: Icons.home,
    route: '/inicio',
  ),
  inventario(
    title: 'Inventario',
    icon: Icons.inventory,
    route: '/inventario',
  ),
  ventas(
    title: 'Ventas',
    icon: Icons.point_of_sale,
    route: '/ventas',
  ),
  reportes(
    title: 'Reportes',
    icon: Icons.bar_chart,
    route: '/reportes',
  );

  final String title;
  final IconData icon;
  final String route;

  const MenuOption({
    required this.title,
    required this.icon,
    required this.route,
  });
}
