import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/vehicle_card.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';



class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List vehicles = [];
  String filter = 'all';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
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
      final data = jsonDecode(response.body);
      setState(() {
        vehicles = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewCount = context.watch<ReviewProvider>().pendingReviewCount;
    final filteredVehicles = vehicles.where((v) {
      if (filter == 'all') return true;
      return (v['type']?.toString().toLowerCase() ?? '') == filter;
    }).toList();

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
              Container(
  height: 100,
  width: double.infinity,
  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
  child: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      const SizedBox(width: 8),
      Text(
        'Produk',
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['all', 'mobil', 'motor'].map((type) {
                    final isActive = filter == type;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ElevatedButton(
                        onPressed: () => setState(() => filter = type),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.deepPurple : const Color.fromARGB(255, 106, 106, 106),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          type == 'all'
                              ? 'Semua'
                              : type[0].toUpperCase() + type.substring(1),
                              style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredVehicles.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada kendaraan tersedia.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: filteredVehicles.length,
                            itemBuilder: (context, index) {
                              final v = filteredVehicles[index];
                              return VehicleCard(
                                vehicle: v,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/vehicle-detail',
                                    arguments: v,
                                  );
                                },
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
        onTap: () {
          Navigator.pushNamed(context, '/home');
        },
      ),
      _buildNavItem(
        icon: Icons.inventory_2,
        label: 'Produk',
        isActive: true,
        onTap: () {},
      ),
      _buildNavItem(
  icon: Icons.receipt_long,
  label: 'Riwayat',
  isActive: false,
  onTap: () {
    Navigator.pushNamed(context, '/riwayat');
  },
  badgeCount: reviewCount,
),

      _buildNavItem(
        icon: Icons.payment,
        label: 'Transaksi',
        isActive: false,
        onTap: () {
          Navigator.pushNamed(context, '/transaksi');
        },
      ),
      _buildNavItem(
        icon: Icons.person,
        label: 'Profil',
        isActive: false,
        onTap: () {
          Navigator.pushNamed(context, '/profil');
        },
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