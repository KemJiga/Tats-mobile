import 'package:flutter/material.dart';
import '../pages/stock.dart';
import '../pages/dinero.dart';
import '../pages/recetario.dart';

class TabsComponent extends StatefulWidget {
  const TabsComponent({super.key});

  @override
  State<TabsComponent> createState() => _TabsComponentState();
}

class _TabsComponentState extends State<TabsComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          StockPage(),
          DineroPage(),
          RecetarioPage(),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.inventory),
            text: 'Stock',
          ),
          Tab(
            icon: Icon(Icons.attach_money),
            text: 'Dinero',
          ),
          Tab(
            icon: Icon(Icons.menu_book),
            text: 'Recetario',
          ),
        ],
      ),
    );
  }
}
