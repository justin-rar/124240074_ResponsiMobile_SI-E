import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/list_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/favorite_service.dart';

/// Entry point utama aplikasi Resep Masakan.
/// Diberi keyword `async` untuk:
/// 1. Menginisialisasi database lokal Hive untuk fitur Favorite.
/// 2. Membaca status login di SharedPreferences (auto-login jika belum logout).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive (Local Database) untuk fitur Favorite
  await Hive.initFlutter();
  await Hive.openBox(FavoriteService.boxName);

  // 2. Cek status sesi login (Ketentuan soal: Login tersimpan di sharedPreferences)
  final isLoggedIn = await AuthService.isLoggedIn();

  // 3. Menjalankan aplikasi
  runApp(MyApp(
    initialScreen: isLoggedIn ? const ListScreen() : const LoginScreen(),
  ));
}

/// Root widget aplikasi
class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resep Masakan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D58),
          primary: const Color(0xFF0F9D58),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F7F4),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 1,
          backgroundColor: Color(0xFF0F9D58),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: initialScreen,
    );
  }
}
