import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class AdminVehicleDetailPage extends StatefulWidget {
  const AdminVehicleDetailPage({super.key});

  @override
  State<AdminVehicleDetailPage> createState() => _AdminVehicleDetailPageState();
}

class _AdminVehicleDetailPageState extends State<AdminVehicleDetailPage> {
  late Map vehicle;

  String formatRupiah(dynamic number) {
    final format = NumberFormat.decimalPattern('id');
    return format.format(num.tryParse(number.toString()) ?? 0);
  }

  Future<List> fetchReviews(String vehicleId) async {
    final response = await http.get(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/reviews/$vehicleId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final token = await AuthService.getToken();

    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak ditemukan. Silakan login ulang.")),
      );
      return;
    }

    final response = await http.delete(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/vehicles/$vehicleId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kendaraan berhasil dihapus")),
      );

      await Future.delayed(const Duration(milliseconds: 700));

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/admin-dashboard',
        (route) => false,
        arguments: {'deleted': true},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus kendaraan: ${response.body}")),
      );
    }
  }

  void showDeleteConfirmation(String vehicleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Ingin Hapus Kendaraan?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0))),
        content: Text("Pastikan data kendaraan ini tidak dibutuhkan lagi.", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 1, 0, 0))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              deleteVehicle(vehicleId);
            },
            child: Text("Hapus", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vehicle = ModalRoute.of(context)?.settings.arguments as Map;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: BackButton(color: Colors.white),
  title: Text(
    'Detail Kendaraan',
    style: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A192D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        vehicle['image_url'] ?? '',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, _) =>
                            const Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${vehicle['brand']?.toString().toUpperCase() ?? ''} ${vehicle['model']?.toString().toUpperCase() ?? ''}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Plat Nomor: ${vehicle['plate_number']}', style: GoogleFonts.poppins(color: Colors.white)),
                    const SizedBox(height: 3),
                    Text('Jenis: ${vehicle['type']}', style: GoogleFonts.poppins(color: Colors.white)),
                    const SizedBox(height: 3),
                    Text('Harga Sewa: Rp ${formatRupiah(vehicle['price_per_day'])}/hari', style: GoogleFonts.poppins(color: Colors.white)),
                    const SizedBox(height: 3),
                    Text(
                      'Status: ${vehicle['status']}',
                      style: GoogleFonts.poppins(
                        color: vehicle['status'].toString().toUpperCase() == 'AVAILABLE'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/edit-vehicle', arguments: vehicle),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 235, 157, 1),
                            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => showDeleteConfirmation(vehicle['id'].toString()),
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text("Hapus"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 236, 41, 27),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Review Kendaraan:',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List>(
                future: fetchReviews(vehicle['id'].toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Belum ada review.', style: GoogleFonts.poppins(color: Colors.white70));
                  }

                  final reviews = snapshot.data!;
                  final avgRating = reviews.fold<double>(0, (sum, item) => sum + (item['rating'] ?? 0)) / reviews.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Penilaian Pengguna (${reviews.length})',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(avgRating.toStringAsFixed(1), style: GoogleFonts.poppins(color: Colors.white)),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...reviews.map((review) {
                        final date = DateTime.tryParse(review['created_at'] ?? '');
                        final formattedDate = date != null
                            ? DateFormat('yyyy-MM-dd').format(date)
                            : '-';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2B40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white12,
                                    child: Icon(Icons.person, size: 18, color: Colors.white70),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review['user']['name'] ?? 'User',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  Text(
                                    review['rating'].toString(),
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                  const Spacer(),
                                  Text(formattedDate, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review['comment'] ?? '', style: GoogleFonts.poppins(color: Colors.white)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
