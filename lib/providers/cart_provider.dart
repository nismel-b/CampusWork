import 'package:flutter/foundation.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/services/project-services.dart';
import 'package:campuswork/services/card_service.dart';


class CartProvider with ChangeNotifier {
  final CardService _cartService = CardService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _userId;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;


  void setUserId(String userId) {
    _userId = userId;
    loadCart();
  }

  Future<void> loadCart() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cartService.getCartItems(_userId!);
      _cartItems = items.map((item) {
        return CartItem(
          cartId: item['cartId'] as String?,
          userId: _userId!,
          projectId: item['projectId'] as String,
          project: Project.fromMap(item),
          projectname: item['projectname'] as String?,
          studentId: item['studentId'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(Project project, {int quantity = 1}) async {
    if (_userId == null) return false;

    try {
      final success = await _cartService.addToCart(
        userId: _userId!,
        projectId: project.projectId!,
        quantity: quantity,
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

  Future<bool> updateQuantity(String productId, int quantity) async {
    if (_userId == null) return false;

    try {
      final success = await _cartService.updateCartItemQuantity(
        userId: _userId!,
        productId: productId,
        quantity: quantity,
      );
      if (success) {
        await loadCart();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
    return false;
  }

  Future<bool> removeFromCart(String productId) async {
    if (_userId == null) return false;

    try {
      final success = await _cartService.removeFromCart(_userId!, productId);
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
      final success = await _cartService.clearCart(_userId!);
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
}


