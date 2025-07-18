import '../models/prestamo.dart';
import '../models/pago.dart';
import '../models/dinero.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DineroService {
  static final String _baseUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:3000/api';

  static Future<Dinero> getDinero() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/dinero'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<Prestamo> prestamos = [];
      List<Pago> pagos = [];

      prestamos = (json.decode(response.body)['prestamos'] as List)
          .map((prestamo) => Prestamo.fromJson(prestamo))
          .toList();
      pagos = (json.decode(response.body)['pagos'] as List)
          .map((pago) => Pago.fromJson(pago))
          .toList();

      return Dinero(prestamos: prestamos, pagos: pagos);
    } else {
      throw Exception('Error en el servidor');
    }
  }

  static Future<void> createPrestamo(
      {required String nombre,
      required double monto,
      required double tasa,
      required DateTime fecha}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/prestamos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'monto': monto,
        'tasa': tasa,
        'fecha': fecha,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error en el servidor');
    }
  }

  static Future<void> createPago({
    required String prestamoId,
    required String nombre,
    required double monto,
    required double restante,
    required DateTime fecha,
    required String tipo,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/pagos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'prestamoId': prestamoId,
        'nombre': nombre,
        'monto': monto,
        'restante': restante,
        'fecha': fecha,
        'tipo': tipo,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error en el servidor');
    }
  }
}
