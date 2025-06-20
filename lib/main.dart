import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pages
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/message_page.dart';
import 'pages/home_page.dart';
import 'pages/vehicle_detail_page.dart';
import 'pages/product_page.dart';
import 'pages/profile_page.dart';
import 'pages/riwayat_page.dart';
import 'pages/riwayat_pembayaran_page.dart';
import 'pages/search_result_page.dart';
import 'pages/rental_form_page.dart';
import 'pages/payment_page.dart';
import 'pages/saved_vehicles_page.dart';
import 'pages/ulasan_page.dart';
import 'pages/lbs_page.dart';
import 'pages/currency_page.dart';
import 'pages/waktu_page.dart';
import 'pages/akselerometer_page.dart';
import 'pages/giroskop_page.dart';
import 'pages/magnetometer_page.dart';
import 'pages/session_checker_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/admin_vehicle_detail_page.dart';
import 'pages/edit_vehicle_page.dart';
import 'pages/add_vehicle_page.dart';
import 'pages/admin_rental_page.dart';
import 'pages/manage_pembayaran_page.dart';

// Providers
import 'providers/review_provider.dart';

// Services
import 'services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> resetReviewedRentalCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('reviewed_rental_ids');
  print('🧹 reviewed_rental_ids berhasil dihapus dari SharedPreferences');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi notifikasi
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload != null) {
        final data = jsonDecode(payload);
        navigatorKey.currentState?.pushNamed('/riwayat', arguments: data);
      }
    },
  );

  await NotificationService.initialize(); // WAJIB
  resetReviewedRentalCache(); // 🔥 tambahkan sementara untuk reset data lokal

  final reviewProvider = ReviewProvider();
  await reviewProvider.fetchPendingReviews();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => reviewProvider),
      ],
      child: const XMotoApp(),
    ),
  );
}

class XMotoApp extends StatelessWidget {
  const XMotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'XMotoCar',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SessionCheckerPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/feedback': (context) => const MessagePage(),
        '/home': (context) => const HomePage(),
        '/admin-dashboard': (context) => const AdminDashboardPage(),
        '/vehicle-detail': (context) => const VehicleDetailPage(),
        '/produk': (context) => const ProductPage(),
        '/profil': (context) => const ProfilePage(),
        '/riwayat': (context) => const RiwayatSewaPage(),
        '/transaksi': (context) => const RiwayatPembayaranPage(),
        '/rent': (context) => const RentalFormPage(),
        '/saved': (context) => const SavedVehiclesPage(),
        '/message': (context) => const MessagePage(),
        '/berikan-ulasan': (context) => const BerikanUlasanPage(),
        '/lbs': (context) => const LBSPage(),
        '/currency': (context) => const CurrencyPage(),
        '/waktu': (context) => const WaktuPage(),
        '/akselerometer': (context) => const AkselerometerPage(),
        '/giroskop': (context) => const GyroscopePage(),
        '/magnetometer': (context) => const MagnetometerPage(),
        '/admin-vehicle-detail': (context) => const AdminVehicleDetailPage(),
        '/add-vehicle': (context) => const AddVehiclePage(),
        '/manage-sewa': (context) => const ManageSewaPage(),
        '/manage-pembayaran': (context) => const ManagePembayaranPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/search') {
          final vehicles = settings.arguments as List;
          return MaterialPageRoute(
            builder: (context) => SearchResultPage(vehicles: vehicles),
          );
        }

        if (settings.name == '/payment') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PaymentPage(
              vehicle: args['vehicle'],
              startDate: args['startDate'],
              endDate: args['endDate'],
              totalPrice: args['totalPrice'],
            ),
          );
        }

        if (settings.name == '/edit-vehicle') {
          final vehicle = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditVehiclePage(vehicle: vehicle),
          );
        }

        return null;
      },
    );
  }
}
