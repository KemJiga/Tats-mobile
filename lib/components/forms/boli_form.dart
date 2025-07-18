import 'package:flutter/material.dart';
import '../../services/stock.services.dart';

class BoliForm extends StatefulWidget {
  @override
  State<BoliForm> createState() => _BoliFormState();
}

class _BoliFormState extends State<BoliForm> {
  final _formKey = GlobalKey<FormState>();
  String _sabor = '';
  int _cantidad = 0;
  double _gananciaPorUnidad = 0;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await StockService.createBoli(
        sabor: _sabor,
        cantidad: _cantidad,
        gananciaPorUnidad: _gananciaPorUnidad.toInt(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Boli creado exitosamente')),
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
            decoration: const InputDecoration(labelText: 'Sabor'),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            onSaved: (v) => _sabor = v!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Cantidad'),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            onSaved: (v) => _cantidad = int.parse(v!),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Ganancia por Unidad'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            onSaved: (v) => _gananciaPorUnidad = double.parse(v!),
          ),
          const SizedBox(height: 24),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Crear Boli'),
                ),
        ],
      ),
    );
  }
}
