import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'list_screen.dart';

/// Halaman Login Aplikasi Resep Masakan.
///
/// Memenuhi ketentuan soal nomor 1 (Fitur Login - 20 Poin):
/// - "Jika error memunculkan snackbar error berwarna merah"
/// - "Login menggunakan akun dengan username=nama panggilan kalian & password= 3 digit akhir NIM kalian"
/// - "Login tersimpan di sharedPreferences sehingga jika dikeluarkan tanpa logout user masih dapat masuk ke aplikasi kembali"
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Helper untuk menampilkan pesan error menggunakan SnackBar berwarna MERAH.
  /// Memenuhi ketentuan soal: "Jika error memunculkan snackbar error berwarna merah".
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Fungsi saat tombol Login ditekan
  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi input: Cek jika field kosong
    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Username dan password tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    // 2. Validasi login melalui AuthService (kredensial: nama panggilan & 3 digit akhir NIM)
    final success = await AuthService.login(username, password);

    setState(() => _isLoading = false);

    // 3. Tangani hasil validasi
    if (success && mounted) {
      // Navigasi ke Halaman List Resep (ListScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListScreen()),
      );
    } else if (mounted) {
      // Munculkan snackbar merah jika kredensial salah
      _showErrorSnackBar('Login gagal: Username atau password salah');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F4),
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F9D58),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul sambutan sesuai screenshot soal
              const Text(
                'Selamat Datang di Resep Masakan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 36),

              // Field Input Username (rounded border sesuai contoh screenshot)
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Masukkan username',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF0F9D58), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Field Input Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        const BorderSide(color: Color(0xFF0F9D58), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Tombol Login rounded
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F9D58),
                    elevation: 1.5,
                    side: const BorderSide(color: Color(0xFFCFD8DC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 10),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0F9D58),
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF37474F),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
