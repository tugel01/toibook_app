import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toibook_app/models/user_model.dart';

class AuthService {
  final _baseUrl = 'https://toibook.up.railway.app/api';
  final _storage = const FlutterSecureStorage();

    Future<Map<String, String>> get _headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

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

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  Future<UserProfile> fetchUserProfile() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/profile'),
      headers: await _headers,
    );

    if (res.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to fetch profile: ${res.statusCode}');
    }
  }
}
