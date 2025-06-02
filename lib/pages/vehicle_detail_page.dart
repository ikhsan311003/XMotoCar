import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../services/saved_service.dart';


class VehicleDetailPage extends StatefulWidget {
  const VehicleDetailPage({super.key});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  Map<String, dynamic>? vehicle;
  List reviews = [];
  bool isLoading = true;
  bool isFavorite = false;
  bool isSaved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('id')) {
      fetchVehicleDetail(args['id']);
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchVehicleDetail(int id) async {
    try {
      final token = await AuthService.getToken();

      final vehicleResponse = await http.get(
        Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/vehicles/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final reviewResponse = await http.get(
        Uri.parse('https://backend-projectakhir-122089089856.us-central1.run.app/api/reviews/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (vehicleResponse.statusCode == 200) {
  final decodedVehicle = jsonDecode(vehicleResponse.body);
  final decodedReviews = jsonDecode(reviewResponse.body);
  final fav = await FavoriteService.isFavorite(id);
  final saved = await SavedService.isSaved(id);

  setState(() {
    vehicle = decodedVehicle;
    reviews = decodedReviews;
    isFavorite = fav;
    isSaved = saved;
    isLoading = false;
  });
}
 else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  

  double calculateAverageRating(List reviews) {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(
      0.0,
      (sum, item) => sum + ((item['rating'] ?? 0).toDouble()),
    );
    return total / reviews.length;
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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : vehicle == null
                  ? const Center(
                      child: Text('Data kendaraan tidak ditemukan', style: TextStyle(color: Colors.white)),
                    )
                  : Column(
                      children: [
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
                                "Detail Produk",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(27),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(248, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
  (vehicle!['image_url'] ?? '').isNotEmpty
      ? vehicle!['image_url']
      : 'https://via.placeholder.com/300',
  height: 200,
  fit: BoxFit.cover,
),

                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
  child: Text(
    '${vehicle!['brand']} ${vehicle!['model']}',
    style: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 53, 53, 53),
    ),
    softWrap: true,
    overflow: TextOverflow.visible,
    maxLines: 2,
  ),
),

                                          IconButton(
  icon: Icon(
    isFavorite ? Icons.favorite : Icons.favorite_border,
    color: isFavorite ? Colors.red : Colors.grey,
  ),
  onPressed: () async {
    if (isFavorite) {
      await FavoriteService.removeFavorite(vehicle!['id']);
    } else {
      await FavoriteService.addFavorite(vehicle!['id']);
    }
    final updatedStatus = await FavoriteService.isFavorite(vehicle!['id']);
    setState(() {
      isFavorite = updatedStatus;
    });
  },
),

                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Plat: ${vehicle!['plate_number'] ?? 'N/A'}',
                                          style: GoogleFonts.poppins(color: const Color.fromARGB(255, 53, 53, 53)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Rp${formatRupiah(vehicle!['price_per_day'] ?? 0)} /hari',
                                          style: GoogleFonts.poppins(color: const Color.fromARGB(255, 53, 53, 53)),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        '${vehicle!['status']?.toUpperCase()}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          color: vehicle!['status'] == 'available'
                                              ? const Color.fromARGB(255, 0, 227, 19)
                                              : Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 1),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (reviews.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Penilaian Pengguna (${reviews.length})',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            calculateAverageRating(reviews).toStringAsFixed(1),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.star, color: Colors.amberAccent, size: 20),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ...reviews.map((review) {
                                    final userName = review['user']?['name'] ?? 'Anonim';
                                    final rating = review['rating']?.toString() ?? '0';
                                    final comment = review['comment'] ?? '';
                                    final createdAt = review['created_at']?.toString().split('T').first ?? '';

                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(248, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.account_circle,
                                                  size: 36, color: Color.fromARGB(182, 49, 49, 49)),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(userName,
                                                        style: GoogleFonts.poppins(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                            color: const Color.fromARGB(255, 34, 34, 34))),
                                                    Text("⭐ $rating",
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: const Color.fromARGB(255, 244, 182, 12))),
                                                  ],
                                                ),
                                              ),
                                              Text(createdAt,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 10, color: const Color.fromARGB(255, 34, 34, 34))),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(comment,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12, color: const Color.fromARGB(255, 34, 34, 34))),
                                          const SizedBox(height: 8),
                                          if (review['photos'] != null &&
                                              review['photos'] is List &&
                                              review['photos'].isNotEmpty)
                                            SizedBox(
                                              height: 100,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: review['photos'].length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 8.0),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.network(
                                                        review['photos'][index],
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
        ],
      ),
      bottomNavigationBar: vehicle != null
    ? Row(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              height: 60,
              child: Row(
                children: [
                  // Tombol Bookmark (bukan favorite)
                  Expanded(
  child: IconButton(
    icon: Icon(
      isSaved ? Icons.bookmark : Icons.bookmark_border,
      color: isSaved ? Colors.blueGrey : Colors.grey,
    ),
    // Bagian toggle
onPressed: () async {
  if (isSaved) {
    await SavedService.removeSavedVehicle(vehicle!['id']);
  } else {
    await SavedService.addSavedVehicle(vehicle!);

  }

  final updatedSavedStatus = await SavedService.isSaved(vehicle!['id']);
  setState(() {
    isSaved = updatedSavedStatus;
  });
},



  ),
),

                  // Garis pemisah
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade400,
                  ),
                  // Tombol Add to Cart
                  Expanded(
  child: IconButton(
    icon: const Icon(Icons.add_shopping_cart),
    color: vehicle!['status'] == 'rented' ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 255, 119, 0),
    onPressed: vehicle!['status'] == 'rented'
    ? null
    : () {
        Navigator.pushNamed(
          context,
          '/rent',
          arguments: vehicle,
        );
      },

  ),
),

                ],
              ),
            ),
          ),
          // Kolom harga total
          Expanded(
            flex: 1,
            child: Container(
              color: const Color.fromARGB(255, 255, 119, 0),
              height: 60,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Total per hari",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
                    Text(
                      "Rp${formatRupiah(vehicle!['price_per_day'] ?? 0)}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )
    : null,

    );
  }
}
