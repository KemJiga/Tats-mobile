import 'package:flutter/material.dart';
import '../../services/dinero.service.dart';

class PrestamoForm extends StatefulWidget {
  @override
  State<PrestamoForm> createState() => _PrestamoFormState();
}

class _PrestamoFormState extends State<PrestamoForm> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  double _monto = 0;
  double _tasa = 0;
  DateTime? _fecha;
  bool _loading = false;

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
    if (!_formKey.currentState!.validate() || _fecha == null) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await DineroService.createPrestamo(
        nombre: _nombre,
        monto: _monto,
        tasa: _tasa,
        fecha: _fecha!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préstamo creado exitosamente')),
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            decoration: const InputDecoration(labelText: 'Tasa (%)'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            onSaved: (v) => _tasa = double.parse(v!) / 100.0,
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
          const SizedBox(height: 24),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Crear Préstamo'),
                ),
        ],
      ),
    );
  }
}
