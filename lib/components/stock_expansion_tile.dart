import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../models/bolis.dart';
import '../models/materiales.dart';
import 'detail_row.dart';
import 'update_modal.dart';

class StockExpansionTile extends StatelessWidget {
  final StockItem item;
  final VoidCallback? onUpdated;
  const StockExpansionTile({super.key, required this.item, this.onUpdated});

  void _showUpdateModal(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => UpdateStockItemModal(item: item),
    );
    if (result == true && onUpdated != null) {
      onUpdated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        item.type == 'bolis' ? Icons.icecream : Icons.inventory,
        color: item.type == 'bolis' ? Colors.purple : Colors.orange,
      ),
      title: Text(
        item.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${item.type.toUpperCase()} - Cantidad: ${item.cantidad}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item is BolisItem) ...[
                DetailRow(label: 'Sabor', value: (item as BolisItem).sabor),
                DetailRow(label: 'Cantidad', value: '${item.cantidad}'),
                DetailRow(
                    label: 'Ganancia por Unidad',
                    value: '\$${(item as BolisItem).gananciaPorUnidad}'),
              ] else if (item is MaterialesItem) ...[
                DetailRow(
                    label: 'Nombre', value: (item as MaterialesItem).nombre),
                DetailRow(label: 'Cantidad', value: '${item.cantidad}'),
                DetailRow(
                    label: 'Unidad', value: (item as MaterialesItem).unidad),
                DetailRow(
                    label: 'Presentación',
                    value: '${(item as MaterialesItem).presentacion}'),
                DetailRow(
                    label: 'Precio',
                    value: '\$${(item as MaterialesItem).precio}'),
              ],
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${item.id}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdateModal(context),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Actualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
