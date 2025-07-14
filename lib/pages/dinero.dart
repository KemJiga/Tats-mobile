import 'package:flutter/material.dart';
import '../services/dinero.service.dart';
import '../models/dinero_item.dart';

class DineroPage extends StatefulWidget {
  const DineroPage({super.key});

  @override
  State<DineroPage> createState() => _DineroPageState();
}

class _DineroPageState extends State<DineroPage> {
  List<DineroItem> _dineroItems = [];
  List<DineroItem> _filteredDineroItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'prestamo', 'pago'
  bool? _completionFilter; // null, true (completed), false (pending)
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadDineroItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDineroItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await DineroService.getDineroItems();

      setState(() {
        _dineroItems = items;
        _filteredDineroItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  void _performSearch() {
    final searchQuery = _searchController.text.trim();

    if (searchQuery.isEmpty &&
        _selectedFilter == 'all' &&
        _completionFilter == null &&
        _startDate == null &&
        _endDate == null) {
      setState(() {
        _filteredDineroItems = _dineroItems;
      });
      return;
    }

    List<DineroItem> filteredItems = _dineroItems;

    // Filter by type
    if (_selectedFilter != 'all') {
      filteredItems =
          filteredItems.where((item) => item.type == _selectedFilter).toList();
    }

    // Filter by name or associated prestamo name for pagos
    if (searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      filteredItems = filteredItems.where((item) {
        if (item.nombre.toLowerCase().contains(lowerQuery)) {
          return true;
        }
        if (item is PagoItem) {
          return item.pago.prestamo.nombre.toLowerCase().contains(lowerQuery);
        }
        return false;
      }).toList();
    }

    // Filter by completion status
    if (_completionFilter != null) {
      filteredItems = filteredItems.where((item) {
        if (item is PrestamoItem) {
          final isCompleted =
              DineroService.isPrestamoCompleted(item.prestamo.id);
          return isCompleted == _completionFilter;
        }
        return false;
      }).toList();
    }

    // Filter by date range
    if (_startDate != null || _endDate != null) {
      filteredItems = filteredItems.where((item) {
        if (_startDate != null && item.fecha.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && item.fecha.isAfter(_endDate!)) {
          return false;
        }
        return true;
      }).toList();
    }

    setState(() {
      _filteredDineroItems = filteredItems;
    });
  }

  void _onFilterChanged(String? newFilter) {
    if (newFilter != null && newFilter != _selectedFilter) {
      setState(() {
        _selectedFilter = newFilter;
      });
      _performSearch();
    }
  }

  void _onCompletionFilterChanged(bool? value) {
    setState(() {
      _completionFilter = value;
    });
    _performSearch();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _performSearch();
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _performSearch();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedFilter = 'all';
      _completionFilter = null;
      _startDate = null;
      _endDate = null;
      _filteredDineroItems = _dineroItems;
    });
  }

  String _getFilterSummary() {
    List<String> parts = [];

    if (_searchController.text.isNotEmpty) {
      parts.add('Nombre: "${_searchController.text}"');
    }
    // Removed prestamo name filter summary
    if (_selectedFilter != 'all') {
      parts.add(
          'Tipo: ${_selectedFilter == 'prestamo' ? 'Préstamos' : 'Pagos'}');
    }
    if (_completionFilter != null) {
      parts.add(_completionFilter! ? 'Completados' : 'Pendientes');
    }
    if (_startDate != null || _endDate != null) {
      parts.add('Rango de fechas');
    }

    return parts.isEmpty ? 'Sin filtros aplicados' : parts.join(' • ');
  }

  Widget _buildDineroExpansionTile(DineroItem item) {
    return ExpansionTile(
      leading: Icon(
        item.type == 'prestamo' ? Icons.account_balance : Icons.payment,
        color: item.type == 'prestamo' ? Colors.blue : Colors.green,
      ),
      title: Text(
        item.nombre,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${item.type == 'prestamo' ? 'Préstamo' : 'Pago'} • \$${item.monto.toStringAsFixed(0)} • ${_formatDate(item.fecha)}',
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
              if (item is PrestamoItem) ...[
                _buildDetailRow('Nombre', item.prestamo.nombre),
                _buildDetailRow('Fecha', _formatDate(item.prestamo.fecha)),
                _buildDetailRow(
                    'Monto', '\$${item.prestamo.monto.toStringAsFixed(0)}'),
                _buildDetailRow('Tasa',
                    '${(item.prestamo.tasa * 100).toStringAsFixed(1)}%'),
                _buildDetailRow(
                    'Estado',
                    DineroService.isPrestamoCompleted(item.prestamo.id)
                        ? 'Completado'
                        : 'Pendiente'),
              ] else if (item is PagoItem) ...[
                _buildDetailRow('Nombre', item.pago.nombre),
                _buildDetailRow('Préstamo', item.pago.prestamo.nombre),
                _buildDetailRow('Fecha', _formatDate(item.pago.fecha)),
                _buildDetailRow(
                    'Monto', '\$${item.pago.monto.toStringAsFixed(0)}'),
                _buildDetailRow(
                    'Restante', '\$${item.pago.restante.toStringAsFixed(0)}'),
                _buildDetailRow('Tipo',
                    item.pago.tipo == 'capital' ? 'Capital' : 'Interés'),
              ],
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
            width: 100,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Dinero'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_searchController.text.isNotEmpty ||
              _selectedFilter != 'all' ||
              _completionFilter != null ||
              _startDate != null ||
              _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Limpiar filtros',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Card(
            margin: const EdgeInsets.all(16.0),
            child: ExpansionTile(
              leading: const Icon(Icons.filter_list, color: Colors.green),
              title: const Text(
                'Filtros de búsqueda',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                _getFilterSummary(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              initiallyExpanded: false,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Filter
                      const Text(
                        'Filtrar por tipo:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterChip('Todos', 'all'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterChip('Préstamos', 'prestamo'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterChip('Pagos', 'pago'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Name Search
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _performSearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (_) => _performSearch(),
                      ),

                      const SizedBox(height: 16),

                      // Removed Prestamo Name Search

                      // Completion Status Filter
                      const Text(
                        'Estado del préstamo:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompletionChip('Todos', null),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildCompletionChip('Completados', true),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildCompletionChip('Pendientes', false),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Date Range Filter
                      const Text(
                        'Rango de fechas:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectDateRange,
                              icon: const Icon(Icons.date_range, size: 18),
                              label: Text(
                                _startDate != null && _endDate != null
                                    ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                                    : 'Seleccionar fechas',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[100],
                                foregroundColor: Colors.green[800],
                                elevation: 2,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_startDate != null || _endDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _clearDateRange,
                              icon: const Icon(Icons.clear),
                              tooltip: 'Limpiar fechas',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Elementos encontrados: ${_filteredDineroItems.length}',
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando datos...'),
                      ],
                    ),
                  )
                : _filteredDineroItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron elementos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Intenta con otros filtros',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredDineroItems.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: _buildDineroExpansionTile(
                                _filteredDineroItems[index]),
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
          color: isSelected ? Colors.white : Colors.green,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(value),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.green,
      checkmarkColor: Colors.white,
      elevation: isSelected ? 4 : 1,
    );
  }

  Widget _buildCompletionChip(String label, bool? value) {
    final isSelected = _completionFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.green,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => _onCompletionFilterChanged(value),
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.green,
      checkmarkColor: Colors.white,
      elevation: isSelected ? 4 : 1,
    );
  }
}
