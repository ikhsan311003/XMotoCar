import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FavoriteService {
  static const String _baseUrl = 'https://backend-projectakhir-122089089856.us-central1.run.app/api';

  static Future<String?> _getUserId() async {
    final user = await AuthService.getCurrentUser(); // { id: 12, name: ..., ... }
    return user?['id']?.toString();
  }

  static Future<List<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();
    final key = 'favorites_$userId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    return List<int>.from(jsonDecode(jsonString));
  }

  static Future<void> addFavorite(int vehicleId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();
    final key = 'favorites_$userId';
    final favorites = await getFavoriteIds();
    if (!favorites.contains(vehicleId)) {
      favorites.add(vehicleId);
      prefs.setString(key, jsonEncode(favorites));
    }
  }

  static Future<void> removeFavorite(int vehicleId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _getUserId();
    final key = 'favorites_$userId';
    final favorites = await getFavoriteIds();
    favorites.remove(vehicleId);
    prefs.setString(key, jsonEncode(favorites));
  }

  static Future<bool> isFavorite(int vehicleId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(vehicleId);
  }

  static Future<int> getTotalFavorites() async {
    final favorites = await getFavoriteIds();
    return favorites.length;
  }

  static Future<List<dynamic>> getFavoriteVehicles() async {
    final token = await AuthService.getToken();
    final favoriteIds = await getFavoriteIds();
    if (favoriteIds.isEmpty) return [];

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/favorites/vehicles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'vehicle_ids': favoriteIds}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat data kendaraan favorit (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan saat mengambil kendaraan favorit: $e');
    }
  }
}
