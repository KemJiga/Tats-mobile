import 'prestamo.dart';

class Pago {
  final String id;
  final String nombre;
  final String prestamoId;
  final Prestamo prestamo;
  final DateTime fecha;
  final double monto;
  final double restante;
  final String tipo;

  Pago({
    required this.id,
    required this.nombre,
    required this.prestamoId,
    required this.prestamo,
    required this.fecha,
    required this.monto,
    required this.restante,
    required this.tipo,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      prestamoId: json['prestamoId'] as String,
      prestamo: Prestamo.fromJson(json['prestamo'] as Map<String, dynamic>),
      fecha: DateTime.parse(json['fecha'] as String),
      monto: (json['monto'] as num).toDouble(),
      restante: (json['restante'] as num).toDouble(),
      tipo: json['tipo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'prestamoId': prestamoId,
      'prestamo': prestamo.toJson(),
      'fecha': fecha.toIso8601String(),
      'monto': monto,
      'restante': restante,
      'tipo': tipo,
    };
  }
}
