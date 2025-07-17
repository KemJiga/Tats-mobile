import '../models/receta.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecetaService {
  static final String _baseUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:3000/api';

  static Future<List<Receta>> getRecetas() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recetas'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final recetas = (json.decode(response.body) as List)
          .map((receta) => Receta.fromJson(receta))
          .toList();
      return recetas;
    } else {
      throw Exception('Failed to load recetas');
    }
  }
}
