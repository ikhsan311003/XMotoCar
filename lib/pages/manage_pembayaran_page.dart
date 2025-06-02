import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ManagePembayaranPage extends StatefulWidget {
  const ManagePembayaranPage({super.key});

  @override
  State<ManagePembayaranPage> createState() => _ManagePembayaranPageState();
}

class _ManagePembayaranPageState extends State<ManagePembayaranPage> {
  List payments = [];
  String selectedStatus = 'Semua';
  String query = '';
  final currentPage = 'pembayaran';

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/payments/admin'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        payments = jsonDecode(response.body);
      });
    }
  }

  Future<void> updatePaymentStatus(String id, String newStatus) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/payments/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode == 200) fetchPayments();
  }

  String formatRupiah(dynamic number) {
    final format = NumberFormat.decimalPattern('id');
    final parsed = num.tryParse(number.toString()) ?? 0;
    return format.format(parsed);
  }

  List get filteredPayments {
    return payments.where((p) {
      final rental = p['rental'];
      final user = rental?['user'];
      final statusMatch = selectedStatus == 'Semua' || p['status'].toString().toLowerCase() == selectedStatus.toLowerCase();
      final queryMatch = user?['name']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false;
      return statusMatch && queryMatch;
    }).toList();
  }

  void showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        content: Text(content, style: GoogleFonts.poppins(color: Colors.black)),
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

  Future<void> printPaymentDetail(Map<String, dynamic> payment) async {
    final pdf = pw.Document();
    final rental = payment['rental'];
    final user = rental['user'];
    final vehicle = rental['vehicle'];

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Detail Pembayaran',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Nama User: ${user['name']}'),
              pw.Text('Email: ${user['email']}'),
              pw.Text('Kendaraan: ${vehicle['brand']} ${vehicle['model']}'),
              pw.Text('Nomor Plat: ${vehicle['plate_number']}'),
              pw.Text('Tanggal Sewa: ${rental['start_date']} → ${rental['end_date']}'),
              pw.Text('Metode Pembayaran: ${payment['payment_method']}'),
              pw.Text('Jumlah: Rp${formatRupiah(payment['amount'])}'),
              pw.Text('Status: ${payment['status'].toString().toUpperCase()}'),
              pw.SizedBox(height: 20),
              pw.Text('Dicetak pada: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}'),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
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
                    title: Text('Manajemen Pembayaran', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Paid', 'Pending', 'Failed'].map((status) {
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
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final p = filteredPayments[index];
                        final rental = p['rental'];
                        final user = rental?['user'];
                        final vehicle = rental?['vehicle'];
                        final status = p['status'].toString().toLowerCase();

                        if (user == null || vehicle == null) return const SizedBox();

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
                              Text('${vehicle['brand']} ${vehicle['model']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
                              const SizedBox(height: 6),
                              Text('Nama User: ${user['name']}', style: GoogleFonts.poppins(color: Colors.black)),
                              Text('Metode: ${p['payment_method']}', style: GoogleFonts.poppins(color: Colors.black)),
                              Text('Jumlah: Rp${formatRupiah(p['amount'])}', style: GoogleFonts.poppins(color: Colors.black)),
                              Text('Status: ${p['status'].toString().toUpperCase()}', style: GoogleFonts.poppins(color: Colors.black)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (status == 'pending') ...[
                                    ElevatedButton.icon(
                                      onPressed: () => showConfirmDialog(
                                        'Konfirmasi Pembayaran',
                                        'Set status menjadi PAID?',
                                        () => updatePaymentStatus(p['id'].toString(), 'paid'),
                                      ),
                                      icon: const Icon(Icons.check, color: Colors.white),
                                      label: Text('Paid', style: GoogleFonts.poppins(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => showConfirmDialog(
                                        'Gagal Bayar',
                                        'Set status menjadi FAILED?',
                                        () => updatePaymentStatus(p['id'].toString(), 'failed'),
                                      ),
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      label: Text('Failed', style: GoogleFonts.poppins(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    ),
                                  ] else if (status != 'failed') ...[
                                    ElevatedButton.icon(
                                      onPressed: () => printPaymentDetail(p),
                                      icon: const Icon(Icons.print, color: Colors.white),
                                      label: Text('Cetak', style: GoogleFonts.poppins(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                    ),
                                  ],
                                ],
                              )
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
      bottomNavigationBar: _buildBottomNavbar(context),
    );
  }

  Widget _buildBottomNavbar(BuildContext context) {
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
          _buildNavItem(Icons.home, 'Beranda', currentPage == 'beranda', () {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          }),
          _buildNavItem(Icons.receipt_long, 'Sewa', currentPage == 'sewa', () {
            Navigator.pushReplacementNamed(context, '/manage-sewa');
          }),
          _buildNavItem(Icons.payment, 'Pembayaran', currentPage == 'pembayaran', () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
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
