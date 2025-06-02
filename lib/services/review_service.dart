import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Pastikan file ini memiliki fungsi getToken()

class ReviewService {
  static const String baseUrl = 'https://backend-projectakhir-122089089856.us-central1.run.app';

  static Future<void> submitReview({
    required int vehicleId,
    required int rentalId, // Masih dipakai di frontend, meski tidak dikirim
    required int rating,
    required String comment,
  }) async {
    final token = await AuthService.getToken(); // Ambil token dari SharedPreferences atau sejenisnya
    final url = Uri.parse('$baseUrl/api/reviews');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'vehicle_id': vehicleId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim ulasan: ${response.body}');
    }
  }
}
