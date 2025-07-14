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
}
