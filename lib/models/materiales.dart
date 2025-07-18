import 'stock_item.dart';

class MaterialesItem extends StockItem {
  final String nombre;
  final String unidad;
  final double presentacion;
  final double precio;

  MaterialesItem({
    required super.id,
    required this.nombre,
    required super.cantidad,
    required this.unidad,
    required this.presentacion,
    required this.precio,
  }) : super(
          name: nombre,
          type: 'materiales',
        );

  factory MaterialesItem.fromJson(Map<String, dynamic> json) {
    return MaterialesItem(
      id: json['id'],
      nombre: json['nombre'],
      cantidad: (json['cantidad'] as num).toInt(),
      unidad: json['unidad'],
      presentacion: (json['presentacion'] as num).toDouble(),
      precio: (json['precio'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
      'presentacion': presentacion,
      'precio': precio,
    };
  }
}
