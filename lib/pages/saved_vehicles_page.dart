import 'package:flutter/material.dart';
import '../services/saved_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedVehiclesPage extends StatefulWidget {
  const SavedVehiclesPage({super.key});

  @override
  State<SavedVehiclesPage> createState() => _SavedVehiclesPageState();
}

class _SavedVehiclesPageState extends State<SavedVehiclesPage> {
  List<Map<String, dynamic>> savedVehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSavedVehicles();
  }

  Future<void> loadSavedVehicles() async {
    try {
      final data = await SavedService.getAllSavedVehicles();
      setState(() {
        savedVehicles = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        savedVehicles = [];
        isLoading = false;
      });
    }
  }

  String formatRupiah(dynamic value) {
    final number = num.tryParse(value.toString()) ?? 0;
    return number.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
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
              // Top AppBar custom
              Container(
                height: 100,
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Kendaraan Tersimpan",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Konten Utama
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : savedVehicles.isEmpty
                        ? Center(
                            child: Text(
                              "Belum ada kendaraan yang disimpan.",
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: savedVehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = savedVehicles[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/vehicle-detail',
                                    arguments: {'id': vehicle['id']},
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(248, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                        child: Image.network(
                                          vehicle['image_url'] ?? '',
                                          width: 100,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 100,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.car_rental, size: 32),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${vehicle['brand']} ${vehicle['model']}",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: const Color.fromARGB(255, 34, 34, 34),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Rp${formatRupiah(vehicle['price_per_day'])} /hari",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
