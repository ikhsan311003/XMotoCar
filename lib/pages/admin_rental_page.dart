import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class ManageSewaPage extends StatefulWidget {
  const ManageSewaPage({super.key});

  @override
  State<ManageSewaPage> createState() => _ManageSewaPageState();
}

class _ManageSewaPageState extends State<ManageSewaPage> {
  List rentals = [];
  String selectedStatus = 'Semua';
  String query = '';
  final String currentPage = 'sewa';

  @override
  void initState() {
    super.initState();
    fetchRentals();
  }

  Future<void> fetchRentals() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/rentals/admin'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        rentals = jsonDecode(response.body);
      });
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/rentals/$id'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode == 200) fetchRentals();
  }

  Future<void> deleteRental(String id) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/rentals/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) fetchRentals();
  }

  String formatRupiah(dynamic number) {
    final format = NumberFormat.decimalPattern('id');
    final parsedNumber = num.tryParse(number.toString()) ?? 0;
    return format.format(parsedNumber);
  }

  List get filteredRentals {
    return rentals.where((r) {
      final statusMatch = selectedStatus == 'Semua' || r['status'].toString().toLowerCase() == selectedStatus.toLowerCase();
      final queryMatch = r['user']['name'].toString().toLowerCase().contains(query.toLowerCase());
      return statusMatch && queryMatch;
    }).toList();
  }

  void showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0))),
        content: Text(content, style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text("Oke", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: Text('Manajemen Penyewaan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onChanged: (val) => setState(() => query = val),
                    style: GoogleFonts.poppins(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: '  Cari nama user...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: const BorderSide(color: Colors.deepOrangeAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Booked', 'Completed', 'Cancelled'].map((status) {
                        final isSelected = selectedStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? Colors.deepPurple : Colors.grey,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () => setState(() => selectedStatus = status),
                            child: Text(status, style: GoogleFonts.poppins(color: Colors.white)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredRentals.length,
                      itemBuilder: (context, index) {
                        final r = filteredRentals[index];
                        final status = r['status'].toString().toLowerCase();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${r['vehicle']['brand']} ${r['vehicle']['model']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
                              const SizedBox(height: 6),
                              Text('Nama: ${r['user']['name']}', style: GoogleFonts.poppins(color: Colors.black)),
                              Text('Tanggal: ${r['start_date']} → ${r['end_date']}', style: GoogleFonts.poppins(color: Colors.black)),
                              Text('Total: Rp${formatRupiah(r['total_price'])}', style: GoogleFonts.poppins(color: Colors.black)),
                              Text('Status: ${r['status']}', style: GoogleFonts.poppins(color: Colors.black)),
                              const SizedBox(height: 8),
                              Row(
  children: [
    if (status == 'booked') ...[
      ElevatedButton.icon(
        onPressed: () => showConfirmDialog(
          "Selesaikan Sewa",
          "Apakah sewa ini sudah selesai?",
          () => updateStatus(r['id'].toString(), 'completed'),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text('Selesai', style: GoogleFonts.poppins(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      ),
      const SizedBox(width: 8),
      ElevatedButton.icon(
        onPressed: () => showConfirmDialog(
          "Batalkan Sewa",
          "Apakah yakin ingin membatalkan sewa?",
          () => updateStatus(r['id'].toString(), 'cancelled'),
        ),
        icon: const Icon(Icons.close, color: Colors.white),
        label: Text('Batal', style: GoogleFonts.poppins(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      ),
    ],
    if (status == 'completed' || status == 'cancelled')
      ElevatedButton.icon(
        onPressed: () => showConfirmDialog(
          "Hapus Sewa",
          "Apakah yakin ingin menghapus riwayat sewa ini?",
          () => deleteRental(r['id'].toString()),
        ),
        icon: const Icon(Icons.delete, color: Colors.white),
        label: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      ),
  ],
),

                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavbar(context),
    );
  }

  Widget buildBottomNavbar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(248, 255, 255, 255),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Color.fromARGB(31, 255, 255, 255), blurRadius: 8, offset: Offset(0, -2))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Beranda',
            isActive: currentPage == 'beranda',
            onTap: () => Navigator.pushReplacementNamed(context, '/admin-dashboard'),
          ),
          _buildNavItem(
            icon: Icons.receipt_long,
            label: 'Sewa',
            isActive: currentPage == 'sewa',
            onTap: () {},
          ),
          _buildNavItem(
            icon: Icons.payment,
            label: 'Pembayaran',
            isActive: currentPage == 'pembayaran',
            onTap: () => Navigator.pushReplacementNamed(context, '/manage-pembayaran'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? Colors.deepPurple : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
