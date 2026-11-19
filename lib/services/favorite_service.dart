import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';

/// Service untuk mengelola data resep yang difavoritkan pengguna menggunakan Hive.
///
/// Memenuhi ketentuan soal:
/// 1. "Penambahan data favourite dilakukan dari halaman detil"
/// 2. "List data favourite terupdate terlepas dilakukannya perubahan di halaman favourite
///     maupun dari halaman detil (tidak harus dari salah satunya)"
///
/// Penggunaan `ValueListenableBuilder` bersama `box.listenable()` memastikan
/// perubahan favorit langsung tersinkronisasi di seluruh halaman secara real-time.
class FavoriteService {
  // Nama box Hive untuk menyimpan data resep favorit
  static const String boxName = 'recipes_favorite_box';

  /// Mendapatkan instance box Hive yang sudah di-open di `main.dart`.
  static Box get box => Hive.box(boxName);

  /// Mengembalikan `ValueListenable` dari box Hive agar UI bisa me-rebuild secara otomatis
  /// saat ada data favorit baru ditambahkan atau dihapus.
  static ValueListenable<Box> listenable() => box.listenable();

  /// Memeriksa apakah resep dengan ID tertentu sudah ada di daftar favorit.
  static bool isFavorite(int id) {
    return box.containsKey(id.toString());
  }

  /// Menambahkan resep ke daftar favorit jika belum ada, atau menghapusnya jika sudah ada.
  /// Mengembalikan `true` jika ditambahkan, atau `false` jika dihapus.
  static Future<bool> toggleFavorite(RecipeModel recipe) async {
    final key = recipe.id.toString();
    if (box.containsKey(key)) {
      await box.delete(key);
      return false; // Dihapus dari favorit
    } else {
      await box.put(key, recipe.toMap());
      return true; // Ditambahkan ke favorit
    }
  }

  /// Menghapus resep dari daftar favorit berdasarkan ID resep.
  static Future<void> removeFavorite(int id) async {
    await box.delete(id.toString());
  }

  /// Mengambil semua resep yang ada di daftar favorit dari box Hive.
  static List<RecipeModel> getAllFavorites() {
    final list = <RecipeModel>[];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        list.add(RecipeModel.fromMap(Map<dynamic, dynamic>.from(val)));
      }
    }
    return list;
  }
}
