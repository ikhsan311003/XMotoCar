import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isFormFilled = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_checkFormFilled);
    emailController.addListener(_checkFormFilled);
    passwordController.addListener(_checkFormFilled);
  }

  void _checkFormFilled() {
    final filled = nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
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
            const Text('Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('KEMBALI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void showSuccessDialog(String message) {
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
                color: Colors.green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Sukses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('LOGIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void handleRegister() async {
    if (!isFormFilled) return;

    final email = emailController.text.trim();
    if (!email.contains('@')) {
      showErrorDialog("Format email tidak valid. Harus mengandung '@'\n Contoh: nama@gmail.com");
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.registerUser(
      nameController.text.trim(),
      email,
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result == 'success') {
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      showSuccessDialog("Pendaftaran berhasil! Silakan login untuk masuk ke akunmu.");
    } else {
      showErrorDialog(result ?? 'Gagal mendaftar. Coba lagi.');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Image.asset('assets/xmotocar.png', height: 100, fit: BoxFit.contain),
                  const SizedBox(height: 48),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Nama Lengkap',
                      prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isFormFilled && !isLoading ? handleRegister : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormFilled ? Colors.deepPurple : Colors.grey[300],
                        foregroundColor: isFormFilled ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading
                          ? const SpinKitFadingCircle(color: Colors.deepPurple, size: 30.0)
                          : Text(
                              'DAFTAR',
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
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Sudah punya akun? ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Masuk di sini',
                            style: TextStyle(color: Color.fromARGB(255, 200, 0, 255)),
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
