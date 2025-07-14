abstract class DineroItem {
  final String id;
  final String nombre;
  final DateTime fecha;
  final double monto;
  final String type; // 'prestamo' or 'pago'

  DineroItem({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.monto,
    required this.type,
  });
}
