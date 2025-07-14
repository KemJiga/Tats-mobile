import 'package:flutter/material.dart';
import '../services/receta.service.dart';
import '../models/receta.dart';

class RecetarioPage extends StatefulWidget {
  const RecetarioPage({super.key});

  @override
  State<RecetarioPage> createState() => _RecetarioPageState();
}

class _RecetarioPageState extends State<RecetarioPage> {
  List<Receta> _recetas = [];
  List<Receta> _filteredRecetas = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedIngredientes = [];
  List<String> _availableIngredientes = [];

  @override
  void initState() {
    super.initState();
    _loadRecetas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecetas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recetas = await RecetaService.getRecetas();
      setState(() {
        _recetas = recetas;
        _filteredRecetas = recetas;
        _isLoading = false;
      });
      _loadIngredientes();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando recetas: $e')),
        );
      }
    }
  }

  void _loadIngredientes() {
    Set<String> allIngredientes = {};
    for (var receta in _recetas) {
      allIngredientes.addAll(receta.ingredientes);
    }
    setState(() {
      _availableIngredientes = allIngredientes.toList()..sort();
    });
  }

  void _performSearch() {
    final searchQuery = _searchController.text.trim();

    if (searchQuery.isEmpty && _selectedIngredientes.isEmpty) {
      setState(() {
        _filteredRecetas = _recetas;
      });
      return;
    }

    List<Receta> filteredRecetas = _recetas;

    // Filter by name if provided
    if (searchQuery.isNotEmpty) {
      filteredRecetas = filteredRecetas
          .where((receta) =>
              receta.nombre.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by ingredients if provided
    if (_selectedIngredientes.isNotEmpty) {
      filteredRecetas = filteredRecetas.where((receta) {
        // Check if ALL specified ingredients are present in the recipe
        return _selectedIngredientes.every((ingrediente) => receta.ingredientes
            .any((recetaIngrediente) => recetaIngrediente
                .toLowerCase()
                .contains(ingrediente.toLowerCase())));
      }).toList();
    }

    setState(() {
      _filteredRecetas = filteredRecetas;
    });
  }

  void _onIngredienteToggled(String ingrediente) {
    setState(() {
      if (_selectedIngredientes.contains(ingrediente)) {
        _selectedIngredientes.remove(ingrediente);
      } else {
        _selectedIngredientes.add(ingrediente);
      }
    });
    _performSearch();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedIngredientes.clear();
      _filteredRecetas = _recetas;
    });
  }

  String _getFilterSummary() {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasIngredients = _selectedIngredientes.isNotEmpty;

    if (!hasSearch && !hasIngredients) {
      return 'Sin filtros aplicados';
    }

    List<String> parts = [];
    if (hasSearch) {
      parts.add('Nombre: "${_searchController.text}"');
    }
    if (hasIngredients) {
      parts.add(
          '${_selectedIngredientes.length} ingrediente${_selectedIngredientes.length == 1 ? '' : 's'}');
    }

    return parts.join(' • ');
  }

  Widget _buildRecetaExpansionTile(Receta receta) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_searchController.text.isNotEmpty ||
              _selectedIngredientes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Limpiar filtros',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Card(
            margin: const EdgeInsets.all(16.0),
            child: ExpansionTile(
              leading: const Icon(Icons.filter_list, color: Colors.orange),
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
                      // Name Search
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre de receta...',
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

                      // Ingredients Filter
                      const Text(
                        'Filtrar por ingredientes:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _availableIngredientes.map((ingrediente) {
                          final isSelected =
                              _selectedIngredientes.contains(ingrediente);
                          return FilterChip(
                            label: Text(ingrediente),
                            selected: isSelected,
                            onSelected: (_) =>
                                _onIngredienteToggled(ingrediente),
                            backgroundColor: Colors.grey[100],
                            selectedColor: Colors.orange[200],
                            checkmarkColor: Colors.orange[800],
                          );
                        }).toList(),
                      ),

                      if (_selectedIngredientes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Mostrando recetas que contienen TODOS los ingredientes seleccionados',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Section
          Text('Recetas encontradas: ${_filteredRecetas.length}',
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              )),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando recetas...'),
                      ],
                    ),
                  )
                : _filteredRecetas.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron recetas',
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
                        itemCount: _filteredRecetas.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: _buildRecetaExpansionTile(
                                _filteredRecetas[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
