import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toibook_app/models/user_model.dart';

class AuthService {
  final _baseUrl = 'https://toibook.up.railway.app/api';
  final _storage = const FlutterSecureStorage();

  // Mock data for now, add actual user fetching logic later
  static UserModel currentUser = UserModel(
    id: 'u-001',
    fullName: 'Alisher Kanatov',
    email: 'alisher@toibook.kz',
    phoneNumber: '+7 707 123 45 67',
    city: 'Astana',
  );

  Future<bool> register(
    String name,
    String surname,
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'surname': surname,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Network error. Check your connection.');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final token = jsonDecode(res.body)['token'] as String;
        await _storage.write(key: 'jwt', value: token);
        return true;
      }
      return false; // wrong credentials
    } catch (e) {
      throw Exception('Network error. Check your connection.');
    }
  }

  Future<String?> getToken() => _storage.read(key: 'jwt');

  Future<void> logout() => _storage.delete(key: 'jwt');

  // also may delete
  Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(payload);
    } catch (e) {
      return null;
    }
  }

  // here we can only get email. May delete later
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) return null;
    return decodeToken(token);
  }

  // may delete as well
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt');
    return token != null;
  }
}
