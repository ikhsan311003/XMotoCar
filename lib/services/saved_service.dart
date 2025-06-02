import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class SavedService {
  // Mendapatkan key yang unik berdasarkan email user
  static Future<String> _getKey() async {
    final email = await AuthService.getEmail();
    if (email == null || email.isEmpty) {
      throw Exception('Email tidak ditemukan. Pastikan user sudah login.');
    }
    return 'saved_vehicles_${email.toLowerCase()}';
  }

  // Ambil semua kendaraan tersimpan milik user saat ini
  static Future<List<Map<String, dynamic>>> getAllSavedVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();

    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return List<Map<String, dynamic>>.from(jsonList);
  }

  // Tambahkan kendaraan ke daftar tersimpan milik user saat ini
  static Future<void> addSavedVehicle(Map<String, dynamic> vehicle) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();

    final vehicles = await getAllSavedVehicles();
    final exists = vehicles.any((v) => v['id'] == vehicle['id']);

    if (!exists) {
      vehicles.add(vehicle);
      await prefs.setString(key, jsonEncode(vehicles));
    }
  }

  // Hapus kendaraan tertentu dari daftar tersimpan milik user saat ini
  static Future<void> removeSavedVehicle(int vehicleId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();

    final vehicles = await getAllSavedVehicles();
    vehicles.removeWhere((v) => v['id'] == vehicleId);

    await prefs.setString(key, jsonEncode(vehicles));
  }

  // Cek apakah kendaraan sudah disimpan oleh user saat ini
  static Future<bool> isSaved(int vehicleId) async {
    final vehicles = await getAllSavedVehicles();
    return vehicles.any((v) => v['id'] == vehicleId);
  }

  // Hapus semua kendaraan tersimpan untuk user saat ini
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    await prefs.remove(key);
  }
}
