class StockItem {
  final String id;
  final String name;
  final int cantidad;
  final String type; // 'bolis' or 'materiales'

  StockItem({
    required this.id,
    required this.name,
    required this.cantidad,
    required this.type,
  });
}
