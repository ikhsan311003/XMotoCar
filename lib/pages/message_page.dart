import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String pesanKesan = 
    '''
Aplikasi ini dikembangkan sebagai bagian dari tugas akhir mata kuliah Teknologi dan Pemrograman Mobile.

Saya merasa sangat terbantu karena melalui proyek ini saya dapat mempelajari langsung bagaimana membangun aplikasi mobile secara menyeluruh, mulai dari autentikasi, pengelolaan data kendaraan, hingga penggunaan UI modern dan integrasi API.

Terima kasih kepada dosen pengampu atas bimbingan dan ilmu yang diberikan.
    ''';

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background
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
              // ✅ Navbar dengan background
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/navbar_bg13.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Pesan dan Kesan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ TextField read-only
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: TextEditingController(text: pesanKesan),
                  readOnly: true,
                  maxLines: null,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
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
