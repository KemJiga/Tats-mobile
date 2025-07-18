import 'package:flutter/material.dart';
import '../../services/stock.services.dart';

class MaterialForm extends StatefulWidget {
  @override
  State<MaterialForm> createState() => _MaterialFormState();
}

class _MaterialFormState extends State<MaterialForm> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  int _cantidad = 0;
  String _unidad = '';
  double _presentacion = 0;
  double _precio = 0;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await StockService.createMaterial(
        nombre: _nombre,
        cantidad: _cantidad,
        unidad: _unidad,
        presentacion: _presentacion,
        precio: _precio,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material creado exitosamente')),
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
            decoration: const InputDecoration(labelText: 'Cantidad'),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            onSaved: (v) => _cantidad = int.parse(v!),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Unidad'),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            onSaved: (v) => _unidad = v!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Presentación'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            onSaved: (v) => _presentacion = double.parse(v!),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Precio'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            onSaved: (v) => _precio = double.parse(v!),
          ),
          const SizedBox(height: 24),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Crear Material'),
                ),
        ],
      ),
    );
  }
}
