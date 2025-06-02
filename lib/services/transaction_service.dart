import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class TransactionService {
  static Future<int> getTotalTransactions() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/payments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List payments = jsonDecode(response.body);
      return payments.where((item) => item['status'] == 'paid').length;
    } else {
      throw Exception('Gagal mengambil data pembayaran');
    }
  }
}
