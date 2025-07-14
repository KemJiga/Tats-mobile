import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/stock.services.dart';
import '../models/stock_item.dart';
import '../models/bolis.dart';
import '../models/materiales.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<StockItem> _stockItems = [];
  List<StockItem> _filteredStockItems = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'bolis', 'materiales'

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    setState(() {
      _isLoading = true;
    });
    final items = await StockService.getStockItems();

    setState(() {
      _stockItems = items;
      _filteredStockItems = items;
      _isLoading = false;
    });
  }

  void _onFilterChanged(String? newFilter) {
    if (newFilter != null && newFilter != _selectedFilter) {
      setState(() {
        _selectedFilter = newFilter;
        _filteredStockItems = _stockItems
            .where((item) => newFilter == 'all' || item.type == newFilter)
            .toList();
      });
    }
  }

  void _copyBolisToClipboard() {
    final bolisItems = _stockItems.whereType<BolisItem>().toList();

    if (bolisItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay bolis en stock para copiar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln(
        'A la orden, Refrescantes, Cremosos y Deliciosos Bolis a \$2.000 en Ceiba #148.');
    buffer.writeln('');
    buffer.writeln('Sabores disponibles: ');

    for (final bolis in bolisItems) {
      buffer.writeln('- ${bolis.sabor}');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString())).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock de bolis copiado al portapapeles'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _buildExpansionTile(StockItem item) {
    return ExpansionTile(
      leading: Icon(
        item.type == 'bolis' ? Icons.icecream : Icons.inventory,
        color: item.type == 'bolis' ? Colors.purple : Colors.orange,
      ),
      title: Text(
        item.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${item.type.toUpperCase()} - Cantidad: ${item.cantidad}',
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
              if (item is BolisItem) ...[
                _buildDetailRow('Sabor', item.sabor),
                _buildDetailRow('Cantidad', '${item.cantidad}'),
                _buildDetailRow(
                    'Ganancia por Unidad', '\$${item.gananciaPorUnidad}'),
              ] else if (item is MaterialesItem) ...[
                _buildDetailRow('Nombre', item.nombre),
                _buildDetailRow('Cantidad', '${item.cantidad}'),
                _buildDetailRow('Unidad', item.unidad),
                _buildDetailRow('Presentación', '${item.presentacion}'),
                _buildDetailRow('Precio', '\$${item.precio}'),
              ],
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${item.id}',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar por tipo:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip('Todos', 'all'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip('Bolis', 'bolis'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip('Materiales', 'materiales'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copyBolisToClipboard,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copiar Stock Bolis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[100],
                          foregroundColor: Colors.purple[800],
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando stock...'),
                      ],
                    ),
                  )
                : _filteredStockItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay elementos en stock',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredStockItems.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child:
                                _buildExpansionTile(_filteredStockItems[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blue,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(value),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      elevation: isSelected ? 4 : 1,
    );
  }
}
