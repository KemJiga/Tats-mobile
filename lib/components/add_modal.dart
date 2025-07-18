import 'package:flutter/material.dart';
import '../pages/create_page.dart';

/// Enum to represent the context in which the AddModal is used
enum AddModalType { stock, dinero, recetario }

/// Shows the AddModal with dynamic content based on [type]
void showAddModal(BuildContext context, AddModalType type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => AddModal(type: type),
  );
}

/// FloatingActionButton that opens the AddModal
class AddModalFAB extends StatelessWidget {
  final AddModalType type;
  const AddModalFAB({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton(
        onPressed: () => showAddModal(context, type),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// The modal content, dynamic based on [type]
class AddModal extends StatelessWidget {
  final AddModalType type;
  const AddModal({super.key, required this.type});

  void _navigateToCreatePage(BuildContext context, CreateFormType formType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatePage(formType: formType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<_AddOption> options;
    switch (type) {
      case AddModalType.stock:
        options = [
          _AddOption('Nuevo Boli', Icons.icecream, () {
            _navigateToCreatePage(context, CreateFormType.boli);
          }),
          _AddOption('Nuevo Material', Icons.category, () {
            _navigateToCreatePage(context, CreateFormType.material);
          }),
        ];
        break;
      case AddModalType.dinero:
        options = [
          _AddOption('Nuevo Pago', Icons.payments, () {
            _navigateToCreatePage(context, CreateFormType.pago);
          }),
          _AddOption('Nuevo Préstamo', Icons.account_balance_wallet, () {
            _navigateToCreatePage(context, CreateFormType.prestamo);
          }),
        ];
        break;
      case AddModalType.recetario:
        options = [
          _AddOption('Nueva Receta', Icons.book, () {
            _navigateToCreatePage(context, CreateFormType.receta);
          }),
        ];
        break;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Wrap(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          ...options.map((opt) => ListTile(
                leading: Icon(opt.icon),
                title: Text(opt.label),
                onTap: () {
                  Navigator.of(context).pop();
                  opt.onTap();
                },
              )),
        ],
      ),
    );
  }
}

class _AddOption {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _AddOption(this.label, this.icon, this.onTap);
}
