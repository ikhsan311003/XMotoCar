import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

class LBSPage extends StatefulWidget {
  const LBSPage({super.key});

  @override
  State<LBSPage> createState() => _LBSPageState();
}

class _LBSPageState extends State<LBSPage> {
  LatLng? currentPosition;
  LatLng? targetPosition;
  String address = 'Menunggu lokasi...';
  String destinationAddress = 'Tap peta untuk memilih lokasi tujuan';
  String distanceText = 'Belum ada tujuan';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        address = 'Layanan lokasi tidak aktif.';
        isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          address = 'Izin lokasi ditolak.';
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        address = 'Izin lokasi ditolak permanen.';
        isLoading = false;
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final latLng = LatLng(position.latitude, position.longitude);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.name}, ${place.subLocality}, ${place.locality}';
      } else {
        address = 'Alamat tidak ditemukan';
      }
    } catch (e) {
      address = 'Gagal mendapatkan alamat.';
    }

    setState(() {
      currentPosition = latLng;
      isLoading = false;
    });
  }

  void handleTap(LatLng tappedPoint) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(tappedPoint.latitude, tappedPoint.longitude);
      String newAddress = 'Lat: ${tappedPoint.latitude}, Lng: ${tappedPoint.longitude}';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        newAddress = '${place.name}, ${place.subLocality}, ${place.locality}';
      }

      double? km = currentPosition != null
          ? Distance().as(LengthUnit.Kilometer, currentPosition!, tappedPoint)
          : null;

      double estimatedMinutes = (km ?? 0) / 40 * 60;

      setState(() {
        targetPosition = tappedPoint;
        destinationAddress = newAddress;
        distanceText = km != null
            ? '${estimatedMinutes.toStringAsFixed(0)} mnt (${km.toStringAsFixed(1)} km)'
            : 'Tidak dapat menghitung jarak';
      });
    } catch (e) {
      setState(() {
        destinationAddress = 'Gagal mengambil alamat tujuan';
        distanceText = 'Tidak dapat menghitung jarak';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi Saya (LBS)', style: GoogleFonts.poppins(textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 255, 255),
          ),)),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading || currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: currentPosition,
                    zoom: 15.0,
                    onTap: (_, tappedPoint) => handleTap(tappedPoint),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentPosition!,
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.my_location, size: 36, color: Colors.blue),
                        ),
                        if (targetPosition != null)
                          Marker(
                            point: targetPosition!,
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle, color: Colors.blue, size: 12),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: GoogleFonts.poppins(fontSize: 13, color: const Color.fromARGB(255, 0, 0, 0)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 12, thickness: 1),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    destinationAddress,
                                    style: GoogleFonts.poppins(fontSize: 13, color: const Color.fromARGB(255, 0, 0, 0)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car, size: 16, color: Colors.green[700]),
                            const SizedBox(width: 6),
                            Text(
                              distanceText,
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.green[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
