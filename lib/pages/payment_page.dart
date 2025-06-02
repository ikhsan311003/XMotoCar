import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;

  const PaymentPage({
    super.key,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController paymentController = TextEditingController();
  String selectedMethod = 'transfer';
  bool isValidAmount = false;

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void _validateAmount(String value) {
    final entered = int.tryParse(value);
    setState(() {
      isValidAmount = entered != null && entered == widget.totalPrice;
    });
  }

  Future<void> _submitTransaction() async {
    final token = await AuthService.getToken();
    final rentalResponse = await http.post(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/rentals'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "vehicle_id": widget.vehicle['id'],
        "start_date": widget.startDate.toIso8601String().substring(0, 10),
        "end_date": widget.endDate.toIso8601String().substring(0, 10),
        "total_price": widget.totalPrice,
      }),
    );

    if (rentalResponse.statusCode == 201) {
      final rentalData = jsonDecode(rentalResponse.body)['rental'];
      final rentalId = rentalData['id'];

      final paymentResponse = await http.post(
        Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/payments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "rental_id": rentalId,
          "payment_method": selectedMethod,
          "amount": widget.totalPrice,
        }),
      );

      if (paymentResponse.statusCode == 201) {
        Navigator.pushNamedAndRemoveUntil(context, '/riwayat', (route) => false);
      } else {
        _showError("Gagal mencatat pembayaran.");
      }
    } else {
      _showError("Gagal menyimpan penyewaan.");
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Konfirmasi Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text("Apakah Anda yakin ingin melanjutkan pembayaran ini?", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTransaction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 119, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Bayar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Perhatian", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        content: Text(message, style: const TextStyle(color: Colors.black)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 119, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Kembali", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
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
                    Text("Pembayaran", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kendaraan
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                                child: Image.network(widget.vehicle['image_url'], width: 120, height: 100, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${widget.vehicle['brand']} ${widget.vehicle['model']}",
                                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                      const SizedBox(height: 4),
                                      Text("${_formatRupiah(int.tryParse(widget.vehicle['price_per_day'].toString()) ?? 0)} / hari",
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Informasi Sewa
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tanggal Pinjam: ${DateFormat('dd MMM yyyy').format(widget.startDate)}",
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
                                Text("Tanggal Kembali: ${DateFormat('dd MMM yyyy').format(widget.endDate)}",
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 8),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total Harga:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
                                    Text(_formatRupiah(widget.totalPrice),
                                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 119, 0))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Input pembayaran
                        Text("Masukkan Nominal Pembayaran:",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: paymentController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(color: Colors.black),
                          onChanged: _validateAmount,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            hintText: "Contoh: ${widget.totalPrice}",
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dropdown metode pembayaran
                        Text("Pilih Metode Pembayaran:",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: DropdownButton<String>(
                            value: selectedMethod,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'cash', child: Text('Cash')),
                              DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                              DropdownMenuItem(value: 'ewallet', child: Text('E-Wallet')),
                            ],
                            onChanged: (value) {
                              setState(() => selectedMethod = value!);
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Tombol Bayar
                        Center(
                          child: ElevatedButton(
                            onPressed: isValidAmount ? _showConfirmationDialog : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 255, 119, 0),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: Text("Bayar", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
