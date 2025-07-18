import 'stock_item.dart';

class BolisItem extends StockItem {
  final String sabor;
  final double gananciaPorUnidad;

  BolisItem({
    required super.id,
    required this.sabor,
    required super.cantidad,
    required this.gananciaPorUnidad,
  }) : super(
          name: sabor,
          type: 'bolis',
        );

  factory BolisItem.fromJson(Map<String, dynamic> json) {
    return BolisItem(
      id: json['id'],
      sabor: json['sabor'],
      cantidad: (json['cantidad'] as num).toInt(),
      gananciaPorUnidad: (json['gananciaPorUnidad'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sabor': sabor,
      'cantidad': cantidad,
      'gananciaPorUnidad': gananciaPorUnidad,
    };
  }
}
