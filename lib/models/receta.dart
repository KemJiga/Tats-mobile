class Receta {
  final String id;
  final String nombre;
  final List<String> ingredientes;
  final List<String> pasos;

  Receta({
    required this.id,
    required this.nombre,
    required this.ingredientes,
    required this.pasos,
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      ingredientes: List<String>.from(json['ingredientes']),
      pasos: List<String>.from(json['pasos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'ingredientes': ingredientes,
      'pasos': pasos,
    };
  }
}
