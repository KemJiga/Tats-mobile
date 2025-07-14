import '../models/prestamo.dart';
import '../models/pago.dart';
import '../models/dinero_item.dart';

class DineroService {
  static final List<Prestamo> _mockPrestamos = [
    Prestamo(
      id: "22fb5a84-f7b4-81d5-8e67-f0f351552623",
      nombre: "Juan Pérez",
      fecha: DateTime.parse("2024-01-15T10:00:00.000+00:00"),
      monto: 50000,
      tasa: 0.05,
    ),
    Prestamo(
      id: "22fb5a84-f7b4-81d5-8e67-f0f351552624",
      nombre: "María García",
      fecha: DateTime.parse("2024-02-10T14:30:00.000+00:00"),
      monto: 75000,
      tasa: 0.04,
    ),
    Prestamo(
      id: "22fb5a84-f7b4-81d5-8e67-f0f351552625",
      nombre: "Carlos López",
      fecha: DateTime.parse("2024-03-05T09:15:00.000+00:00"),
      monto: 30000,
      tasa: 0.06,
    ),
    Prestamo(
      id: "22fb5a84-f7b4-81d5-8e67-f0f351552626",
      nombre: "Ana Rodríguez",
      fecha: DateTime.parse("2024-01-20T16:45:00.000+00:00"),
      monto: 100000,
      tasa: 0.03,
    ),
  ];

  static final List<Pago> _mockPagos = [
    Pago(
      id: "22fb5a84-f7b4-81a1-b79f-d9da43605da7",
      nombre: "Pago Capital",
      prestamoId: "22fb5a84-f7b4-81d5-8e67-f0f351552623",
      prestamo: _mockPrestamos[0],
      fecha: DateTime.parse("2024-01-20T14:30:00.000+00:00"),
      monto: 10000,
      restante: 40000,
      tipo: "capital",
    ),
    Pago(
      id: "22fb5a84-f7b4-81a1-b79f-d9da43605da8",
      nombre: "Pago Interés",
      prestamoId: "22fb5a84-f7b4-81d5-8e67-f0f351552623",
      prestamo: _mockPrestamos[0],
      fecha: DateTime.parse("2024-02-15T10:00:00.000+00:00"),
      monto: 2500,
      restante: 40000,
      tipo: "interes",
    ),
    Pago(
      id: "22fb5a84-f7b4-81a1-b79f-d9da43605da9",
      nombre: "Pago Capital",
      prestamoId: "22fb5a84-f7b4-81d5-8e67-f0f351552623",
      prestamo: _mockPrestamos[0],
      fecha: DateTime.parse("2024-03-15T14:30:00.000+00:00"),
      monto: 40000,
      restante: 0,
      tipo: "capital",
    ),
    Pago(
      id: "22fb5a84-f7b4-81a1-b79f-d9da43605daa",
      nombre: "Pago Capital",
      prestamoId: "22fb5a84-f7b4-81d5-8e67-f0f351552624",
      prestamo: _mockPrestamos[1],
      fecha: DateTime.parse("2024-03-10T16:00:00.000+00:00"),
      monto: 25000,
      restante: 50000,
      tipo: "capital",
    ),
    Pago(
      id: "22fb5a84-f7b4-81a1-b79f-d9da43605dab",
      nombre: "Pago Interés",
      prestamoId: "22fb5a84-f7b4-81d5-8e67-f0f351552624",
      prestamo: _mockPrestamos[1],
      fecha: DateTime.parse("2024-04-10T14:30:00.000+00:00"),
      monto: 2000,
      restante: 50000,
      tipo: "interes",
    ),
    Pago(
      id: "22fb5a84-f7b4-81a1-b79f-d9da43605dac",
      nombre: "Pago Capital",
      prestamoId: "22fb5a84-f7b4-81d5-8e67-f0f351552625",
      prestamo: _mockPrestamos[2],
      fecha: DateTime.parse("2024-04-05T11:00:00.000+00:00"),
      monto: 30000,
      restante: 0,
      tipo: "capital",
    ),
    Pago(
      id: "22fb5a84-f7b4-81a1-b79f-d9da43605dad",
      nombre: "Pago Capital",
      prestamoId: "22fb5a84-f7b4-81d5-8e67-f0f351552626",
      prestamo: _mockPrestamos[3],
      fecha: DateTime.parse("2024-02-20T15:30:00.000+00:00"),
      monto: 50000,
      restante: 50000,
      tipo: "capital",
    ),
  ];

  static Future<List<DineroItem>> getDineroItems({
    String? filterType,
    String? nombreQuery,
    String? prestamoNombreQuery,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    List<DineroItem> allItems = [
      ..._mockPrestamos.map((p) => PrestamoItem(p)),
      ..._mockPagos.map((p) => PagoItem(p)),
    ];

    // Filter by type
    if (filterType != null && filterType.isNotEmpty) {
      allItems = allItems.where((item) => item.type == filterType).toList();
    }

    // Filter by name
    if (nombreQuery != null && nombreQuery.isNotEmpty) {
      allItems = allItems
          .where((item) =>
              item.nombre.toLowerCase().contains(nombreQuery.toLowerCase()))
          .toList();
    }

    // Filter by prestamo name (for pagos)
    if (prestamoNombreQuery != null && prestamoNombreQuery.isNotEmpty) {
      allItems = allItems.where((item) {
        if (item is PagoItem) {
          return item.pago.prestamo.nombre
              .toLowerCase()
              .contains(prestamoNombreQuery.toLowerCase());
        }
        return false;
      }).toList();
    }

    // Filter by completion status
    if (isCompleted != null) {
      allItems = allItems.where((item) {
        if (item is PrestamoItem) {
          // Check if prestamo is completed (has a pago with restante = 0)
          final lastPago = _mockPagos
              .where((p) => p.prestamoId == item.prestamo.id)
              .toList()
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
          return lastPago.isNotEmpty && lastPago.first.restante == 0;
        }
        return false;
      }).toList();
    }

    // Filter by date range
    if (startDate != null || endDate != null) {
      allItems = allItems.where((item) {
        if (startDate != null && item.fecha.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && item.fecha.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    }

    return allItems;
  }

  static Future<List<Prestamo>> getPrestamos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPrestamos;
  }

  static Future<List<Pago>> getPagos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPagos;
  }

  static List<String> getAllPrestamoNombres() {
    return _mockPrestamos.map((p) => p.nombre).toList()..sort();
  }

  static bool isPrestamoCompleted(String prestamoId) {
    final pagos = _mockPagos.where((p) => p.prestamoId == prestamoId).toList();
    if (pagos.isEmpty) return false;
    pagos.sort((a, b) => b.fecha.compareTo(a.fecha));
    return pagos.first.restante == 0;
  }
}

// Helper classes to make Prestamo and Pago implement DineroItem
class PrestamoItem extends DineroItem {
  final Prestamo prestamo;

  PrestamoItem(this.prestamo)
      : super(
          id: prestamo.id,
          nombre: prestamo.nombre,
          fecha: prestamo.fecha,
          monto: prestamo.monto,
          type: 'prestamo',
        );
}

class PagoItem extends DineroItem {
  final Pago pago;

  PagoItem(this.pago)
      : super(
          id: pago.id,
          nombre: pago.nombre,
          fecha: pago.fecha,
          monto: pago.monto,
          type: 'pago',
        );
}
