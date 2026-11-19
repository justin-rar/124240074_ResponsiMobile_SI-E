import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart';

/// Halaman List Resep Masakan (Halaman Utama).
///
/// Memenuhi ketentuan soal nomor 2 (Halaman List - 30 Poin):
/// - "Halaman list berisi data-data dari resep yang tersedia dari API"
/// - "Wajib menampilkan judul dari data"
/// - "Wajib menampilkan gambar sebagai leading (thumbnail) & memberikan exception handling apabila gambarnya tidak muncul"
/// - "Wajib memunculkan asal makanan dari data"
/// - "Wajib memunculkan rating dari data"
/// - "Tampilan list boleh bebas" (Ditampilkan dalam format Grid 3 kolom sesuai screenshot soal)
/// - Dilengkapi tombol navigasi ke halaman Favorite dan tombol Logout pada AppBar.
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<RecipeModel> _recipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  /// Mengambil data resep dari API dummyjson.com/recipes
  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipes = await ApiService.getRecipes();
      if (mounted) {
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Dialog konfirmasi untuk Logout
  void _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  /// Widget untuk membangun thumbnail gambar dengan exception handling
  Widget _buildRecipeImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Exception handling jika gambar gagal dimuat
        return Container(
          width: double.infinity,
          height: 110,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
          ),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: double.infinity,
          height: 110,
          color: Colors.grey.shade100,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF0F9D58),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F4),
      appBar: AppBar(
        title: const Text(
          'Resep Masakan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F9D58),
        elevation: 1,
        actions: [
          // Tombol menuju Halaman Favorite
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            tooltip: 'Halaman Favorite',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteScreen(),
                ),
              );
            },
          ),
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0F9D58),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchRecipes,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D58),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_recipes.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada data resep tersedia.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF0F9D58),
      onRefresh: _fetchRecipes,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsif: 3 kolom untuk layar HP standar (sesuai contoh soal) atau 4 jika lebar
          final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.62,
            ),
            itemCount: _recipes.length,
            itemBuilder: (context, index) {
              final recipe = _recipes[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        recipeId: recipe.id,
                        initialRecipe: recipe,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail Gambar dengan Exception Handling
                      _buildRecipeImage(recipe.image),

                      // Informasi Teks (Judul, Asal Makanan, Rating)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Judul Resep (Wajib menampilkan judul dari data)
                              Text(
                                recipe.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Color(0xFF263238),
                                ),
                              ),

                              // Asal Makanan & Rating (Wajib memunculkan asal & rating)
                              Text(
                                '${recipe.cuisine} • ★ ${recipe.rating}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
