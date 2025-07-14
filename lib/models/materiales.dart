import 'stock_item.dart';

class MaterialesItem extends StockItem {
  final String nombre;
  final String unidad;
  final int presentacion;
  final int precio;

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
      cantidad: json['cantidad'],
      unidad: json['unidad'],
      presentacion: json['presentacion'],
      precio: json['precio'],
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
