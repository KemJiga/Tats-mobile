import 'package:flutter/material.dart';
import '../components/forms/boli_form.dart';
import '../components/forms/material_form.dart';
import '../components/forms/pago_form.dart';
import '../components/forms/prestamo_form.dart';
import '../components/forms/receta_form.dart';

// Enum for the create form type
enum CreateFormType { boli, material, pago, prestamo, receta }

class CreatePage extends StatelessWidget {
  final CreateFormType formType;
  const CreatePage({super.key, required this.formType});

  @override
  Widget build(BuildContext context) {
    Widget form;
    String title;
    switch (formType) {
      case CreateFormType.boli:
        form = BoliForm();
        title = 'Nuevo Boli';
        break;
      case CreateFormType.material:
        form = MaterialForm();
        title = 'Nuevo Material';
        break;
      case CreateFormType.pago:
        form = PagoForm();
        title = 'Nuevo Pago';
        break;
      case CreateFormType.prestamo:
        form = PrestamoForm();
        title = 'Nuevo Préstamo';
        break;
      case CreateFormType.receta:
        form = RecetaForm();
        title = 'Nueva Receta';
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: form,
      ),
    );
  }
}
