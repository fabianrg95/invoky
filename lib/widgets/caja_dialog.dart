import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CajaDialog extends StatefulWidget {
  final bool isOpening;
  final Function(Map<String, dynamic>) onSave;

  const CajaDialog({
    super.key,
    required this.isOpening,
    required this.onSave,
  });

  @override
  _CajaDialogState createState() => _CajaDialogState();
}

class _CajaDialogState extends State<CajaDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  // Billetes (valores altos)
  final Map<String, int> _billetes = {
    '100000': 100000,
    '50000': 50000,
    '20000': 20000,
    '10000': 10000,
    '5000': 5000,
    '2000': 2000,
  };

  // Monedas (valores bajos)
  final Map<String, int> _monedas = {
    '1000': 1000,
    '500': 500,
    '200': 200,
    '100': 100,
    '50': 50,
  };

  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores para billetes
    for (var denom in _billetes.keys) {
      _controllers[denom] = TextEditingController(text: '');
      _controllers[denom]!.addListener(_calcularTotal);
    }
    // Inicializar controladores para monedas
    for (var denom in _monedas.keys) {
      _controllers[denom] = TextEditingController(text: '');
      _controllers[denom]!.addListener(_calcularTotal);
    }
  }

  @override
  void dispose() {
    // Limpiar controladores
    for (var controller in _controllers.values) {
      controller.removeListener(_calcularTotal);
      controller.dispose();
    }
    super.dispose();
  }

  void _calcularTotal() {
    double total = 0;
    // Calcular total de billetes
    _billetes.forEach((key, value) {
      final cantidad = int.tryParse(_controllers[key]?.text ?? '0') ?? 0;
      total += cantidad * value;
    });
    // Calcular total de monedas
    _monedas.forEach((key, value) {
      final cantidad = int.tryParse(_controllers[key]?.text ?? '0') ?? 0;
      total += cantidad * value;
    });
    setState(() {
      _total = total;
    });
  }

  void _onFieldSubmitted(String value, String denomKey) {
    final cantidad = int.tryParse(value) ?? 0;
    _controllers[denomKey]!.text = cantidad.toString();
    _calcularTotal();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isCierre = false;
    

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        widget.isOpening ? 'Apertura de Caja' : 'Cierre de Caja',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: colorScheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingrese la cantidad de cada denominación',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _buildDenominacionFields(),
              const SizedBox(height: 24),
              Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: isCierre,
                      tristate: false,
                      onChanged: (value) {
                          isCierre = value ?? false;
                      },
                    ),
                    const Text('Cerrar caja?', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: '\$',
                      decimalDigits: 0,
                      locale: 'es_CO',
                    ).format(_total),
                    style: GoogleFonts.robotoMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final detalles = <String, int>{};
              // Agregar billetes
              _billetes.forEach((key, value) {
                detalles[key] = int.tryParse(_controllers[key]?.text ?? '0') ?? 0;
              });
              // Agregar monedas
              _monedas.forEach((key, value) {
                detalles[key] = int.tryParse(_controllers[key]?.text ?? '0') ?? 0;
              });
              
              widget.onSave({
                'total': _total,
                'detalles': detalles,
                'isCierre': isCierre,
              });
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            widget.isOpening ? 'Abrir Caja' : 'Cerrar Caja',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDenominacionFields() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
      locale: 'es_CO',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billetes',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna de billetes
            Expanded(
              child: Column(
                children: _buildDenominationsList(_billetes, formatter),
              ),
            ),
            const SizedBox(width: 16),
            // Columna de monedas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monedas',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildDenominationsList(_monedas, formatter),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildDenominationsList(
      Map<String, int> denominations, NumberFormat formatter) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return denominations.entries.map((entry) {
      final denom = entry.value;
      final denomKey = entry.key;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                formatter.format(denom),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: _controllers[denomKey],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                ),
                onChanged: (_) => _calcularTotal(),
                onEditingComplete: () {
                  _onFieldSubmitted(_controllers[denomKey]!.text, denomKey);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un valor';
                  }
                  final cantidad = int.tryParse(value);
                  if (cantidad == null || cantidad < 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
