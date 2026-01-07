import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:campuswork/database/database_helper.dart';

/// Provider pour gérer le mode hors connexion
class OfflineProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isOnline = true;
  bool _isLoading = false;

  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  bool get isOffline => !_isOnline;

  OfflineProvider() {
    _checkConnectivity();
    _setupConnectivityListener();
  }

  /// Vérifier la connectivité actuelle
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    notifyListeners();
  }

  /// Écouter les changements de connectivité
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  /// Synchroniser les données locales avec le serveur
  Future<void> syncData() async {
    if (!_isOnline) {
      debugPrint('Cannot sync: offline');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      
      // Sync pending messages
      final pendingMessages = await db.query(
        'messages',
        where: 'synced = ? OR synced IS NULL',
        whereArgs: [0],
      );
      
      // Sync pending orders
      final pendingOrders = await db.query(
        'orders',
        where: 'synced = ? OR synced IS NULL',
        whereArgs: [0],
      );
      
      // In a real app, send these to the server
      // For now, mark as synced
      for (var message in pendingMessages) {
        await db.update(
          'messages',
          {'synced': 1},
          where: 'messageId = ?',
          whereArgs: [message['messageId']],
        );
      }
      
      for (var order in pendingOrders) {
        await db.update(
          'orders',
          {'synced': 1},
          where: 'orderId = ?',
          whereArgs: [order['orderId']],
        );
      }
    } catch (e) {
      debugPrint('Error syncing data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
  
  /// Save data for offline sync
  Future<void> saveForSync(String table, Map<String, dynamic> data) async {
    try {
      final db = await _dbHelper.database;
      data['synced'] = _isOnline ? 1 : 0;
      await db.insert(table, data);
      
      if (_isOnline) {
        // Try to sync immediately
        await syncData();
      }
    } catch (e) {
      debugPrint('Error saving for sync: $e');
    }
  }

  /// Obtenir les données en cache
  Future<List<Map<String, dynamic>>> getCachedData(String table) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(table, orderBy: 'createdAt DESC', limit: 50);
    } catch (e) {
      debugPrint('Error getting cached data: $e');
      return [];
    }
  }
}

