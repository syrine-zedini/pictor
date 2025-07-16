import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'usermodel.dart';

class ApiService {
  static const String _baseUrl = 'http://41.230.35.111:3030/api/users';
  static const int timeoutSeconds = 30;

  // Login avec username/password
  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
    'username': username,
    'password': password,
    }),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (response.statusCode == 200) {
    return jsonDecode(response.body);
    } else {
    throw HttpException('Login failed with status: ${response.statusCode}');
    }
    } on SocketException {
    throw const SocketException('No Internet connection');
    } on TimeoutException {
    throw TimeoutException('Request timeout');
    } on FormatException {
    throw const FormatException('Invalid response format');
    } catch (e) {
    throw Exception('Login error: $e');
    }
  }

  // Récupérer les infos utilisateur par ID
  static Future<User> getUserInfo(String userId, String token) async {
    try {
      final response = await http.get(
          Uri.parse('$_baseUrl/$userId'),
          headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    },
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
    } else {
    throw HttpException('Failed to get user info: ${response.statusCode}');
    }
    } on SocketException {
    throw const SocketException('No Internet connection');
    } on TimeoutException {
    throw TimeoutException('Request timeout');
    } on FormatException {
    throw const FormatException('Invalid response format');
    } catch (e) {
    throw Exception('Get user info error: $e');
    }
  }

  // Vérifier mot de passe
  // checkPasswordData should be a Map corresponding to CheckPasswordQuery (JSON)
  static Future<bool> checkPassword(Map<String, dynamic> checkPasswordData) async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/checkpassword'), // [cite: 8]
          headers: {'Content-Type': 'application/json'},
    body: jsonEncode(checkPasswordData),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (response.statusCode == 200) {
    return jsonDecode(response.body); // Assuming it returns a boolean
    } else {
    throw HttpException('Failed to check password: ${response.statusCode}');
    }
    } on SocketException {
    throw const SocketException('No Internet connection');
    } on TimeoutException {
    throw TimeoutException('Request timeout');
    } on FormatException {
    throw const FormatException('Invalid response format');
    } catch (e) {
    throw Exception('Check password error: $e');
    }
  }

  // Email existe ?
  // emailData should be a Map corresponding to Exist Email Query (JSON)
  static Future<bool> checkEmailExists(Map<String, dynamic> emailData) async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/existmail'), // [cite: 8]
          headers: {'Content-Type': 'application/json'},
    body: jsonEncode(emailData),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (response.statusCode == 200) {
    return jsonDecode(response.body); // Assuming it returns a boolean
    } else {
    throw HttpException('Failed to check email existence: ${response.statusCode}');
    }
    } on SocketException {
    throw const SocketException('No Internet connection');
    } on TimeoutException {
    throw TimeoutException('Request timeout');
    } on FormatException {
    throw const FormatException('Invalid response format');
    } catch (e) {
    throw Exception('Check email exists error: $e');
    }
  }

  // Mobile password reset - new endpoint for mobile apps
  // Sends email with code if email exists, returns false if email doesn't exist
  static Future<bool> mobilePasswordReset(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/existmailmobil'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Returns true if email exists and code sent, false otherwise
      } else {
        throw HttpException('Failed to process mobile password reset: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } on FormatException {
      throw const FormatException('Invalid response format');
    } catch (e) {
      throw Exception('Mobile password reset error: $e');
    }
  }

  // Valider token
  // tokenData should be a Map corresponding to Validate TokenQuery (JSON)
  static Future<bool> validateToken(Map<String, dynamic> tokenData) async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/validatetoken'), // [cite: 8]
          headers: {'Content-Type': 'application/json'},
    body: jsonEncode(tokenData),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (response.statusCode == 200) {
    return jsonDecode(response.body); // Assuming it returns a boolean
    } else {
    throw HttpException('Failed to validate token: ${response.statusCode}');
    }
    } on SocketException {
    throw const SocketException('No Internet connection');
    } on TimeoutException {
    throw TimeoutException('Request timeout');
    } on FormatException {
    throw const FormatException('Invalid response format');
    } catch (e) {
    throw Exception('Validate token error: $e');
    }
  }

  // Réinitialiser mot de passe
  // resetPasswordData should be a Map corresponding to RestPasswordCommand (JSON)
  static Future<void> resetPassword(Map<String, dynamic> resetPasswordData) async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/reset-password'), // [cite: 8]
          headers: {'Content-Type': 'application/json'},
    body: jsonEncode(resetPasswordData),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (response.statusCode == 200) {
    // Password reset successful
    } else {
    throw HttpException('Failed to reset password: ${response.statusCode}');
    }
    } on SocketException {
    throw const SocketException('No Internet connection');
    } on TimeoutException {
    throw TimeoutException('Request timeout');
    } on FormatException {
    throw const FormatException('Invalid response format');
    } catch (e) {
    throw Exception('Reset password error: $e');
    }
  }

  // Mettre à jour le profil de l'utilisateur [cite: 9]
  // updatedData should be a Map corresponding to UpdateUserCommand (JSON)
  static Future<User> updateMyProfile(String userId, Map<String, dynamic> updatedData, String token) async {
    try {
      final response = await http.put(
          Uri.parse('$_baseUrl/myprofile/$userId'), // [cite: 9]
          headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    },
    body: jsonEncode(updatedData),
    ).timeout(const Duration(seconds: timeoutSeconds));

    if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
    } else {
    throw HttpException('Failed to update profile: ${response.statusCode}');
    }
    } on SocketException {
    throw const SocketException('No Internet connection');
    } on TimeoutException {
    throw TimeoutException('Request timeout');
    } on FormatException {
    throw const FormatException('Invalid response format');
    } catch (e) {
    throw Exception('Update profile error: $e');
    }
  }
}