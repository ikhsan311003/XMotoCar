import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class SessionCheckerPage extends StatefulWidget {
  const SessionCheckerPage({super.key});

  @override
  State<SessionCheckerPage> createState() => _SessionCheckerPageState();
}

class _SessionCheckerPageState extends State<SessionCheckerPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
  final isLoggedIn = await AuthService.isLoggedIn();

  if (isLoggedIn) {
    final role = await AuthService.getRole();

    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      // Start notifikasi jika user (bukan admin)
      NotificationService.startPeriodicCheck(); // 🔔 Mulai cek rental completed tiap 30 detik
      Navigator.pushReplacementNamed(context, '/home');
    }
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Bisa diganti loading custom
      ),
    );
  }
}
