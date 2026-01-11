import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/auth/auth_service.dart';

class OAuthService {
  static final OAuthService _instance = OAuthService._internal();
  factory OAuthService() => _instance;
  OAuthService._internal();

  // Google Sign In instance
  GoogleSignIn get _googleSignIn => GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // ========================================
  // GOOGLE SIGN IN
  // ========================================
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔵 Starting Google Sign In...');
      
      // Sign out first to force account selection
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ Google sign in cancelled by user');
        return null;
      }

      debugPrint('✅ Google authentication successful');
      debugPrint('📧 Email: ${googleUser.email}');
      debugPrint('👤 Name: ${googleUser.displayName}');

      // Check if user already exists
      final existingUser = await AuthService().getUserByEmail(googleUser.email);
      
      if (existingUser != null) {
        debugPrint('✅ User already exists, logging in...');
        // User exists, save session
        await AuthService().loginUser(
          username: existingUser.username,
          password: existingUser.password, // Use stored password
        );
        return existingUser;
      }

      debugPrint('📝 Creating new user from Google account...');

      // Create new user
      final names = googleUser.displayName?.split(' ') ?? ['User', ''];
      final firstName = names.isNotEmpty ? names.first : 'User';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'Google';

      // Generate unique username from email
      String baseUsername = googleUser.email.split('@').first;
      String username = baseUsername;
      int counter = 1;
      
      // Ensure username is unique
      while (await AuthService().usernameExists(username)) {
        username = '$baseUsername$counter';
        counter++;
      }

      final user = await AuthService().registerUser(
        firstname: firstName,
        lastname: lastName,
        username: username,
        email: googleUser.email,
        phonenumber: '', // Optional for OAuth
        password: _generateRandomPassword(), // Generate random password
        userRole: UserRole.student, // Default role
      );

      if (user != null) {
        debugPrint('✅ New user created successfully: ${user.username}');
        // Auto login after registration
        await AuthService().loginUser(
          username: user.username,
          password: user.password,
        );
      }

      return user;
    } catch (e) {
      debugPrint('❌ Error signing in with Google: $e');
      return null;
    }
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(16, (index) => chars[(random + index) % chars.length]).join();
  }

  // Sign out from all providers
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await AuthService().logout();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
    }
  }
}