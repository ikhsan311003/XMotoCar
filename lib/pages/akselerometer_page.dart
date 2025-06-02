import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AkselerometerPage extends StatefulWidget {
  const AkselerometerPage({super.key});

  @override
  State<AkselerometerPage> createState() => _AkselerometerPageState();
}

class _AkselerometerPageState extends State<AkselerometerPage> {
  AccelerometerEvent? _currentEvent;
  late StreamSubscription<AccelerometerEvent> _accelSubscription;

  double _lastTotalAcc = 0;
  DateTime? _lastDropTime;
  final Duration dropCooldown = const Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _accelSubscription = accelerometerEvents.listen(_handleAccelerometerEvent);
  }

  @override
  void dispose() {
    _accelSubscription.cancel();
    super.dispose();
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();

    // Total percepatan (acceleration)
    double totalAcc = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    double delta = (totalAcc - _lastTotalAcc).abs();

    // Deteksi kemungkinan perangkat jatuh
    if (delta > 30) {
      if (_lastDropTime == null || now.difference(_lastDropTime!) > dropCooldown) {
        _lastDropTime = now;
        showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(
      'Perhatian',
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    content: Text(
      'Kemungkinan perangkat jatuh.',
      style: GoogleFonts.poppins(color: Colors.black87),
    ),
    actions: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text('OK', style: GoogleFonts.poppins(color: Colors.white)),
      ),
    ],
  ),
);

      }
    }

    _lastTotalAcc = totalAcc;

    setState(() {
      _currentEvent = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Sensor Akselerometer',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Sensor:', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 10),
            _buildSensorTile('X', _currentEvent?.x ?? 0),
            _buildSensorTile('Y', _currentEvent?.y ?? 0),
            _buildSensorTile('Z', _currentEvent?.z ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorTile(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16))),
          Expanded(
            child: LinearProgressIndicator(
              value: ((value + 12) / 24).clamp(0.0, 1.0),
              backgroundColor: Colors.white12,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 10),
          Text(value.toStringAsFixed(2), style: GoogleFonts.poppins(color: Colors.white)),
        ],
      ),
    );
  }
}
