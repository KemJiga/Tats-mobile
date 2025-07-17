import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/stock.services.dart';
import '../models/stock_item.dart';
import '../models/bolis.dart';
import '../models/materiales.dart';
import '../components/stock_expansion_tile.dart';
import '../components/detail_row.dart';
import '../components/filter_chip.dart';

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
                      child: CustomFilterChip(
                        label: 'Todos',
                        isSelected: _selectedFilter == 'all',
                        onTap: () => _onFilterChanged('all'),
                        selectedColor: Colors.blue,
                        unselectedColor: Colors.grey[100]!,
                        selectedTextColor: Colors.white,
                        unselectedTextColor: Colors.blue,
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomFilterChip(
                        label: 'Bolis',
                        isSelected: _selectedFilter == 'bolis',
                        onTap: () => _onFilterChanged('bolis'),
                        selectedColor: Colors.blue,
                        unselectedColor: Colors.grey[100]!,
                        selectedTextColor: Colors.white,
                        unselectedTextColor: Colors.blue,
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomFilterChip(
                        label: 'Materiales',
                        isSelected: _selectedFilter == 'materiales',
                        onTap: () => _onFilterChanged('materiales'),
                        selectedColor: Colors.blue,
                        unselectedColor: Colors.grey[100]!,
                        selectedTextColor: Colors.white,
                        unselectedTextColor: Colors.blue,
                        elevation: 1,
                      ),
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
                            child: StockExpansionTile(
                                item: _filteredStockItems[index],
                                onUpdated: _loadStockItems),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
