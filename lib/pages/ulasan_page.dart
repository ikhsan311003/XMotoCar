import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/review_service.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';


class BerikanUlasanPage extends StatefulWidget {
  const BerikanUlasanPage({super.key});

  @override
  State<BerikanUlasanPage> createState() => _BerikanUlasanPageState();
}

class _BerikanUlasanPageState extends State<BerikanUlasanPage> {
  final _formKey = GlobalKey<FormState>();
  int rating = 5;
  String comment = '';
  bool isSubmitting = false;

  Future<void> saveReviewedRental(int rentalId) async {
  final prefs = await SharedPreferences.getInstance();
  final reviewed = prefs.getStringList('reviewed_rental_ids') ?? [];
  if (!reviewed.contains(rentalId.toString())) {
    reviewed.add(rentalId.toString());
    await prefs.setStringList('reviewed_rental_ids', reviewed);
  }
}



  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final rentalId = args['rental_id'];
    final vehicleId = args['vehicle_id'];

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Konten
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Beri Rating:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                    DropdownButtonFormField<int>(
                      value: rating,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      items: List.generate(5, (index) => index + 1)
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                          .toList(),
                      onChanged: (val) => setState(() => rating = val ?? 5),
                    ),
                    const SizedBox(height: 16),
                    Text("Komentar:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                    TextFormField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        errorStyle: const TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (val) => val == null || val.isEmpty ? 'Komentar wajib diisi' : null,
                      onChanged: (val) => comment = val,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 119, 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: isSubmitting
    ? null
    : () async {
        if (_formKey.currentState!.validate()) {
          setState(() => isSubmitting = true);
          try {
            await ReviewService.submitReview(
              vehicleId: vehicleId,
              rentalId: rentalId,
              rating: rating,
              comment: comment,
            );
            await saveReviewedRental(rentalId);


            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Berhasil!", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  content: const Text(
                    "Ulasan berhasil dikirim 🎉",
                    style: TextStyle(color: Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                     onPressed: () {
  Navigator.of(context).pop(); // tutup dialog
  Navigator.of(context).pop(); // kembali ke halaman sebelumnya

  // Refresh badge ulasan
  final provider = Provider.of<ReviewProvider>(context, listen: false);
  provider.fetchPendingReviews();
},
                      child: const Text("Kembali"),
                    ),
                  ],
                );
              },
            );
          } catch (e) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: const [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Gagal", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  content: Text(
                    "Gagal mengirim ulasan:\n$e",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Tutup"),
                    ),
                  ],
                );
              },
            );
          } finally {
            setState(() => isSubmitting = false);
          }
        }
      },

                        child: Text("Kirim", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navbar Top
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Berikan Ulasan',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
