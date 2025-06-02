import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RentalService {
  static const String _baseUrl =
      'https://backend-projectakhir-122089089856.us-central1.run.app/api';

  /// Mengambil riwayat rental milik user yang sedang login
  static Future<List<dynamic>> fetchRentalHistory() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/rentals'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat riwayat sewa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data sewa: $e');
    }
  }
}
