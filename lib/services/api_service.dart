import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

/// Service yang menangani komunikasi jaringan (HTTP Request) ke REST API Recipes DummyJSON.
///
/// Sesuai ketentuan soal:
/// - Base API : https://dummyjson.com/recipes
/// - Untuk detail data diakses berdasarkan id-nya: https://dummyjson.com/recipes/{id}
class ApiService {
  static const String baseUrl = 'https://dummyjson.com/recipes';

  /// Mengambil seluruh data resep masakan dari API.
  /// Menggunakan query `?limit=50` agar mendapatkan seluruh daftar resep.
  static Future<List<RecipeModel>> getRecipes() async {
    final uri = Uri.parse('$baseUrl?limit=50');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> rawList = decoded['recipes'] ?? [];
        return rawList.map((item) => RecipeModel.fromMap(item)).toList();
      } else {
        throw Exception(
          'Gagal memuat resep: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  /// Mengambil detail satu data resep berdasarkan ID resep.
  /// Contoh: https://dummyjson.com/recipes/{id}
  static Future<RecipeModel> getRecipeDetail(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return RecipeModel.fromMap(decoded);
      } else {
        throw Exception(
          'Gagal memuat detail resep (ID $id): Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi detail: $e');
    }
  }
}
