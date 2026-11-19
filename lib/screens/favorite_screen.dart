import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';
import '../services/favorite_service.dart';
import 'detail_screen.dart';

/// Halaman Daftar Resep Favorit (Fitur Favourite - 20 Poin).
///
/// Memenuhi ketentuan soal nomor 3:
/// - "Halaman yang berisi data-data yang difavoritkan oleh user. Semua data yang dinyatakan
///    sebagai favourite tercantum di halaman ini."
/// - "Penambahan data favourite dilakukan dari halaman detil"
/// - "List data favourite terupdate terlepas dilakukannya perubahan di halaman favourite
///    maupun dari halaman detil (tidak harus dari salah satunya)"
///
/// Menggunakan `ValueListenableBuilder` dari Hive Box sehingga perubahan apapun
/// (penambahan dari DetailScreen maupun penghapusan dari FavoriteScreen)
/// langsung me-rebuild UI secara real-time.
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  /// Widget thumbnail gambar dengan exception handling
  Widget _buildThumbnail(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0F9D58),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F4),
      appBar: AppBar(
        title: const Text(
          'Favorite',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F9D58),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: FavoriteService.listenable(),
        builder: (context, Box box, child) {
          final List<RecipeModel> favorites = FavoriteService.getAllFavorites();

          // Tampilan jika belum ada data resep favorit
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Resep Favorit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan resep favorit Anda melalui ikon hati pada Halaman Detail.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Menampilkan daftar kartu resep favorit sesuai screenshot soal halaman 4
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final recipe = favorites[index];

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  onTap: () {
                    // Navigasi ke Halaman Detail
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
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Thumbnail Gambar Makanan
                        _buildThumbnail(recipe.image),
                        const SizedBox(width: 14),

                        // Judul & Asal • Kesulitan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${recipe.cuisine} • ${recipe.difficulty}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Ikon Hati Merah (Hapus dari Favorite)
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          tooltip: 'Hapus dari Favorite',
                          onPressed: () async {
                            await FavoriteService.removeFavorite(recipe.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dihapus dari favorite'),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
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
