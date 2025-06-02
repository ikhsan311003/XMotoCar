import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart' as cs;
import '../components/vehicle_card.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final List<String> sliderImages = [
    'assets/slide2.png',
    'assets/slide5.png',
    'assets/slide12.png',
  ];

  List vehicles = [];
  List allVehicles = [];
  bool isLoading = true;
  String userRole = 'User';
  String selectedType = 'Semua';

  @override
  void initState() {
    super.initState();
    fetchVehicles();
    getUserRole();
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  final args = ModalRoute.of(context)?.settings.arguments;
  if (args is Map) {
    // ✅ SnackBar untuk kendaraan dihapus
    if (args['deleted'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kendaraan berhasil dihapus")),
        );
      });
      fetchVehicles(); // refresh
    }

    // ✅ SnackBar untuk kendaraan diupdate
    if (args['updated'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kendaraan berhasil diperbarui")),
        );
      });
      fetchVehicles(); // refresh
    }
  }
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
        filterVehicles();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void filterVehicles() {
    setState(() {
      if (selectedType == 'Semua') {
        vehicles = allVehicles;
      } else {
        vehicles = allVehicles
            .where((v) => v['type'].toString().toLowerCase() == selectedType.toLowerCase())
            .toList();
      }
    });
  }

  Future<void> getUserRole() async {
    final role = await AuthService.getRole();
    setState(() {
      userRole = role?.toString().toLowerCase() ?? 'user';
    });
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
          Column(
            children: [
              buildNavbar(),
              const SizedBox(height: 12),
              Expanded(child: buildContent()),
            ],
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavbar(),
    );
  }

  Widget buildNavbar() {
    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 21, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hello ${userRole[0].toUpperCase()}${userRole.substring(1)}!',
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 30),
                onPressed: () => Navigator.pushNamed(context, '/add-vehicle'),
                tooltip: 'Tambah Kendaraan',
              ),
              const SizedBox(width: 8),
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
        child: Text('Tidak ada kendaraan ditemukan.', style: TextStyle(color: Colors.white)),
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
          const SizedBox(height: 40),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Semua', 'Mobil', 'Motor'].map((type) {
                final isSelected = selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = type;
                        filterVehicles();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepPurple : Colors.grey,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 0),
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
                return VehicleCard(
                  vehicle: v,
                  onTap: () => Navigator.pushNamed(context, '/admin-vehicle-detail', arguments: v),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildBottomNavbar() {
  String currentRoute = ModalRoute.of(context)?.settings.name ?? '/admin-dashboard';

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
          routeName: '/admin-dashboard',
          isActive: currentRoute == '/admin-dashboard',
        ),
        _buildNavItem(
          icon: Icons.receipt_long,
          label: 'Sewa',
          routeName: '/manage-sewa',
          isActive: currentRoute == '/manage-sewa',
        ),
        _buildNavItem(
          icon: Icons.payment,
          label: 'Pembayaran',
          routeName: '/manage-pembayaran',
          isActive: currentRoute == '/manage-pembayaran',
        ),
      ],
    ),
  );
}

Widget _buildNavItem({
  required IconData icon,
  required String label,
  required String routeName,
  required bool isActive,
}) {
  return GestureDetector(
    onTap: () {
      if (!isActive) {
        Navigator.pushReplacementNamed(context, routeName);
      }
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Colors.deepPurple : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.deepPurple : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

}
