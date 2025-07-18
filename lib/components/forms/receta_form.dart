import 'package:flutter/material.dart';
import '../../services/receta.service.dart';

class RecetaForm extends StatefulWidget {
  @override
  State<RecetaForm> createState() => _RecetaFormState();
}

class _RecetaFormState extends State<RecetaForm> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  List<String> _ingredientes = [];
  List<String> _pasos = [];
  final _ingredienteController = TextEditingController();
  final _pasoController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ingredienteController.dispose();
    _pasoController.dispose();
    super.dispose();
  }

  void _addIngrediente() {
    final text = _ingredienteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredientes.add(text);
        _ingredienteController.clear();
      });
    }
  }

  void _addPaso() {
    final text = _pasoController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _pasos.add(text);
        _pasoController.clear();
      });
    }
  }

  void _removeIngrediente(int index) {
    setState(() => _ingredientes.removeAt(index));
  }

  void _removePaso(int index) {
    setState(() => _pasos.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _ingredientes.isEmpty ||
        _pasos.isEmpty) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await RecetaService.createReceta(
        nombre: _nombre,
        ingredientes: _ingredientes,
        pasos: _pasos,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta creada exitosamente')),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              onSaved: (v) => _nombre = v!,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ingredienteController,
                    decoration: const InputDecoration(labelText: 'Ingrediente'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addIngrediente,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: List.generate(
                  _ingredientes.length,
                  (i) => Chip(
                        label: Text(_ingredientes[i]),
                        onDeleted: () => _removeIngrediente(i),
                      )),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pasoController,
                    decoration: const InputDecoration(labelText: 'Paso'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addPaso,
                ),
              ],
            ),
            Column(
              children: List.generate(
                  _pasos.length,
                  (i) => ListTile(
                        leading: Text('${i + 1}'),
                        title: Text(_pasos[i]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removePaso(i),
                        ),
                      )),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Crear Receta'),
                  ),
          ],
        ),
      ),
    );
  }
}
