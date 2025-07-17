import 'package:flutter/material.dart';
import '../models/prestamo.dart';
import '../models/pago.dart';
import 'detail_row.dart';

class DineroExpansionTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool Function(Prestamo) isPrestamoCompleted;
  final String Function(DateTime) formatDate;
  const DineroExpansionTile(
      {super.key,
      required this.item,
      required this.isPrestamoCompleted,
      required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String;
    if (type == 'prestamo') {
      final Prestamo prestamo = item['data'] as Prestamo;
      return ExpansionTile(
        leading: const Icon(Icons.account_balance, color: Colors.blue),
        title: Text(
          prestamo.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Préstamo • \$${prestamo.monto.toStringAsFixed(0)} • ${formatDate(prestamo.fecha)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(
                    label: 'Nombre', value: prestamo.nombre, labelWidth: 100),
                DetailRow(
                    label: 'Fecha',
                    value: formatDate(prestamo.fecha),
                    labelWidth: 100),
                DetailRow(
                    label: 'Monto',
                    value: '\$${prestamo.monto.toStringAsFixed(0)}',
                    labelWidth: 100),
                DetailRow(
                    label: 'Tasa',
                    value: '${(prestamo.tasa * 100).toStringAsFixed(1)}%',
                    labelWidth: 100),
                DetailRow(
                    label: 'Estado',
                    value: isPrestamoCompleted(prestamo)
                        ? 'Completado'
                        : 'Pendiente',
                    labelWidth: 100),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ID: ${prestamo.id}',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      final Pago pago = item['data'] as Pago;
      return ExpansionTile(
        leading: const Icon(Icons.payment, color: Colors.green),
        title: Text(
          pago.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Pago • \$${pago.monto.toStringAsFixed(0)} • ${formatDate(pago.fecha)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(label: 'Nombre', value: pago.nombre, labelWidth: 100),
                DetailRow(
                    label: 'Préstamo',
                    value: pago.prestamo.nombre,
                    labelWidth: 100),
                DetailRow(
                    label: 'Fecha',
                    value: formatDate(pago.fecha),
                    labelWidth: 100),
                DetailRow(
                    label: 'Monto',
                    value: '\$${pago.monto.toStringAsFixed(0)}',
                    labelWidth: 100),
                DetailRow(
                    label: 'Restante',
                    value: '\$${pago.restante.toStringAsFixed(0)}',
                    labelWidth: 100),
                DetailRow(
                    label: 'Tipo',
                    value: pago.tipo == 'capital' ? 'Capital' : 'Interés',
                    labelWidth: 100),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ID: ${pago.id}',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
