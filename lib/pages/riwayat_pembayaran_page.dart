import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/payment_service.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';


class RiwayatPembayaranPage extends StatefulWidget {
  const RiwayatPembayaranPage({super.key});

  @override
  State<RiwayatPembayaranPage> createState() => _RiwayatPembayaranPageState();
}

class _RiwayatPembayaranPageState extends State<RiwayatPembayaranPage> {
  String selectedStatus = 'all';
  List payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    setState(() => isLoading = true);
    final data = await PaymentService.getMyPayments();
    setState(() {
      payments = data;
      isLoading = false;
    });
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
    final reviewCount = context.watch<ReviewProvider>().pendingReviewCount;
    final filtered = selectedStatus == 'all'
        ? payments
        : payments.where((p) => p['status'] == selectedStatus).toList();

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
                      'Riwayat Pembayaran',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  children: ['all', 'pending', 'paid', 'failed'].map((status) {
                    final isSelected = selectedStatus == status;
                    return ElevatedButton(
                      onPressed: () => setState(() => selectedStatus = status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.deepPurple
                            : const Color.fromARGB(255, 106, 106, 106),
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
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada pembayaran.',
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final payment = filtered[index];
                              final rental = payment['rental'];
                              final vehicle = rental?['vehicle'];

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
  "${vehicle?['brand']} ${vehicle?['model']}" ?? 'Kendaraan',
  style: GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.black,
  ),
),

                                    const SizedBox(height: 8),
                                    Text(
                                      'Tanggal Sewa: ${rental?['start_date']} → ${rental?['end_date']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Metode: ${payment['payment_method']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Jumlah: Rp${formatRupiah(payment['amount'])}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${payment['status']?.toUpperCase() ?? ''}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: payment['status'] == 'paid'
                                            ? Colors.green
                                            : payment['status'] == 'failed'
                                                ? Colors.red
                                                : Colors.orange,
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
          color: Color.fromARGB(240, 255, 255, 255),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Beranda',
              isActive: false,
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            _buildNavItem(
              icon: Icons.inventory_2,
              label: 'Produk',
              isActive: false,
              onTap: () => Navigator.pushNamed(context, '/produk'),
            ),
            _buildNavItem(
  icon: Icons.receipt_long,
  label: 'Riwayat',
  isActive: false,
  onTap: () => Navigator.pushNamed(context, '/riwayat'),
  badgeCount: reviewCount,
),
            _buildNavItem(
              icon: Icons.payment,
              label: 'Transaksi',
              isActive: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.person,
              label: 'Profil',
              isActive: false,
              onTap: () => Navigator.pushNamed(context, '/profil'),
            ),
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
            Icon(icon, color: isActive ? Colors.deepPurple : const Color.fromARGB(255, 141, 141, 141)),
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
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.deepPurple : const Color.fromARGB(255, 141, 141, 141),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

}
