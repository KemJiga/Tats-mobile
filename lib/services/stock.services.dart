import '../models/bolis.dart';
import '../models/materiales.dart';
import '../models/stock_item.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockService {
  static final String _baseUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:3000/api';

  static Future<List<StockItem>> getStockItems() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/stock'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final bolis = json.decode(response.body)['bolis'];
      final materiales = json.decode(response.body)['materiales'];

      return [
        ...bolis.map((bolis) => BolisItem.fromJson(bolis)),
        ...materiales.map((materiales) => MaterialesItem.fromJson(materiales)),
      ];
    } else {
      throw Exception('Failed to load stock items');
    }
  }

  // update bolis stock
  static Future<void> updateBolis(
      {required String id, required int cantidad}) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/bolis'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'cantidad': cantidad}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update bolis');
    }
  }

  // update materiales stock
  static Future<void> updateMateriales(
      {required String id, required int cantidad, required int precio}) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/materiales'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': id,
        'cantidad': cantidad,
        'precio': precio,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update materiales');
    }
  }
}
