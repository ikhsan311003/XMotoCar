import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xmotocar/main.dart';
import 'package:xmotocar/services/rental_service.dart';

class NotificationService {
  static Timer? _timer;

  static Future<void> initialize() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'rental_channel_id',
      'Rental Channel',
      description: 'Notifikasi status rental completed',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('✅ Notification channel initialized');
  }

  static void startPeriodicCheck() {
  print('🔁 Memulai periodic check...');
  _timer?.cancel();

  _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
    print('⏱ Timer berjalan...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewed = prefs.getStringList('reviewed_rental_ids') ?? [];
      final notified = prefs.getStringList('notified_rental_ids') ?? [];

      final rentals = await RentalService.fetchRentalHistory();
      print('📦 Jumlah rental ditemukan: ${rentals.length}');

      final completedUnreviewed = rentals.where((r) =>
          r['status'] == 'completed' &&
          r['vehicle'] != null &&
          !reviewed.contains(r['id'].toString()) &&
          !notified.contains(r['id'].toString()));

      print('🟢 Rental siap diberi notifikasi: ${completedUnreviewed.length}');

      if (completedUnreviewed.isNotEmpty) {
        final rental = completedUnreviewed.first;

        final payload = jsonEncode({
          'rental_id': rental['id'],
          'vehicle_id': rental['vehicle']['id'],
        });

        await flutterLocalNotificationsPlugin.show(
          0,
          'Terima kasih telah merental kendaraan!',
          'Jangan lupa untuk memberikan ulasan Anda di XMotoCar.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'rental_channel_id',
              'Rental Channel',
              channelDescription: 'Notifikasi status rental completed',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: payload,
        );

        print('🔔 Notifikasi ditampilkan untuk rental ID: ${rental['id']}');

        // ✅ Tambahkan ID ke daftar notified agar tidak terulang
        notified.add(rental['id'].toString());
        await prefs.setStringList('notified_rental_ids', notified);
      } else {
        print('✅ Tidak ada rental baru yang butuh notifikasi');
      }
    } catch (e) {
      print('❌ Error saat cek notifikasi: $e');
    }
  });
}

}
