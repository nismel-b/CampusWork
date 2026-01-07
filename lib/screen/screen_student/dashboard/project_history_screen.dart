import 'package:flutter/material.dart';
import 'package:store_buy/service/store_history_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class StoreHistoryScreen extends StatefulWidget {
  final String? storeId;
  const StoreHistoryScreen({super.key, this.storeId});

  @override
  State<StoreHistoryScreen> createState() => _StoreHistoryScreenState();
}

class _StoreHistoryScreenState extends State<StoreHistoryScreen> {
  final StoreHistoryService _historyService = StoreHistoryService();
  final StoreService _storeService = StoreService();
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _stats;
  String? _selectedStoreId;
  int _selectedMonths = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (widget.storeId != null) {
      _selectedStoreId = widget.storeId;
    } else if (authProvider.currentUser != null) {
      final stores = await _storeService.getStoresByUserId(
        authProvider.currentUser!.userId,
      );
      if (stores.isNotEmpty) {
        _selectedStoreId = stores.first['storeId'];
      }
    }

    if (_selectedStoreId != null) {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: 30 * _selectedMonths));
      
      final history = await _historyService.getHistoryByStore(
        _selectedStoreId!,
        startDate: startDate,
        endDate: endDate,
      );
      
      final stats = await _historyService.getMonthlyStats(
        _selectedStoreId!,
        _selectedMonths,
      );

      setState(() {
        _history = history;
        _stats = stats;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: const Color(0xFF3B82F6),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _selectedMonths = value;
                _isLoading = true;
              });
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text('1 mois')),
              const PopupMenuItem(value: 3, child: Text('3 mois')),
              const PopupMenuItem(value: 6, child: Text('6 mois')),
              const PopupMenuItem(value: 12, child: Text('12 mois')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$_selectedMonths mois'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_stats != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Commandes',
                              '${_stats!['orders']?['count'] ?? 0}',
                              Icons.shopping_bag,
                            ),
                            _buildStatItem(
                              'Ventes',
                              '${(_stats!['orders']?['total'] ?? 0.0).toStringAsFixed(0)} FCFA',
                              Icons.attach_money,
                            ),
                            _buildStatItem(
                              'Produits',
                              '${_stats!['products']?['count'] ?? 0}',
                              Icons.inventory_2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _history.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 100, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'Aucun historique',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final entry = _history[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getActionColor(entry['action']),
                                    child: Icon(
                                      _getActionIcon(entry['action']),
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(entry['action'] ?? 'Action'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (entry['details'] != null)
                                        Text(entry['details']),
                                      if (entry['userName'] != null)
                                        Text('Par: ${entry['userName']}'),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(
                                          DateTime.parse(entry['createdAt']),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3B82F6)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Color _getActionColor(String? action) {
    switch (action?.toLowerCase()) {
      case 'order':
        return Colors.green;
      case 'product':
        return Colors.blue;
      case 'employee':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String? action) {
    switch (action?.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag;
      case 'product':
        return Icons.inventory_2;
      case 'employee':
        return Icons.people;
      default:
        return Icons.info;
    }
  }
}


