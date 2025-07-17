import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../models/bolis.dart';
import '../models/materiales.dart';
import '../services/stock.services.dart';

class UpdateStockItemModal extends StatefulWidget {
  final StockItem item;
  const UpdateStockItemModal({super.key, required this.item});

  @override
  State<UpdateStockItemModal> createState() => _UpdateStockItemModalState();
}

class _UpdateStockItemModalState extends State<UpdateStockItemModal> {
  final _formKey = GlobalKey<FormState>();
  late int _cantidad;
  int? _precio; // For Materiales

  @override
  void initState() {
    super.initState();
    _cantidad = widget.item.cantidad;
    if (widget.item is MaterialesItem) {
      _precio = (widget.item as MaterialesItem).precio;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    try {
      if (widget.item is BolisItem) {
        await StockService.updateBolis(id: widget.item.id, cantidad: _cantidad);
      } else if (widget.item is MaterialesItem) {
        await StockService.updateMateriales(
          id: widget.item.id,
          cantidad: _cantidad,
          precio: _precio!,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBolis = widget.item is BolisItem;
    return AlertDialog(
      title: Text('Actualizar ${isBolis ? 'Bolis' : 'Materiales'}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _cantidad.toString(),
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              onSaved: (v) => _cantidad = int.parse(v!),
            ),
            if (!isBolis)
              TextFormField(
                initialValue: _precio.toString(),
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                onSaved: (v) => _precio = int.parse(v!),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}
