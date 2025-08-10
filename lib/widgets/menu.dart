import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';
import '../models/menu_options.dart';

class SideMenu extends StatefulWidget {
  final MenuOption selectedOption;
  final Function(MenuOption) onMenuSelected;

  const SideMenu({
    super.key,
    required this.selectedOption,
    required this.onMenuSelected,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${packageInfo.version}';
      });
    }
  }

  void _onMenuItemSelected(MenuOption option) {
    widget.onMenuSelected(option);
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required MenuOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.menuSelectedColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppTheme.menuSelectedColor.withValues(alpha: 0.5))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                color: isSelected ? AppTheme.menuSelectedColor : AppTheme.menuIconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                option.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? AppTheme.menuSelectedColor : AppTheme.menuTextColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 250,
      color: AppTheme.menuBackgroundColor,
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
                      color: AppTheme.menuSelectedColor,
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
                    color: AppTheme.menuTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administrador',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.menuIconColor,
                  ),
                ),
              ],
            ),
          ),
          // Opciones del menú
          ...MenuOption.values.map((option) => _buildMenuItem(
                context,
                option: option,
                isSelected: widget.selectedOption == option,
                onTap: () => _onMenuItemSelected(option),
              )),
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
_version.isNotEmpty ? _version : 'Cargando...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.menuIconColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
