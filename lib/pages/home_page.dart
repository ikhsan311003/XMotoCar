import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:google_fonts/google_fonts.dart';

import '../components/vehicle_card.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum FeatureMode { all, sensors }

class _HomePageState extends State<HomePage> {
  final List<String> sliderImages = [
    'assets/slide2.png',
    'assets/slide5.png',
    'assets/slide12.png',
  ];

  List allVehicles = [];
  List vehicles = [];
  bool isLoading = true;
  FeatureMode _currentMode = FeatureMode.all;

  @override
void initState() {
  super.initState();
  fetchVehicles();

  Future.delayed(Duration.zero, () {
    if (mounted) {
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      reviewProvider.fetchPendingReviews(); // ← ini yang benar
    }
  });
}

  Future<void> fetchVehicles() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/vehicles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        allVehicles = data;
        vehicles = data.where((v) {
          final rating = double.tryParse(v['averageRating']?.toString() ?? '') ?? 0.0;
          return rating >= 4.0;
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('❌ Gagal mengambil data: ${response.statusCode} - ${response.body}');
    }
  }

  @override
Widget build(BuildContext context) {
  final reviewCount = context.watch<ReviewProvider>().pendingReviewCount;
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
          Column(
            children: [
              buildNavbar(),
              const SizedBox(height: 12),
              Expanded(child: buildContent()),
            ],
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavbar(reviewCount),
    );
  }

  Widget buildNavbar() {
    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 21, right: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/search', arguments: allVehicles);
              },
              child: AbsorbPointer(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Cari kendaraan...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
  icon: const Icon(Icons.bookmark, color: Colors.white),
  tooltip: 'Lihat kendaraan tersimpan',
  onPressed: () => Navigator.pushNamed(context, '/saved'),
),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Ingin LogOut?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  content: const Text("Pastikan semua aktivitas sudah selesai.", style: TextStyle(color: Colors.black)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      onPressed: () {
                        AuthService.logoutUser();
                        Navigator.pop(context, true);
                      },
                      child: const Text("Logout", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vehicles.isEmpty) {
      return const Center(
        child: Text('Tidak ada kendaraan dengan rating tinggi.', style: TextStyle(color: Colors.white)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          cs.CarouselSlider(
            items: sliderImages.map((path) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  path,
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
            options: cs.CarouselOptions(
              height: 125,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              enlargeCenterPage: true,
              viewportFraction: 0.85,
            ),
          ),
          const SizedBox(height: 30),
          buildFeatureSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: vehicles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final v = vehicles[index];
                final rating = double.tryParse(v['averageRating']?.toString() ?? '') ?? 0.0;

                return Stack(
                  children: [
                    VehicleCard(
                      vehicle: v,
                      onTap: () {
                        Navigator.pushNamed(context, '/vehicle-detail', arguments: v);
                      },
                    ),
                    if (rating >= 4.0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 119, 0),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Text(
                            'Terfavorit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildFeatureSection() {
  final allFeatures = [
    {
      'icon': Icons.navigation,
      'label': 'LBS',
      'color': const Color.fromARGB(255, 0, 184, 209),
      'onTap': () => Navigator.pushNamed(context, '/lbs'),
    },
    {
      'icon': Icons.monetization_on,
      'label': 'Mata Uang',
      'color': const Color.fromARGB(255, 255, 191, 0),
      'onTap': () => Navigator.pushNamed(context, '/currency'),
    },
    {
      'icon': Icons.access_time,
      'label': 'Waktu',
      'color': const Color.fromARGB(255, 17, 136, 234),
      'onTap': () => Navigator.pushNamed(context, '/waktu'),
    },
    {
      'icon': Icons.speed,
      'label': 'Akselero\nmeter',
      'color': const Color.fromARGB(255, 15, 185, 21),
      'onTap': () => Navigator.pushNamed(context, '/akselerometer'),
    },
    {
      'icon': Icons.rotate_right,
      'label': 'Giroskop',
      'color': const Color.fromARGB(255, 230, 28, 95),
      'onTap': () => Navigator.pushNamed(context, '/giroskop'),
    },
    {
      'icon': Icons.explore,
      'label': 'Magneto\nmeter',
      'color': Colors.teal,
      'onTap': () => Navigator.pushNamed(context, '/magnetometer'),
    },
  ];

    final sensorIcons = ['Akselero\nmeter', 'Giroskop', 'Magneto\nmeter'];

    final filteredFeatures = _currentMode == FeatureMode.all
        ? allFeatures
        : allFeatures.where((f) => sensorIcons.contains(f['label'])).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(248, 255, 255, 255),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color.fromARGB(31, 0, 0, 0), blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '  Lainnya',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 64, 64, 64),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildFilterChip('Semua', FeatureMode.all),
                  const SizedBox(width: 8),
                  _buildFilterChip('Sensor', FeatureMode.sensors),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filteredFeatures
                  .map((f) => _buildFeatureButton(
  f['icon'] as IconData,
  f['label'] as String,
  f['color'] as Color,
  f['onTap'] as VoidCallback, // ← Tambahkan ini!
))

                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, FeatureMode mode) {
    final isSelected = _currentMode == mode;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.grey[800],
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _currentMode = mode),
      backgroundColor: Colors.white,
      selectedColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? Colors.deepPurple : Colors.grey,
          width: 0.8,
        ),
      ),
    );
  }

  Widget _buildFeatureButton(IconData icon, String label, Color bgColor, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap, // ← Ini penting
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(color: const Color.fromARGB(255, 193, 193, 193), width: 0.5),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget buildBottomNavbar(int reviewCount) {

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
          _buildNavItem(icon: Icons.home, label: 'Beranda', isActive: true, onTap: () {}),
          _buildNavItem(icon: Icons.inventory_2, label: 'Produk', isActive: false, onTap: () => Navigator.pushNamed(context, '/produk')),
          _buildNavItem(icon: Icons.receipt_long, label: 'Riwayat', isActive: false, onTap: () => Navigator.pushNamed(context, '/riwayat'), badgeCount: reviewCount),
          _buildNavItem(icon: Icons.payment, label: 'Transaksi', isActive: false, onTap: () => Navigator.pushNamed(context, '/transaksi')),
          _buildNavItem(icon: Icons.person, label: 'Profil', isActive: false, onTap: () => Navigator.pushNamed(context, '/profil')),
        ],
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
            Icon(icon, color: isActive ? Colors.deepPurple : const Color.fromARGB(255, 149, 149, 149)),
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
            color: isActive ? Colors.deepPurple : const Color.fromARGB(255, 149, 149, 149),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

}
