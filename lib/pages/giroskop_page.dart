import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroscopePage extends StatefulWidget {
  const GyroscopePage({super.key});

  @override
  State<GyroscopePage> createState() => _GyroscopePageState();
}

class _GyroscopePageState extends State<GyroscopePage> {
  double _rotationZ = 0.0;
  late StreamSubscription<GyroscopeEvent> _gyroSubscription;

  @override
  void initState() {
    super.initState();
    _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _rotationZ += event.z * 0.05;
        _rotationZ = _rotationZ.clamp(-pi, pi);
      });
    });
  }

  @override
  void dispose() {
    _gyroSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Arah Gerak (Giroskop)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: _rotationZ,
              child: Icon(
                Icons.navigation, // Tampilkan seperti kompas/navigasi
                size: 150,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Putar perangkat untuk melihat arah',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
