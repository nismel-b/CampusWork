import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Helper class for security operations
class SecurityHelper {
  /// Hash password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  /// Encrypt sensitive data
  static String encryptData(String data, String key) {
    final keyBytes = utf8.encode(key);
    final key256 = sha256.convert(keyBytes).toString().substring(0, 32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromBase64(base64Encode(utf8.encode(key256)))),
    );
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  /// Decrypt sensitive data
  static String decryptData(String encryptedData, String key) {
    try {
      final keyBytes = utf8.encode(key);
      final key256 = sha256.convert(keyBytes).toString().substring(0, 32);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(encrypt.Key.fromBase64(base64Encode(utf8.encode(key256)))),
      );
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return encryptedData; // Return original if decryption fails
    }
  }

  /// Sanitize user input
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>]'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .trim();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  static bool isStrongPassword(String password) {
    if (password.length < 10) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }
}


