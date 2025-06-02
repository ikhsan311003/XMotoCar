import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MagnetometerPage extends StatefulWidget {
  const MagnetometerPage({super.key});

  @override
  State<MagnetometerPage> createState() => _MagnetometerPageState();
}

class _MagnetometerPageState extends State<MagnetometerPage> {
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<Position>? _locationSubscription;

  MagnetometerEvent? _magnetometerEvent;
  AccelerometerEvent? _accelerometerEvent;
  String? _latitude;
  String? _longitude;

  @override
  void initState() {
    super.initState();
    _magnetometerSubscription = magnetometerEvents.listen((event) {
      setState(() {
        _magnetometerEvent = event;
      });
    });

    _accelerometerSubscription = accelerometerEvents.listen((event) {
      setState(() {
        _accelerometerEvent = event;
      });
    });

    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      _locationSubscription = Geolocator.getPositionStream().listen((Position position) {
        setState(() {
          _latitude = _formatDMS(position.latitude, isLat: true);
          _longitude = _formatDMS(position.longitude, isLat: false);
        });
      });
    }
  }

  String _formatDMS(double value, {required bool isLat}) {
    final direction = isLat ? (value >= 0 ? 'LU' : 'LS') : (value >= 0 ? 'BT' : 'BB');
    value = value.abs();
    final degrees = value.floor();
    final minutes = ((value - degrees) * 60).floor();
    final seconds = ((((value - degrees) * 60) - minutes) * 60).round();
    return '$degrees°$minutes\'$seconds\" $direction';
  }

  double? getHeading() {
    final mag = _magnetometerEvent;
    final acc = _accelerometerEvent;
    if (mag == null || acc == null) return null;

    final ax = acc.x, ay = acc.y, az = acc.z;
    final normAcc = sqrt(ax * ax + ay * ay + az * az);
    final nx = ax / normAcc, ny = ay / normAcc, nz = az / normAcc;

    final mx = mag.x, my = mag.y, mz = mag.z;

    final hx = my * nz - mz * ny;
    final hy = mz * nx - mx * nz;
    final heading = atan2(hy, hx) * (180 / pi);

    return (heading + 360) % 360;
  }

  @override
  void dispose() {
    _magnetometerSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heading = getHeading();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Kompas Digital', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (heading != null)
              Transform.rotate(
                angle: -heading * (pi / 180),
                child: Icon(Icons.navigation, size: 120, color: Colors.deepPurpleAccent),
              )
            else
              const CircularProgressIndicator(),

            const SizedBox(height: 20),
            Text(
              heading != null ? 'BD${heading.toStringAsFixed(0)}°' : 'Menghitung arah...',
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('LS', style: TextStyle(color: Colors.white54)),
                    Text(_latitude ?? '--', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                Column(
                  children: [
                    const Text('BT', style: TextStyle(color: Colors.white54)),
                    Text(_longitude ?? '--', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
