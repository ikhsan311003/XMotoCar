import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class RentalFormPage extends StatefulWidget {
  const RentalFormPage({super.key});

  @override
  State<RentalFormPage> createState() => _RentalFormPageState();
}

class _RentalFormPageState extends State<RentalFormPage> {
  DateTime? startDate;
  DateTime? endDate;
  Map<String, dynamic>? vehicle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      vehicle = args;
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  int _calculateTotalDays() {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  int _calculateTotalPrice() {
    final rawPrice = vehicle?['price_per_day'].toString() ?? '0';
    final pricePerDay = double.tryParse(rawPrice)?.round() ?? 0;
    return pricePerDay * _calculateTotalDays();
  }

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Widget _buildShopeeStyleDateBox(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          leading: const Icon(Icons.date_range, color: Colors.deepPurple),
          title: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
          subtitle: Text(
            date == null ? 'Pilih tanggal' : DateFormat('dd MMMM yyyy').format(date),
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
          Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Sewa Kendaraan",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: vehicle == null
                    ? const Center(child: Text("Kendaraan tidak ditemukan", style: TextStyle(color: Colors.white)))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        vehicle!['image_url'],
                                        width: 120,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${vehicle!['brand']} ${vehicle!['model']}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${_formatRupiah(double.tryParse(vehicle!['price_per_day'].toString())?.toInt() ?? 0)} / hari",
                                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Shopee-style date pickers
_buildShopeeStyleDateBox("Tanggal Pinjam", startDate, () => _selectDate(true)),
_buildShopeeStyleDateBox("Tanggal Kembali", endDate, () => _selectDate(false)),

// Harga & Total Hari
if (startDate != null && endDate != null)
  Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Hari",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87, // ✅ warna teks
                ),
              ),
              Text(
                "${_calculateTotalDays()} Hari",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87, // ✅ warna teks
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Harga",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // ✅ warna teks
                ),
              ),
              Text(
                _formatRupiah(_calculateTotalPrice()),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 119, 0) // ✅ tetap tema utama
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),


                              const SizedBox(height: 30),
                              Center(
  child: ElevatedButton(
    onPressed: (startDate != null && endDate != null)
        ? () {
            Navigator.pushNamed(
              context,
              '/payment',
              arguments: {
                'vehicle': vehicle,
                'startDate': startDate,
                'endDate': endDate,
                'totalPrice': _calculateTotalPrice(),
              },
            );
          }
        : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 255, 119, 0),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      foregroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey,
    ),
    child: Text(
      "Lanjutkan",
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),


                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
