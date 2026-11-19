/// Model data untuk menampung informasi Resep Masakan dari API dummyjson.com/recipes.
///
/// Digunakan pada Halaman List, Halaman Detail, dan Halaman Favorite.
/// Menyimpan seluruh informasi resep seperti nama, bahan-bahan, langkah memasak,
/// waktu persiapan & memasak, porsi, kalori, tingkat kesulitan, asal makanan (cuisine),
/// dan rating.
class RecipeModel {
  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final List<String> tags;
  final int userId;
  final String image;
  final double rating;
  final int reviewCount;
  final List<String> mealType;

  RecipeModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.caloriesPerServing,
    required this.tags,
    required this.userId,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.mealType,
  });

  /// Factory constructor untuk mem-parse JSON Map dari REST API dummyjson.com
  /// maupun dari Map lokal di database Hive.
  factory RecipeModel.fromMap(Map<dynamic, dynamic> map) {
    // Parsing ingredients secara aman
    List<String> parsedIngredients = [];
    if (map['ingredients'] != null && map['ingredients'] is List) {
      parsedIngredients = (map['ingredients'] as List)
          .map((e) => e.toString())
          .toList();
    }

    // Parsing instructions secara aman
    List<String> parsedInstructions = [];
    if (map['instructions'] != null && map['instructions'] is List) {
      parsedInstructions = (map['instructions'] as List)
          .map((e) => e.toString())
          .toList();
    }

    // Parsing tags
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'] is List) {
      parsedTags = (map['tags'] as List).map((e) => e.toString()).toList();
    }

    // Parsing mealType
    List<String> parsedMealType = [];
    if (map['mealType'] != null && map['mealType'] is List) {
      parsedMealType =
          (map['mealType'] as List).map((e) => e.toString()).toList();
    }

    return RecipeModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name']?.toString() ?? 'Tanpa Nama',
      ingredients: parsedIngredients,
      instructions: parsedInstructions,
      prepTimeMinutes: map['prepTimeMinutes'] is int
          ? map['prepTimeMinutes']
          : int.tryParse(map['prepTimeMinutes']?.toString() ?? '0') ?? 0,
      cookTimeMinutes: map['cookTimeMinutes'] is int
          ? map['cookTimeMinutes']
          : int.tryParse(map['cookTimeMinutes']?.toString() ?? '0') ?? 0,
      servings: map['servings'] is int
          ? map['servings']
          : int.tryParse(map['servings']?.toString() ?? '0') ?? 0,
      difficulty: map['difficulty']?.toString() ?? 'Easy',
      cuisine: map['cuisine']?.toString() ?? 'Unknown',
      caloriesPerServing: map['caloriesPerServing'] is int
          ? map['caloriesPerServing']
          : int.tryParse(map['caloriesPerServing']?.toString() ?? '0') ?? 0,
      tags: parsedTags,
      userId: map['userId'] is int
          ? map['userId']
          : int.tryParse(map['userId']?.toString() ?? '0') ?? 0,
      image: map['image']?.toString() ?? '',
      rating: map['rating'] is num
          ? (map['rating'] as num).toDouble()
          : double.tryParse(map['rating']?.toString() ?? '0.0') ?? 0.0,
      reviewCount: map['reviewCount'] is int
          ? map['reviewCount']
          : int.tryParse(map['reviewCount']?.toString() ?? '0') ?? 0,
      mealType: parsedMealType,
    );
  }

  /// Konversi objek RecipeModel ke `Map<String, dynamic>` untuk penyimpanan di Hive.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'cuisine': cuisine,
      'caloriesPerServing': caloriesPerServing,
      'tags': tags,
      'userId': userId,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'mealType': mealType,
    };
  }
}
