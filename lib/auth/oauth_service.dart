import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  // GitHub OAuth Configuration
  static const String _githubClientId = 'YOUR_GITHUB_CLIENT_ID'; // À remplacer
  static const String _githubClientSecret = 'YOUR_GITHUB_CLIENT_SECRET'; // À remplacer
  static const String _githubRedirectUri = 'campuswork://auth';

  // LinkedIn OAuth Configuration
  static const String _linkedinClientId = 'YOUR_LINKEDIN_CLIENT_ID'; // À remplacer
  static const String _linkedinClientSecret = 'YOUR_LINKEDIN_CLIENT_SECRET'; // À remplacer
  static const String _linkedinRedirectUri = 'campuswork://auth';

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
  // GITHUB SIGN IN
  // ========================================
  Future<User?> signInWithGitHub() async {
    try {
      debugPrint('🐙 Starting GitHub Sign In...');
      
      // Build authorization URL
      final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': _githubClientId,
        'redirect_uri': _githubRedirectUri,
        'scope': 'user:email',
      });

      // Authenticate
      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'campuswork',
      );

      // Extract code from callback URL
      final code = Uri.parse(result).queryParameters['code'];

      if (code == null) {
        debugPrint('⚠️ GitHub authorization cancelled');
        return null;
      }

      debugPrint('🔑 Exchanging code for access token...');

      // Exchange code for access token
      final tokenResponse = await http.post(
        Uri.https('github.com', '/login/oauth/access_token'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': _githubClientId,
          'client_secret': _githubClientSecret,
          'code': code,
          'redirect_uri': _githubRedirectUri,
        },
      );

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      if (accessToken == null) {
        debugPrint('❌ Failed to get GitHub access token');
        return null;
      }

      debugPrint('✅ Access token obtained');

      // Get user info
      final userResponse = await http.get(
        Uri.https('api.github.com', '/user'),
        headers: {
          'Authorization': 'token $accessToken',
          'Accept': 'application/json',
        },
      );

      final userData = jsonDecode(userResponse.body);

      // Get user email (might be private)
      final emailResponse = await http.get(
        Uri.https('api.github.com', '/user/emails'),
        headers: {
          'Authorization': 'token $accessToken',
          'Accept': 'application/json',
        },
      );

      final emails = jsonDecode(emailResponse.body) as List;
      final primaryEmail = emails.firstWhere(
        (email) => email['primary'] == true,
        orElse: () => emails.first,
      )['email'] as String;

      debugPrint('✅ GitHub authentication successful');
      debugPrint('📧 Email: $primaryEmail');
      debugPrint('👤 Username: ${userData['login']}');

      // Check if user exists
      final existingUser = await AuthService().getUserByEmail(primaryEmail);
      
      if (existingUser != null) {
        debugPrint('✅ User already exists, logging in...');
        await AuthService().loginUser(
          username: existingUser.username,
          password: existingUser.password,
        );
        return existingUser;
      }

      debugPrint('📝 Creating new user from GitHub account...');

      // Create new user
      final fullName = userData['name'] ?? userData['login'];
      final names = fullName.toString().split(' ');
      final firstName = names.isNotEmpty ? names.first : 'User';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'GitHub';

      // Generate unique username
      String username = userData['login'] as String;
      int counter = 1;
      
      while (await AuthService().usernameExists(username)) {
        username = '${userData['login']}$counter';
        counter++;
      }

      final user = await AuthService().registerUser(
        firstname: firstName,
        lastname: lastName,
        username: username,
        email: primaryEmail,
        phonenumber: '',
        password: _generateRandomPassword(),
        userRole: UserRole.student,
      );

      if (user != null) {
        debugPrint('✅ New user created successfully: ${user.username}');
        await AuthService().loginUser(
          username: user.username,
          password: user.password,
        );
      }

      return user;
    } catch (e) {
      debugPrint('❌ Error signing in with GitHub: $e');
      return null;
    }
  }

  // ========================================
  // LINKEDIN SIGN IN
  // ========================================
  Future<User?> signInWithLinkedIn() async {
    try {
      debugPrint('💼 Starting LinkedIn Sign In...');
      
      // Build authorization URL
      final authUrl = Uri.https('www.linkedin.com', '/oauth/v2/authorization', {
        'response_type': 'code',
        'client_id': _linkedinClientId,
        'redirect_uri': _linkedinRedirectUri,
        'scope': 'r_liteprofile r_emailaddress',
      });

      // Authenticate
      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'campuswork',
      );

      // Extract code from callback URL
      final code = Uri.parse(result).queryParameters['code'];

      if (code == null) {
        debugPrint('⚠️ LinkedIn authorization cancelled');
        return null;
      }

      debugPrint('🔑 Exchanging code for access token...');

      // Exchange code for access token
      final tokenResponse = await http.post(
        Uri.https('www.linkedin.com', '/oauth/v2/accessToken'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _linkedinRedirectUri,
          'client_id': _linkedinClientId,
          'client_secret': _linkedinClientSecret,
        },
      );

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      if (accessToken == null) {
        debugPrint('❌ Failed to get LinkedIn access token');
        return null;
      }

      debugPrint('✅ Access token obtained');

      // Get user profile
      final profileResponse = await http.get(
        Uri.https('api.linkedin.com', '/v2/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      final profileData = jsonDecode(profileResponse.body);

      // Get user email
      final emailResponse = await http.get(
        Uri.https('api.linkedin.com', '/v2/emailAddress', {
          'q': 'members',
          'projection': '(elements*(handle~))',
        }),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      final emailData = jsonDecode(emailResponse.body);
      final email = emailData['elements'][0]['handle~']['emailAddress'] as String;

      debugPrint('✅ LinkedIn authentication successful');
      debugPrint('📧 Email: $email');

      // Check if user exists
      final existingUser = await AuthService().getUserByEmail(email);
      
      if (existingUser != null) {
        debugPrint('✅ User already exists, logging in...');
        await AuthService().loginUser(
          username: existingUser.username,
          password: existingUser.password,
        );
        return existingUser;
      }

      debugPrint('📝 Creating new user from LinkedIn account...');

      // Create new user
      final firstName = profileData['localizedFirstName'] ?? 'User';
      final lastName = profileData['localizedLastName'] ?? 'LinkedIn';
      
      // Generate unique username
      String baseUsername = email.split('@').first;
      String username = baseUsername;
      int counter = 1;
      
      while (await AuthService().usernameExists(username)) {
        username = '$baseUsername$counter';
        counter++;
      }

      final user = await AuthService().registerUser(
        firstname: firstName,
        lastname: lastName,
        username: username,
        email: email,
        phonenumber: '',
        password: _generateRandomPassword(),
        userRole: UserRole.student,
      );

      if (user != null) {
        debugPrint('✅ New user created successfully: ${user.username}');
        await AuthService().loginUser(
          username: user.username,
          password: user.password,
        );
      }

      return user;
    } catch (e) {
      debugPrint('❌ Error signing in with LinkedIn: $e');
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