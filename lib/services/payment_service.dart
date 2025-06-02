import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PaymentService {
  static const String _baseUrl =
      'https://backend-projectakhir-122089089856.us-central1.run.app/api';

  static Future<List<dynamic>> getMyPayments() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/payments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat riwayat pembayaran: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
