import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Invoky/models/caja.dart';
import '../widgets/caja_dialog.dart';
import '../services/caja_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _cajaAbierta = false;
  bool _cajaCerrada = false;
  int _montoInicial = 0;
  int _montoFinal = 0;
  DateTime _horaApertura = DateTime.now();
  DateTime _horaCierre = DateTime.now();
  final CajaService _cajaService = CajaService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verificarEstadoCaja();
  }

  Future<void> _verificarEstadoCaja() async {
    try {
      final cajaAbierta = await _cajaService.verificarCajaAbierta();
      final cajaCerrada = await _cajaService.verificarCajaCerrada();
      
      if (cajaAbierta) {
        final caja = await _cajaService.obtenerCajaAbierta();
        if (caja != null) {
          _montoInicial = caja.valorTotal;
          _horaApertura = caja.createdAt;
        }
      }

      if (cajaCerrada) {
        final caja = await _cajaService.obtenerCajaCerrada();
        if (caja != null) {
          _montoFinal = caja.valorTotal;
          _horaCierre = caja.createdAt;
        }
      }

      if (mounted) {
        setState(() {
          _cajaAbierta = cajaAbierta;
          _cajaCerrada = cajaCerrada;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al verificar el estado de la caja: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Diseño para pantallas anchas (tablets/escritorio)
  Widget _buildWideLayout(BuildContext context, double width, double height, double spacing) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCajaCard(context, width, height),
            SizedBox(width: spacing),
            _buildNuevaVentaCard(context, width, height),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVentasCard(context, width, height),
            SizedBox(width: spacing),
            _buildProductosCard(context, width, height),
          ],
        ),
      ],
    );
  }

  // Diseño para pantallas estrechas (móviles)
  Widget _buildNarrowLayout(BuildContext context, double width, double height, double spacing) {
    return Column(
      children: [
        _buildCajaCard(context, width, height),
        SizedBox(height: spacing),
        _buildNuevaVentaCard(context, width, height),
        SizedBox(height: spacing),
        _buildVentasCard(context, width, height),
        SizedBox(height: spacing),
        _buildProductosCard(context, width, height),
      ],
    );
  }

  // Muestra el diálogo de caja (apertura o cierre)
  void _mostrarDialogoCaja(bool esApertura) {
    // Capture the context before the async operation
    final currentContext = context;
    
    showDialog(
      context: context,
      builder: (dialogContext) => CajaDialog(
        isOpening: esApertura,
        onSave: (valores) async {
          final total = valores['total'] as double;
          final detalles = valores['detalles'] as Map<String, dynamic>;
          final isCierre = valores['isCierre'] as bool;

          final tipoCaja = esApertura ? TipoCaja.apertura : isCierre ? TipoCaja.cierre : TipoCaja.conteo;

          final caja = Caja(
            createdAt: DateTime.now(),
            tipoCaja: tipoCaja,
            cantidadBillete100000: detalles['100000'],
            cantidadBillete50000: detalles['50000'],
            cantidadBillete20000: detalles['20000'],
            cantidadBillete10000: detalles['10000'],
            cantidadBillete5000: detalles['5000'],
            cantidadBillete2000: detalles['2000'],
            cantidadMoneda1000: detalles['1000'],
            cantidadMoneda500: detalles['500'],
            cantidadMoneda200: detalles['200'],
            cantidadMoneda100: detalles['100'],
            cantidadMoneda50: detalles['50'],
            valorTotal: total.toInt(),
          );
          
          await _cajaService.crearRegistroCaja(caja);
          
          if (mounted) {
            // Show success message using the captured context
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text(esApertura 
                  ? 'Caja abierta correctamente' 
                  : 'Caja cerrada correctamente'
                ),
                backgroundColor: Colors.green,
              ),
            );
            
            // Update the state after showing the message
            setState(() {
               _verificarEstadoCaja();
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // Inicializar el formato de fecha
    initializeDateFormatting('es_ES', null);
    
    final dateFormatter = DateFormat('EEEE d MMMM y', 'es_ES');
    final today = DateTime.now();
    final formattedDate = '${dateFormatter.format(today)[0].toUpperCase()}${dateFormatter.format(today).substring(1)}';
    
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final padding = isSmallScreen ? 16.0 : 24.0;
    final spacing = isSmallScreen ? 16.0 : 20.0;
    
    final availableWidth = size.width - padding;
    final cellHeight = 320.0;
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard - $formattedDate',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [        
            // Layout dinámico según el tamaño de la pantalla
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return _buildNarrowLayout(
                    context, 
                    availableWidth *2,
                    cellHeight,
                    spacing,
                  );
                } else {
                  return _buildWideLayout(
                    context, 
                    ((availableWidth) - 330) / 2,
                    cellHeight,
                    spacing,
                  );
                }
              },
            ),
            
            // Espacio en la parte inferior
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVentasCard(BuildContext context, double width, double height) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navegar al historial de ventas
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ventas del día',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildStatRow(
                  context,
                  label: 'Ventas',
                  value: '0',
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  context,
                  label: 'Total',
                  value: '\$0',
                  icon: Icons.attach_money_rounded,
                  isTotal: true,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '0% vs ayer',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductosCard(BuildContext context, double width, double height) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Productos',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                context,
                label: 'Total de productos',
                value: '0',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                context,
                label: 'Productos agotados',
                value: '0',
                icon: Icons.warning_amber_outlined,
                isTotal: true,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.trending_down, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '0% vs ayer',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNuevaVentaCard(BuildContext context, double width, double height) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Implementar navegación a pantalla de nueva venta
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 36,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nueva Venta',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Iniciar una nueva transacción',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCajaCard(BuildContext context, double width, double height) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final bool cajaAbierta = _cajaAbierta;
    final bool cajaCerrada = _cajaCerrada;
    final int montoInicial = _montoInicial;
    final int montoFinal = _montoFinal;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Control de Caja',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.point_of_sale_outlined,
                      color: Colors.orange.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cajaAbierta ? cajaCerrada ? Colors.red.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cajaAbierta 
                        ? cajaCerrada ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3) 
                        : Colors.red.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cajaAbierta ? cajaCerrada ? Colors.red : Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cajaAbierta ? cajaCerrada ? 'Caja Cerrada' : 'Caja Abierta' : 'Caja Cerrada',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: cajaAbierta ? cajaCerrada ? Colors.red.withValues(alpha: 0.8) : Colors.green.withValues(alpha: 0.8) : Colors.red.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              if (cajaAbierta) ...[
                _buildStatRow(
                  context,
                  label: 'Monto Inicial',
                  value: NumberFormat('\$#,##0', 'es_CL').format(montoInicial),
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 16),
              ],

              if (cajaCerrada) ...[
                _buildStatRow(
                  context,
                  label: 'Monto Final',
                  value: NumberFormat('\$#,##0', 'es_CL').format(montoFinal),
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 16),
              ],
              
              if (!cajaAbierta || (cajaAbierta && !cajaCerrada)) ...[
                SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: cajaAbierta 
                      ? () => _mostrarDialogoCaja(false)
                      : () => _mostrarDialogoCaja(true), // Abrir caja
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cajaAbierta 
                        ? Colors.yellow.withValues(alpha: 0.5) 
                        : colorScheme.primary,
                    foregroundColor: cajaAbierta 
                        ? Colors.yellow.withValues(alpha: 0.7) 
                        : colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: cajaAbierta 
                          ? BorderSide(color: Colors.yellow.withValues(alpha: 0.2))
                          : BorderSide.none,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cajaAbierta ? Icons.currency_exchange : Icons.lock_open,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cajaAbierta ? 'Registrar Caja' : 'Abrir Caja',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              ],
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: cajaAbierta 
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Detalles de Caja',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (cajaAbierta) ...[
                                  Text(
                                    'Monto Inicial:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '\$${_montoInicial.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ],
                                  if (cajaCerrada) ...[
                                  Text(
                                    'Monto Final:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '\$${_montoFinal.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ],
                                  
                                  Text(
                                    'Estado: ${_cajaAbierta ? cajaCerrada ? 'Cerrada' : 'Abierta' : 'Cerrada'}',
                                    style: GoogleFonts.poppins(
                                      color: _cajaAbierta ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (cajaAbierta) ...[
                                  Text(
                                    'Hora de Apertura: ${_horaApertura.hour}:${_horaApertura.minute}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ],
                                  if (cajaCerrada) ...[
                                  Text(
                                'Hora de cierre: ${_horaCierre.hour}:${_horaCierre.minute}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ],
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Ver Detalles',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
