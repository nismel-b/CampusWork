import 'package:flutter/foundation.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isLecturer => _currentUser?.isLecturer ?? false;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null) {
        _currentUser = await _authService.getUserById(userId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<bool> register({
    required String username,
    required String firstname,
    required String lastname,
    required String email,
    required String phonenumber,
    required String password,
    required UserRole userRole,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final exists = await _authService.usernameExists(username);
      if (exists) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = await _authService.registerUser(
        firstname: firstname,
        lastname: lastname,
        username: username,
        email: email,
        phonenumber: phonenumber,
        password: password,
        userRole: userRole,
      );

      if (user != null) {
        _currentUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.userId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error registering: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.loginUser(
        username: username,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.userId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }
}



