import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  String type = 'Mobil';
  String status = 'AVAILABLE';

  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final plateController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();

  Future<void> submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/vehicles'),
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
        'type': type.toLowerCase(),
        'status': status,
      }),
    );

    if (context.mounted) {
      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kendaraan berhasil ditambahkan", style: GoogleFonts.poppins())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menambah kendaraan: ${response.body}", style: GoogleFonts.poppins())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> inputFields = [
      {'label': 'Merk', 'controller': brandController},
      {'label': 'Model', 'controller': modelController},
      {'label': 'Plat Nomor', 'controller': plateController},
      {'label': 'Harga per hari', 'controller': priceController},
      {'label': 'URL Gambar', 'controller': imageController},
    ];

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
                    'Tambah Kendaraan',
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
                          dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                          style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                          items: ['Mobil', 'Motor'].map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(val, style: GoogleFonts.poppins()),
                          )).toList(),
                          onChanged: (val) => setState(() => type = val!),
                        ),
                        const SizedBox(height: 12),
                        ...inputFields.map((field) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: field['controller'] as TextEditingController,
                              decoration: InputDecoration(
                                labelText: field['label'],
                                labelStyle: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                              ),
                              style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                              keyboardType: field['label'] == 'Harga per hari' ? TextInputType.number : TextInputType.text,
                              validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                          );
                        }).toList(),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            labelStyle: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                          style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                          items: const [
                            DropdownMenuItem(value: 'AVAILABLE', child: Text('Tersedia')),
                            DropdownMenuItem(value: 'RENTED', child: Text('Tidak Tersedia')),
                          ],
                          onChanged: (val) => setState(() => status = val!),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: submitVehicle,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color.fromARGB(255, 108, 0, 123),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
