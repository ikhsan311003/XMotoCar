import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isFormFilled = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFormFilled);
    passwordController.addListener(_checkFormFilled);
  }

  void _checkFormFilled() {
    final filled = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    if (filled != isFormFilled) {
      setState(() => isFormFilled = filled);
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'KEMBALI',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> handleLogin() async {
    if (!isFormFilled) return;

    setState(() => isLoading = true);

    final result = await AuthService.loginUser(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result == 'success') {
      final role = await AuthService.getRole();

      // 🚀 Arahkan berdasarkan role
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      showErrorDialog(result ?? 'Akun tidak ditemukan. Coba lagi dengan email yang benar.');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          // ✅ Konten Login
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/xmotocar.png', height: 100, fit: BoxFit.contain),
                  const SizedBox(height: 48),

                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isFormFilled && !isLoading) ? handleLogin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormFilled ? Colors.deepPurple : Colors.grey[300],
                        foregroundColor: isFormFilled ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SpinKitFadingCircle(color: Colors.deepPurple, size: 30.0)
                          : Text(
                              'LOGIN',
                              style: TextStyle(
                                color: isFormFilled ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Buat Akun? ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Klik Disini',
                            style: TextStyle(color: Color.fromARGB(255, 191, 0, 255)),
                          ),
                        ],
                      ),
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
