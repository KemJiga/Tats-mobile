import 'package:flutter/material.dart';
import '../services/dinero.service.dart';
import '../models/prestamo.dart';
import '../models/pago.dart';
import '../models/dinero.dart';
import '../components/dinero_expansion_tile.dart';
import '../components/detail_row.dart';
import '../components/filter_chip.dart';
import '../components/completion_chip.dart';

class DineroPage extends StatefulWidget {
  const DineroPage({super.key});

  @override
  State<DineroPage> createState() => _DineroPageState();
}

class _DineroPageState extends State<DineroPage> {
  Dinero _dinero = Dinero(prestamos: [], pagos: []);
  List<Prestamo> _prestamos = [];
  List<Pago> _pagos = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'prestamo', 'pago'
  bool? _completionFilter; // null, true (completed), false (pending)
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadDinero();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDinero() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dinero = await DineroService.getDinero();
      setState(() {
        _dinero = dinero;
        _prestamos = dinero.prestamos;
        _pagos = dinero.pagos;
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
    final searchQuery = _searchController.text.trim().toLowerCase();
    List<Prestamo> prestamos = _dinero.prestamos;
    List<Pago> pagos = _dinero.pagos;

    // Filter by type
    if (_selectedFilter == 'prestamo') {
      pagos = [];
    } else if (_selectedFilter == 'pago') {
      prestamos = [];
    }

    // Filter by name
    if (searchQuery.isNotEmpty) {
      prestamos = prestamos
          .where((p) => p.nombre.toLowerCase().contains(searchQuery))
          .toList();
      pagos = pagos
          .where((p) =>
              p.nombre.toLowerCase().contains(searchQuery) ||
              p.prestamo.nombre.toLowerCase().contains(searchQuery))
          .toList();
    }

    // Filter by completion status (only applies to prestamos)
    if (_completionFilter != null) {
      prestamos = prestamos
          .where((p) => _isPrestamoCompleted(p) == _completionFilter)
          .toList();
    }

    // Filter by date range
    if (_startDate != null || _endDate != null) {
      if (_startDate != null) {
        prestamos =
            prestamos.where((p) => !p.fecha.isBefore(_startDate!)).toList();
        pagos = pagos.where((p) => !p.fecha.isBefore(_startDate!)).toList();
      }
      if (_endDate != null) {
        prestamos =
            prestamos.where((p) => !p.fecha.isAfter(_endDate!)).toList();
        pagos = pagos.where((p) => !p.fecha.isAfter(_endDate!)).toList();
      }
    }

    setState(() {
      _prestamos = prestamos;
      _pagos = pagos;
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
      _prestamos = _dinero.prestamos;
      _pagos = _dinero.pagos;
    });
  }

  String _getFilterSummary() {
    List<String> parts = [];
    if (_searchController.text.isNotEmpty) {
      parts.add('Nombre: "${_searchController.text}"');
    }
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

  // Helper to combine and sort prestamos and pagos by date
  List<Map<String, dynamic>> _getCombinedSortedList() {
    final List<Map<String, dynamic>> combined = [
      ..._prestamos.map((p) => {'type': 'prestamo', 'data': p}),
      ..._pagos.map((p) => {'type': 'pago', 'data': p}),
    ];
    combined.sort((a, b) {
      final dateA = a['type'] == 'prestamo'
          ? (a['data'] as Prestamo).fecha
          : (a['data'] as Pago).fecha;
      final dateB = b['type'] == 'prestamo'
          ? (b['data'] as Prestamo).fecha
          : (b['data'] as Pago).fecha;
      return dateB.compareTo(dateA); // newest first
    });
    return combined;
  }

  // Helper to determine if a Prestamo is completed
  bool _isPrestamoCompleted(Prestamo prestamo) {
    // Get all pagos for this prestamo
    final pagosPrestamo = _dinero.pagos
        .where((p) => p.prestamoId == prestamo.id && p.tipo == 'capital')
        .toList();
    if (pagosPrestamo.isEmpty) return false;
    // Option 1: Check if last pago has restante == 0
    pagosPrestamo.sort((a, b) => a.fecha.compareTo(b.fecha));
    if (pagosPrestamo.last.restante == 0) return true;
    // Option 2: Check if sum of pagos >= monto
    final totalPagado = pagosPrestamo.fold(0.0, (sum, p) => sum + p.monto);
    return totalPagado >= prestamo.monto;
  }

  Widget _buildDineroExpansionTile(Map<String, dynamic> item) {
    return DineroExpansionTile(
      item: item,
      isPrestamoCompleted: _isPrestamoCompleted,
      formatDate: _formatDate,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final combinedList = _getCombinedSortedList();
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
              'Elementos encontrados: ${combinedList.length}',
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
                : combinedList.isEmpty
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
                        itemCount: combinedList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child:
                                _buildDineroExpansionTile(combinedList[index]),
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
    return CustomFilterChip(
      label: label,
      isSelected: isSelected,
      onTap: () => _onFilterChanged(value),
      selectedColor: Colors.green,
      unselectedColor: Colors.grey[100]!,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.green,
      elevation: 1,
    );
  }

  Widget _buildCompletionChip(String label, bool? value) {
    final isSelected = _completionFilter == value;
    return CompletionChip(
      label: label,
      isSelected: isSelected,
      onTap: () => _onCompletionFilterChanged(value),
      selectedColor: Colors.green,
      unselectedColor: Colors.grey[100]!,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.green,
      elevation: 1,
    );
  }
}
