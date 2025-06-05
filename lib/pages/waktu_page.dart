import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class WaktuPage extends StatefulWidget {
  const WaktuPage({super.key});

  @override
  State<WaktuPage> createState() => _WaktuPageState();
}

class _WaktuPageState extends State<WaktuPage> {
  late Timer _timer;
  DateTime _localTime = DateTime.now();
  final List<WorldClock> _worldClocks = [];
  List<String> _availableTimezones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _localTime = DateTime.now());
    });
    fetchTimezones();
  }

  Future<void> fetchTimezones() async {
  setState(() => _isLoading = true);
  try {
    final response = await http.get(Uri.parse('https://timeapi.io/api/TimeZone/AvailableTimeZones'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        _availableTimezones = List<String>.from(data);
      });
    } else {
      throw Exception('Status bukan 200');
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat zona waktu. Menggunakan default.')),
    );
    setState(() {
      _availableTimezones = ['Asia/Jakarta', 'Europe/London', 'America/New_York'];
    });
  } finally {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}


  Future<void> _addWorldClock(String timezone) async {
  try {
    final response = await http.get(Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=$timezone'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final datetime = DateTime.parse(data['dateTime']);
      final offset = datetime.difference(DateTime.now().toUtc());

      if (!mounted) return; // ✅ penting
      setState(() {
        _worldClocks.add(WorldClock(city: timezone, offset: offset, initialTime: datetime.toUtc()));
      });
    }
  } catch (e) {
    if (!mounted) return; // ✅ penting
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menambahkan zona waktu $timezone')),
    );
  }
}


  void _showAddClockDialog() {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sedang memuat zona waktu...')),
      );
      return;
    }

    if (_availableTimezones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada zona waktu yang tersedia')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Zona Waktu'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _availableTimezones.length,
            itemBuilder: (context, index) {
              final tz = _availableTimezones[index];
              return ListTile(
                title: Text(tz),
                onTap: () {
                  Navigator.pop(context);
                  _addWorldClock(tz);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) => DateFormat.Hms().format(time);

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = _localTime;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Jam Dunia', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: _isLoading ? null : _showAddClockDialog,
  backgroundColor: Colors.deepPurple,
  child: _isLoading
      ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
      : const Icon(Icons.add),
),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatTime(now),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Saat ini: ${DateFormat.yMMMMd().format(now)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const Divider(height: 32, color: Colors.white24),
            Expanded(
              child: _worldClocks.isEmpty
                  ? const Center(child: Text('Belum ada zona waktu ditambahkan', style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: _worldClocks.length,
                      itemBuilder: (context, index) {
                        final wc = _worldClocks[index];
                        final worldTime = DateTime.now().toUtc().add(wc.offset);
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              '${DateFormat.Hm().format(worldTime)} ${wc.city}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${DateFormat.yMMMd().format(worldTime)}  |  ${wc.offset.inHours >= 0 ? '+' : ''}${wc.offset.inHours} jam',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _worldClocks.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class WorldClock {
  final String city;
  final Duration offset;
  final DateTime initialTime;

  WorldClock({required this.city, required this.offset, required this.initialTime});
}
