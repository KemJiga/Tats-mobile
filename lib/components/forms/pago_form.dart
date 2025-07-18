import 'package:flutter/material.dart';
import '../../services/dinero.service.dart';
import '../../models/prestamo.dart';

class PagoForm extends StatefulWidget {
  @override
  State<PagoForm> createState() => _PagoFormState();
}

class _PagoFormState extends State<PagoForm> {
  final _formKey = GlobalKey<FormState>();
  String? _prestamoId;
  String _nombre = '';
  double _monto = 0;
  double _restante = 0;
  DateTime? _fecha;
  String _tipo = 'capital';
  bool _loading = false;
  List<Prestamo> _prestamos = [];

  @override
  void initState() {
    super.initState();
    _fetchPrestamos();
  }

  Future<void> _fetchPrestamos() async {
    try {
      final dinero = await DineroService.getDinero();
      setState(() {
        _prestamos = dinero.prestamos;
      });
    } catch (e) {
      // ignore error for now
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _fecha == null ||
        _prestamoId == null) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await DineroService.createPago(
        prestamoId: _prestamoId!,
        nombre: _nombre,
        monto: _monto,
        restante: _restante,
        fecha: _fecha!,
        tipo: _tipo,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago creado exitosamente')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _prestamos.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Préstamo'),
                  value: _prestamoId,
                  items: _prestamos
                      .map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.nombre),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _prestamoId = v),
                  validator: (v) => v == null ? 'Seleccione un préstamo' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => _nombre = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => _monto = double.parse(v!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Restante'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => _restante = double.parse(v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(_fecha == null
                          ? 'Fecha: No seleccionada'
                          : 'Fecha: ${_fecha!.day}/${_fecha!.month}/${_fecha!.year}'),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Seleccionar Fecha'),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  value: _tipo,
                  items: const [
                    DropdownMenuItem(value: 'capital', child: Text('Capital')),
                    DropdownMenuItem(value: 'interes', child: Text('Interés')),
                  ],
                  onChanged: (v) => setState(() => _tipo = v!),
                ),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Crear Pago'),
                      ),
              ],
            ),
          );
  }
}
