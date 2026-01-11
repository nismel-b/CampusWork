import 'package:flutter/foundation.dart';
import 'package:campuswork/services/card_service.dart';

class CartItem {
  final String? cartId;
  final String userId;
  final String projectId;
  final String projectName;
  final String? imageUrl;
  final String? username;
  final int quantity;

  CartItem({
    this.cartId,
    required this.userId,
    required this.projectId,
    required this.projectName,
    this.imageUrl,
    this.username,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'userId': userId,
      'projectId': projectId,
      'projectName': projectName,
      'imageUrl': imageUrl,
      'username': username,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      cartId: map['cardId'], // Note: le service utilise 'cardId'
      userId: map['userId'] ?? '',
      projectId: map['projectId'] ?? '',
      projectName: map['projectName'] ?? '',
      imageUrl: map['imageUrl'],
      username: map['username'],
      quantity: 1, // Le service card ne gère pas les quantités
    );
  }
}

class CartProvider with ChangeNotifier {
  final CardService _cardService = CardService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _userId;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.length;

  void setUserId(String userId) {
    _userId = userId;
    loadCart();
  }

  Future<void> loadCart() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cardService.getCardItems(_userId!);
      _cartItems = items.map((item) => CartItem.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(String projectId) async {
    if (_userId == null) return false;

    try {
      final cardId = 'card_${DateTime.now().millisecondsSinceEpoch}';
      final success = await _cardService.addToPanel(
        cardId: cardId,
        userId: _userId!,
        projectId: projectId,
      );
      if (success) {
        await loadCart();
        return true;
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
    return false;
  }

  Future<bool> removeFromCart(String projectId) async {
    if (_userId == null) return false;

    try {
      final success = await _cardService.removeFromPanel(_userId!, projectId);
      if (success) {
        await loadCart();
        return true;
      }
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
    return false;
  }

  Future<bool> clearCart() async {
    if (_userId == null) return false;

    try {
      final success = await _cardService.clearPanel(_userId!);
      if (success) {
        _cartItems = [];
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
    return false;
  }

  bool isInCart(String projectId) {
    return _cartItems.any((item) => item.projectId == projectId);
  }

  CartItem? getCartItem(String projectId) {
    try {
      return _cartItems.firstWhere((item) => item.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  Future<int> getCartCount() async {
    if (_userId == null) return 0;
    return await _cardService.getPanelCount(_userId!);
  }
}


