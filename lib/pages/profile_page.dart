import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/favorite_service.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PageController _pageController = PageController();
  final List<String> _messages = [
    'Ajak teman pakai XMotoCar biar makin seru!',
    'Gabung ke program loyalti XMotoCar sekarang!',
    'Nikmati diskon sewa kendaraan tiap minggu!',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  String? name;
  String? role;
  String? userId;
  File? _profileImage;

  late Future<int> _totalFavoritesFuture;
  late Future<int> _totalTransactionsFuture;

  List allVehicles = [];
  List favoriteVehicles = [];

  final List<Map<String, String>> promoList = [
    {
      'title': 'Diskon 20%',
      'desc': 'Sewa pertama kamu hemat 20%!',
      'image': 'assets/promo1.png',
    },
    {
      'title': 'Cashback 50rb',
      'desc': 'Transaksi di atas Rp500rb',
      'image': 'assets/promo2.png',
    },
    {
      'title': 'Bebas Biaya Antar',
      'desc': 'Berlaku untuk wilayah kota',
      'image': 'assets/promo3.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startAutoScroll();
    _totalFavoritesFuture = FavoriteService.getTotalFavorites();
    _totalTransactionsFuture = TransactionService.getTotalTransactions();
    fetchAllVehiclesAndFavorites();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      name = user?['name'];
      role = user?['role'];
      userId = user?['id'].toString();
    });
    await _loadProfileImage();
  }

  Future<void> _pickImage() async {
  final picker = ImagePicker();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.pop(context); // Tutup dialog
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null && userId != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('profile_image_path_$userId', pickedFile.path);
                  setState(() {
                    _profileImage = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context); // Tutup dialog
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null && userId != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('profile_image_path_$userId', pickedFile.path);
                  setState(() {
                    _profileImage = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      );
    },
  );
}


  Future<void> _loadProfileImage() async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path_$userId');
    if (path != null) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> fetchAllVehiclesAndFavorites() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/vehicles'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final favIds = await FavoriteService.getFavoriteIds();
        setState(() {
          allVehicles = data;
          favoriteVehicles = allVehicles.where((v) => favIds.contains(v['id'])).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetch favorites: $e');
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _messages.length;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider?>(context, listen: true);
  final reviewCount = reviewProvider?.pendingReviewCount ?? 0;
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
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage('assets/download.jpg') as ImageProvider,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt, color: Colors.white70)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name ?? 'Memuat...',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (role != null)
                      Text('Role: $role', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 30,
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Text(
                              _messages[index],
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatisticsSection(),
                    const SizedBox(height: 24),
                    _buildPromoSection(),
                    const SizedBox(height: 24),
                    _buildFavoriteSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Profil Saya',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/message'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(reviewCount),

    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 130, 5, 159),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.favorite, color: Colors.amber),
                  SizedBox(width: 4),
                  Text("Total Favorite", style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 4),
              FutureBuilder<int>(
                future: _totalFavoritesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white, strokeWidth: 2);
                  }
                  return Text(
                    '${snapshot.data ?? 0}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
          Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.cyanAccent),
                  SizedBox(width: 4),
                  Text("Transaksi", style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 4),
              FutureBuilder<int>(
                future: _totalTransactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white, strokeWidth: 2);
                  }
                  return Text(
                    '${snapshot.data ?? 0}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Promo untukmu:',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: promoList.length,
            itemBuilder: (context, index) {
              final promo = promoList[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (promo['image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          promo['image']!,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      promo['title'] ?? '',
                      style: GoogleFonts.poppins(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      promo['desc'] ?? '',
                      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Kendaraan Favorit:',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: favoriteVehicles.isEmpty
              ? Center(
                  child: Text('Belum ada kendaraan favorit 😅', style: GoogleFonts.poppins(color: Colors.white)),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: favoriteVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = favoriteVehicles[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                vehicle['image_url'] ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                          Text(
                            vehicle['type'] ?? '',
                            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(int reviewCount) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Icons.home, 'Beranda', false, () => Navigator.pushNamed(context, '/home')),
        _buildNavItem(Icons.inventory_2, 'Produk', false, () => Navigator.pushNamed(context, '/produk')),
        _buildNavItem(
          Icons.receipt_long,
          'Riwayat',
          false,
          () => Navigator.pushNamed(context, '/riwayat'),
          badgeCount: reviewCount,
        ),
        _buildNavItem(Icons.payment, 'Transaksi', false, () => Navigator.pushNamed(context, '/transaksi')),
        _buildNavItem(Icons.person, 'Profil', true, () {}),
      ],
    ),
  );
}

  Widget _buildNavItem(
  IconData icon,
  String label,
  bool isActive,
  VoidCallback onTap, {
  int badgeCount = 0,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Icon(icon, color: isActive ? Colors.deepPurple : Colors.grey),
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
            color: isActive ? Colors.deepPurple : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

}
