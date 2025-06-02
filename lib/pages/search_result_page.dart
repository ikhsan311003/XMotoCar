import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../components/vehicle_card.dart';
import '../services/auth_service.dart';

class SearchResultPage extends StatefulWidget {
  final List vehicles;

  const SearchResultPage({super.key, required this.vehicles});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  List allVehicles = [];
  List filteredVehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    fetchAllVehicles();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      fetchAllVehicles();
    }
  }

  Future<void> fetchAllVehicles() async {
    setState(() {
      isLoading = true;
    });

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
        filteredVehicles = [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('❌ Gagal mengambil data kendaraan: ${response.statusCode}');
    }
  }

  void _filterSearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredVehicles = allVehicles.where((v) {
        final name = (v['name'] ?? '').toString().toLowerCase();
        final brand = (v['brand'] ?? '').toString().toLowerCase();
        final model = (v['model'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery) || brand.contains(lowerQuery) || model.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
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
              image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 45),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
  height: 40,
  width: MediaQuery.of(context).size.width * 0.74, // <= atur lebar lebih kecil
  margin: const EdgeInsets.only(left: 10),
  child: TextField(
    controller: _searchController,
    focusNode: _focusNode,
    onChanged: _filterSearch,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: 'Cari kendaraan...',
      prefixIcon: const Icon(Icons.search, color: Colors.grey),
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    style: const TextStyle(color: Colors.black),
  ),
),

                  ],
                ),
              ),
              const SizedBox(height: 0),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredVehicles.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada kendaraan ditemukan.',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: GridView.builder(
                              itemCount: filteredVehicles.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.65,
                              ),
                              itemBuilder: (context, index) {
                                final vehicle = filteredVehicles[index];
                                return VehicleCard(
                                  vehicle: vehicle,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/vehicle-detail',
                                    arguments: vehicle,
                                  ),
                                );
                              },
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
