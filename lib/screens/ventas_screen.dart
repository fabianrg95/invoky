import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'nueva_venta_screen.dart';
import '../models/venta.dart';
import '../services/venta_service.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom colors for the app
class CustomColors {
  static const Color primaryColorDark = Color(0xFF1A237E);
  static const Color primaryColorLight = Color(0xFFC5CAE9);
  static const Color accentColor = Color(0xFF536DFE);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> with SingleTickerProviderStateMixin {
  final VentaService _ventaService = VentaService();
  late TabController _tabController;
  List<Venta> _ventasRecientes = [];
  bool _cargando = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarVentasRecientes();
  }

  Future<void> _cargarVentasRecientes() async {
    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      final ventas = await _ventaService.obtenerHistorialVentas(fechaInicio: DateTime.now().subtract(const Duration(days: 7)));

      setState(() {
        _ventasRecientes = ventas;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las ventas: $e';
        _cargando = false;
      });
    }
  }

  void _navegarANuevaVenta() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NuevaVentaScreen())).then((_) {
      // Recargar el historial cuando volvamos de la nueva venta
      _cargarVentasRecientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: CustomColors.primaryColorDark, secondary: CustomColors.accentColor),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Ventas', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 22)),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
              indicatorColor: CustomColors.accentColor,
              labelColor: CustomColors.accentColor,
              unselectedLabelColor: CustomColors.textSecondary,
              tabs: const [
                Tab(icon: Icon(Icons.point_of_sale), text: 'Nueva Venta'),
                Tab(icon: Icon(Icons.history), text: 'Historial'),
              ],
            ),
            actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarVentasRecientes, tooltip: 'Actualizar')],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [CustomColors.primaryColorDark.withOpacity(0.05), CustomColors.primaryColorLight.withOpacity(0.1)],
              ),
            ),
            child: TabBarView(controller: _tabController, children: [_construirNuevaVenta(), _construirHistorialVentas()]),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _navegarANuevaVenta,
            icon: const Icon(Icons.add_shopping_cart, size: 24),
            label: Text('Nueva Venta', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
            backgroundColor: CustomColors.accentColor,
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _construirNuevaVenta() {
    return Column(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CustomColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.point_of_sale_rounded, size: 80, color: CustomColors.primaryColorDark.withOpacity(0.8)),
                      const SizedBox(height: 24),
                      Text(
                        '¡Comienza una nueva venta!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: CustomColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Escanea un código de barras o busca un producto para comenzar a vender',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 14, color: CustomColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _navegarANuevaVenta,
                          icon: const Icon(Icons.add_shopping_cart, size: 20),
                          label: Text('NUEVA VENTA', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_ventasRecientes.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.history, color: CustomColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ventas Recientes',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: CustomColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._ventasRecientes.take(3).map((venta) => _buildVentaItem(venta)).toList(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirHistorialVentas() {
    if (_cargando) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Cargando ventas...', style: GoogleFonts.poppins(color: CustomColors.textSecondary, fontSize: 14)),
        ],
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: CustomColors.errorColor.withOpacity(0.8)),
              const SizedBox(height: 24),
              Text(
                '¡Ups! Algo salió mal',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: CustomColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: CustomColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargarVentasRecientes,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text('REINTENTAR', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: CustomColors.accentColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_ventasRecientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: CustomColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No hay ventas recientes',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: CustomColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Las ventas que realices aparecerán aquí',
              style: GoogleFonts.poppins(fontSize: 14, color: CustomColors.textSecondary.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarVentasRecientes,
      color: CustomColors.accentColor,
      backgroundColor: CustomColors.cardColor,
      strokeWidth: 2.5,
      notificationPredicate: (notification) {
        // for iOS style effect
        return notification.depth == 0;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _ventasRecientes.length,
        itemBuilder: (context, index) {
          final venta = _ventasRecientes[index];
          return _buildVentaItem(venta);
        },
      ),
    );
  }

  Widget _buildVentaItem(Venta venta) {
    final isToday = DateUtils.isSameDay(venta.createdAt, DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _mostrarDetalleVenta(venta),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Venta #${venta.id ?? 'N/A'}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: CustomColors.primaryColorDark),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isToday ? CustomColors.accentColor.withOpacity(0.1) : CustomColors.primaryColorLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isToday ? 'HOY' : DateFormat('dd MMM yyyy').format(venta.createdAt).toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday ? CustomColors.accentColor : CustomColors.primaryColorDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${venta.cantidadProductos ?? 0} ${venta.cantidadProductos == 1 ? 'producto' : 'productos'}',
                        style: GoogleFonts.poppins(color: CustomColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(venta.createdAt),
                        style: GoogleFonts.poppins(color: CustomColors.textSecondary.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    '\$${(venta.valorTotalVenta ?? 0).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: CustomColors.primaryColorDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleVenta(Venta venta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CustomColors.backgroundColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: CustomColors.textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalle de Venta',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: CustomColors.textPrimary),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: CustomColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Venta #${venta.id ?? 'N/A'}', style: GoogleFonts.poppins(color: CustomColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),
            _buildDetailRow('Fecha', venta.formattedDate),
            const Divider(height: 32),
            _buildDetailRow('Hora', DateFormat('HH:mm').format(venta.createdAt)),
            const Divider(height: 32),
            _buildDetailRow('Método de pago', venta.medioPagoId == 1 ? 'Tarjeta de crédito' : 'Efectivo'),
            if (venta.medioPagoId == 1 && venta.valorPagoTarjetaCredito != null) ...[
              const Divider(height: 32),
              _buildDetailRow('Monto con tarjeta', '\$${venta.valorPagoTarjetaCredito?.toStringAsFixed(2) ?? '0.00'}'),
            ],
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: CustomColors.textPrimary),
                ),
                Text(
                  '\$${venta.valorTotalVenta?.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: CustomColors.primaryColorDark),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implementar reimpresión de ticket
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: CustomColors.accentColor,
                ),
                child: Text('IMPRIMIR TICKET', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: CustomColors.textSecondary, fontSize: 14)),
        Text(
          value,
          style: GoogleFonts.poppins(color: CustomColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
