import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';

/// Halaman Detail Resep Masakan.
///
/// Memenuhi ketentuan soal nomor 4 (Halaman Detil - 30 Poin):
/// - "Base API : https://dummyjson.com/recipes, Untuk detail data diakses berdasarkan id nya."
/// - "Wajib menampilkan gambar (lengkap dengan exception handling)"
/// - "Wajib menampilkan judul data"
/// - "Wajib menampilkan bahan-bahan data"
/// - "Wajib menampilkan Intruksi data"
/// - "Penambahan data favourite dilakukan dari halaman detil"
///
/// Tampilan disusun identik dengan screenshot soal halaman 5:
/// - Gambar resep penuh di bagian atas
/// - Judul resep dan Asal Makanan (Cuisine • Meal Type)
/// - Badges / Chips: Rating, Tingkat Kesulitan, Waktu Persiapan, Waktu Masak, Porsi, Kalori
/// - Bagian Bahan-bahan dengan bullet points
/// - Bagian Langkah Memasak dengan nomor urut lingkaran hijau
/// - Tombol Favorite di AppBar yang reaktif dan memunculkan SnackBar
class DetailScreen extends StatefulWidget {
  final int recipeId;
  final RecipeModel? initialRecipe;

  const DetailScreen({
    super.key,
    required this.recipeId,
    this.initialRecipe,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  RecipeModel? _recipe;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _recipe = widget.initialRecipe;
    _fetchDetail();
  }

  /// Mengambil data detail resep berdasarkan ID dari endpoint API:
  /// https://dummyjson.com/recipes/{id}
  Future<void> _fetchDetail() async {
    // Jika data awal belum ada, aktifkan loading
    if (_recipe == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final fetched = await ApiService.getRecipeDetail(widget.recipeId);
      if (mounted) {
        setState(() {
          _recipe = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_recipe == null) {
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  /// Helper untuk membuat Badge / Chip informasi resep
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color iconColor = const Color(0xFF0F9D58),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCFD8DC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF37474F),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Resep',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F9D58),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Tombol Toggle Favorite di AppBar
          if (_recipe != null)
            ValueListenableBuilder<Box>(
              valueListenable: FavoriteService.listenable(),
              builder: (context, box, child) {
                final isFav = FavoriteService.isFavorite(_recipe!.id);

                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.amberAccent : Colors.white,
                  ),
                  tooltip:
                      isFav ? 'Hapus dari Favorite' : 'Tambahkan ke Favorite',
                  onPressed: () async {
                    final added =
                        await FavoriteService.toggleFavorite(_recipe!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            added
                                ? 'Ditambahkan ke favorite'
                                : 'Dihapus dari favorite',
                          ),
                          behavior: SnackBarBehavior.fixed,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _recipe == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F9D58)),
      );
    }

    if (_errorMessage != null && _recipe == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat detail resep:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchDetail,
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

    final recipe = _recipe!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gambar Resep Utama (Wajib menampilkan gambar + exception handling)
          Image.network(
            recipe.image,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey.shade200,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 54, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Gambar tidak dapat dimuat',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey.shade100,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0F9D58),
                  ),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Judul Resep (Wajib menampilkan judul data)
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 4),

                // Asal Makanan & Jenis Santapan (Cuisine • Meal Type)
                Text(
                  '${recipe.cuisine} • ${recipe.mealType.isNotEmpty ? recipe.mealType.join(', ') : 'All Meals'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Badges / Chips Informasi Resep
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    // Rating
                    _buildInfoChip(
                      icon: Icons.star,
                      label: '★ ${recipe.rating} (${recipe.reviewCount})',
                      iconColor: Colors.amber.shade700,
                    ),
                    // Tingkat Kesulitan
                    _buildInfoChip(
                      icon: Icons.speed,
                      label: recipe.difficulty,
                      iconColor: const Color(0xFF0F9D58),
                    ),
                    // Waktu Persiapan
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: 'Persiapan ${recipe.prepTimeMinutes} mnt',
                      iconColor: const Color(0xFF0F9D58),
                    ),
                    // Waktu Masak
                    _buildInfoChip(
                      icon: Icons.timer_outlined,
                      label: 'Masak ${recipe.cookTimeMinutes} mnt',
                      iconColor: const Color(0xFF0F9D58),
                    ),
                    // Jumlah Porsi
                    _buildInfoChip(
                      icon: Icons.people_outline,
                      label: '${recipe.servings} porsi',
                      iconColor: const Color(0xFF0F9D58),
                    ),
                    // Kalori
                    _buildInfoChip(
                      icon: Icons.local_fire_department_outlined,
                      label: '${recipe.caloriesPerServing} kal/porsi',
                      iconColor: Colors.orange.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Bagian Bahan-bahan (Wajib menampilkan bahan-bahan data)
                const Text(
                  'Bahan-bahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 8),
                if (recipe.ingredients.isEmpty)
                  Text(
                    'Tidak ada data bahan-bahan.',
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                else
                  ...recipe.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F9D58),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: Color(0xFF37474F),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // 5. Bagian Langkah Memasak (Wajib menampilkan instruksi data)
                const Text(
                  'Langkah Memasak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 12),
                if (recipe.instructions.isEmpty)
                  Text(
                    'Tidak ada langkah memasak tersedia.',
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                else
                  ...recipe.instructions.asMap().entries.map(
                    (entry) {
                      final int stepNumber = entry.key + 1;
                      final String instruction = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nomor urut lingkaran hijau sesuai screenshot soal
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F9D58),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$stepNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Teks instruksi langkah
                            Expanded(
                              child: Text(
                                instruction,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF37474F),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
