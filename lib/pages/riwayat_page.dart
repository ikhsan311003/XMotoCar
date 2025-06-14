import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rental_service.dart';
import 'dart:convert'; // untuk jsonEncode
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // agar bisa akses flutterLocalNotificationsPlugin & navigatorKey


class RiwayatSewaPage extends StatefulWidget {
  const RiwayatSewaPage({super.key});

  @override
  State<RiwayatSewaPage> createState() => _RiwayatSewaPageState();
}

class _RiwayatSewaPageState extends State<RiwayatSewaPage> {
  String selectedStatus = 'all';
  List rentals = [];
  List<int> reviewedRentalIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
  setState(() => isLoading = true);

  final prefs = await SharedPreferences.getInstance();
  final reviewed = prefs.getStringList('reviewed_rental_ids') ?? [];
  final notified = prefs.getStringList('notified_rental_ids') ?? [];

  final newData = await RentalService.fetchRentalHistory();

  setState(() {
    reviewedRentalIds = reviewed.map(int.parse).toList();
    rentals = newData;
    isLoading = false;
  });

  // Cek rental yang status-nya completed, belum diulas, dan belum dikasih notifikasi
  final newCompletedUnreviewed = newData.where((r) =>
      r['status'] == 'completed' &&
      !reviewed.contains(r['id'].toString()) &&
      !notified.contains(r['id'].toString()));

  if (newCompletedUnreviewed.isNotEmpty) {
    final rental = newCompletedUnreviewed.first;
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

    // Tambahkan ke daftar yang sudah dikasih notifikasi
    notified.add(rental['id'].toString());
    await prefs.setStringList('notified_rental_ids', notified);
  }
}




  String formatRupiah(dynamic value) {
    final number = num.tryParse(value.toString()) ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRentals = selectedStatus == 'all'
        ? rentals
        : rentals.where((r) => r['status'] == selectedStatus).toList();

    int pendingReviews = rentals
        .where((r) =>
            r['status'] == 'completed' &&
            !reviewedRentalIds.contains(r['id']))
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Riwayat Sewa',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 12,
                  children: ['all', 'booked', 'completed', 'cancelled'].map((status) {
                    final isSelected = selectedStatus == status;
                    return ElevatedButton(
                      onPressed: () => setState(() => selectedStatus = status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.deepPurple : const Color.fromARGB(255, 106, 106, 106),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredRentals.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada riwayat sewa. 🕵️',
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filteredRentals.length,
                            itemBuilder: (context, index) {
                              final rental = filteredRentals[index];
                              final hasReviewed = reviewedRentalIds.contains(rental['id']);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${rental['vehicle']['brand']} ${rental['vehicle']['model']}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tanggal: ${rental['start_date']}  ->  ${rental['end_date']}',
                                      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13),
                                    ),
                                    Text(
                                      'Total: Rp${formatRupiah(rental['total_price'])}',
                                      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${rental['status']?.toUpperCase() ?? ''}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: rental['status'] == 'completed'
                                            ? Colors.green
                                            : rental['status'] == 'cancelled'
                                                ? Colors.red
                                                : Colors.orange,
                                      ),
                                    ),
                                    if (rental['status'] == 'completed' && hasReviewed)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Sudah Diulas',
                                          style: GoogleFonts.poppins(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    if (rental['status'] == 'completed' && !hasReviewed)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/berikan-ulasan',
                                              arguments: {
                                                'rental_id': rental['id'],
                                                'vehicle_id': rental['vehicle']['id'],
                                              },
                                            ).then((_) => fetchAll());
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                          child: Text('Berikan Ulasan', style: GoogleFonts.poppins(color: Colors.white)),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: 'Beranda', isActive: false, onTap: () => Navigator.pushNamed(context, '/home')),
            _buildNavItem(icon: Icons.inventory_2, label: 'Produk', isActive: false, onTap: () => Navigator.pushNamed(context, '/produk')),
            _buildNavItem(icon: Icons.receipt_long, label: 'Riwayat', isActive: true, onTap: () {}, badgeCount: pendingReviews),
            _buildNavItem(icon: Icons.payment, label: 'Transaksi', isActive: false, onTap: () => Navigator.pushNamed(context, '/transaksi')),
            _buildNavItem(icon: Icons.person, label: 'Profil', isActive: false, onTap: () => Navigator.pushNamed(context, '/profil')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(icon, color: isActive ? Colors.deepPurple : Colors.grey),
              if (badgeCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.deepPurple : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
