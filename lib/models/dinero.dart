import 'prestamo.dart';
import 'pago.dart';

class Dinero {
  final List<Prestamo> prestamos;
  final List<Pago> pagos;

  Dinero({
    required this.prestamos,
    required this.pagos,
  });
}
