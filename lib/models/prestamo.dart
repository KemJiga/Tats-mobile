class Prestamo {
  final String id;
  final String nombre;
  final DateTime fecha;
  final double monto;
  final double tasa;

  Prestamo({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.monto,
    required this.tasa,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      monto: (json['monto'] as num).toDouble(),
      tasa: (json['tasa'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'fecha': fecha.toIso8601String(),
      'monto': monto,
      'tasa': tasa,
    };
  }
}
