import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  static const String _baseUrl =
      'https://backend-projectakhir-122089089856.us-central1.run.app/api/users';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// LOGIN USER
  static Future<String?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        await _storage.write(key: 'token', value: token);

        // ✅ Ambil role dari token
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        final role = payload['role'];
        await _storage.write(key: 'role', value: role);

        return 'success';
      } else {
        return data['message'] ?? 'Email atau password salah';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// REGISTER USER
  static Future<String?> registerUser(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return 'success';
      } else {
        return data['message'] ?? 'Gagal daftar (${response.statusCode})';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  /// LOGOUT USER
  static Future<void> logoutUser() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'role');
  }

  /// GET STORED TOKEN
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  /// GET STORED ROLE
  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  /// CEK APAKAH USER SUDAH LOGIN
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  /// AMBIL DATA USER DARI PAYLOAD JWT
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      return payload;
    } catch (e) {
      return null;
    }
  }

  /// AMBIL EMAIL USER DARI PAYLOAD JWT
  static Future<String?> getEmail() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      return payload['email'];
    } catch (e) {
      return null;
    }
  }
}
