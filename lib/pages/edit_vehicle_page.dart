import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class EditVehiclePage extends StatefulWidget {
  final Map vehicle;

  const EditVehiclePage({super.key, required this.vehicle});

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController plateController;
  late TextEditingController priceController;
  late TextEditingController imageController;

  String type = 'Mobil';
  String status = 'available'; // ENUM VALUE: 'available' or 'rented'

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;

    brandController = TextEditingController(text: vehicle['brand']);
    modelController = TextEditingController(text: vehicle['model']);
    plateController = TextEditingController(text: vehicle['plate_number']);
    priceController = TextEditingController(text: vehicle['price_per_day'].toString());
    imageController = TextEditingController(text: vehicle['image_url']);

    final rawType = vehicle['type'].toString().toLowerCase();
    type = (rawType == 'mobil' || rawType == 'car') ? 'Mobil' : 'Motor';

    status = vehicle['status'].toString().toLowerCase(); // 'available' or 'rented'
  }

  @override
  void dispose() {
    brandController.dispose();
    modelController.dispose();
    plateController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> updateVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/vehicles/${widget.vehicle['id']}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'brand': brandController.text,
        'model': modelController.text,
        'plate_number': plateController.text,
        'price_per_day': (double.tryParse(priceController.text.replaceAll(',', '')) ?? 0).toInt(),
        'image_url': imageController.text,
        'type': type,
        'status': status, // enum-compatible value
      }),
    );

    if (context.mounted) {
      if (response.statusCode == 200) {
        await Future.delayed(const Duration(milliseconds: 600));
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin-dashboard',
          (route) => false,
          arguments: {'updated': true},
        );

        Future.microtask(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kendaraan berhasil diperbarui', style: GoogleFonts.poppins())),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui kendaraan: ${response.body}', style: GoogleFonts.poppins())),
        );
      }
    }
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const BackButton(color: Colors.white),
                  title: Text(
                    'Edit Kendaraan',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: type,
                          decoration: InputDecoration(
                            labelText: 'Jenis',
                            labelStyle: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          dropdownColor: const Color(0xFF1A192D),
                          style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                          items: ['Mobil', 'Motor']
                              .map((val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(val, style: GoogleFonts.poppins()),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => type = val!),
                        ),
                        const SizedBox(height: 12),
                        ...[
                          ['Merek', brandController],
                          ['Model', modelController],
                          ['Plat Nomor', plateController],
                          ['Harga Sewa (Rp)', priceController],
                          ['URL Gambar', imageController],
                        ].map((field) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: field[1] as TextEditingController,
                              decoration: InputDecoration(
                                labelText: field[0] as String,
                                labelStyle: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                              ),
                              style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                              keyboardType: field[0] == 'Harga Sewa (Rp)' ? TextInputType.number : TextInputType.text,
                              validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                          );
                        }),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            labelStyle: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                          style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                          items: const [
                            DropdownMenuItem(value: 'available', child: Text('Tersedia')),
                            DropdownMenuItem(value: 'rented', child: Text('Sedang Disewa')),
                          ],
                          onChanged: (val) => setState(() => status = val!),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: updateVehicle,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color.fromARGB(255, 108, 0, 123),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
