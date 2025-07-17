import 'package:flutter/material.dart';
import '../models/receta.dart';

class RecetaExpansionTile extends StatelessWidget {
  final Receta receta;
  const RecetaExpansionTile({super.key, required this.receta});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(
        Icons.restaurant_menu,
        color: Colors.orange,
      ),
      title: Text(
        receta.nombre,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${receta.ingredientes.length} ingredientes • ${receta.pasos.length} pasos',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ingredients Section
              const Text(
                'Ingredientes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: receta.ingredientes.map((ingrediente) {
                  return Chip(
                    label: Text(ingrediente),
                    backgroundColor: Colors.orange[50],
                    side: BorderSide(color: Colors.orange[200]!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Steps Section
              const Text(
                'Pasos:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ...receta.pasos.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final paso = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          paso,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${receta.id}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
