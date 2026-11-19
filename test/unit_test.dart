import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:latresuas/models/recipe_model.dart';
import 'package:latresuas/services/auth_service.dart';
import 'package:latresuas/services/favorite_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('hive_unit_test');
    Hive.init(tempDir.path);
    await Hive.openBox(FavoriteService.boxName);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService Tests', () {
    test('Login succeeds with valid username "justin" and password "074"',
        () async {
      final success = await AuthService.login('justin', '074');
      expect(success, isTrue);

      final isLoggedIn = await AuthService.isLoggedIn();
      expect(isLoggedIn, isTrue);

      final user = await AuthService.getCurrentUser();
      expect(user, equals('justin'));
    });

    test('Login is case-insensitive for username ("Justin")', () async {
      final success = await AuthService.login('Justin', '074');
      expect(success, isTrue);
    });

    test('Login fails with invalid password', () async {
      final success = await AuthService.login('justin', '123');
      expect(success, isFalse);

      final isLoggedIn = await AuthService.isLoggedIn();
      expect(isLoggedIn, isFalse);
    });

    test('Login fails with invalid username', () async {
      final success = await AuthService.login('budi', '074');
      expect(success, isFalse);
    });

    test('Logout clears session correctly', () async {
      await AuthService.login('justin', '074');
      expect(await AuthService.isLoggedIn(), isTrue);

      await AuthService.logout();
      expect(await AuthService.isLoggedIn(), isFalse);
      expect(await AuthService.getCurrentUser(), isNull);
    });
  });

  group('RecipeModel Tests', () {
    test('RecipeModel parses correctly from map and serializes back', () {
      final jsonMap = {
        'id': 10,
        'name': 'Fried Rice',
        'ingredients': ['Rice', 'Egg', 'Soy Sauce'],
        'instructions': ['Heat wok', 'Stir fry'],
        'prepTimeMinutes': 10,
        'cookTimeMinutes': 15,
        'servings': 2,
        'difficulty': 'Easy',
        'cuisine': 'Indonesian',
        'caloriesPerServing': 400,
        'tags': ['Rice', 'Asian'],
        'userId': 5,
        'image': 'https://example.com/fried_rice.jpg',
        'rating': 4.8,
        'reviewCount': 50,
        'mealType': ['Lunch', 'Dinner'],
      };

      final recipe = RecipeModel.fromMap(jsonMap);

      expect(recipe.id, equals(10));
      expect(recipe.name, equals('Fried Rice'));
      expect(recipe.ingredients.length, equals(3));
      expect(recipe.instructions.length, equals(2));
      expect(recipe.cuisine, equals('Indonesian'));
      expect(recipe.rating, equals(4.8));

      final map = recipe.toMap();
      expect(map['id'], equals(10));
      expect(map['name'], equals('Fried Rice'));
      expect(map['cuisine'], equals('Indonesian'));
    });
  });

  group('FavoriteService Tests', () {
    final recipe = RecipeModel(
      id: 101,
      name: 'Nasi Goreng',
      ingredients: ['Nasi', 'Bawang'],
      instructions: ['Goreng'],
      prepTimeMinutes: 5,
      cookTimeMinutes: 10,
      servings: 1,
      difficulty: 'Easy',
      cuisine: 'Indonesian',
      caloriesPerServing: 350,
      tags: ['Indonesian'],
      userId: 1,
      image: '',
      rating: 5.0,
      reviewCount: 10,
      mealType: ['Dinner'],
    );

    test('FavoriteService toggle and remove operations', () async {
      expect(FavoriteService.isFavorite(101), isFalse);

      // Add to favorite
      final added = await FavoriteService.toggleFavorite(recipe);
      expect(added, isTrue);
      expect(FavoriteService.isFavorite(101), isTrue);

      final favorites = FavoriteService.getAllFavorites();
      expect(favorites.any((r) => r.id == 101), isTrue);

      // Remove from favorite via toggle
      final removed = await FavoriteService.toggleFavorite(recipe);
      expect(removed, isFalse);
      expect(FavoriteService.isFavorite(101), isFalse);

      // Add again and remove via removeFavorite
      await FavoriteService.toggleFavorite(recipe);
      expect(FavoriteService.isFavorite(101), isTrue);

      await FavoriteService.removeFavorite(101);
      expect(FavoriteService.isFavorite(101), isFalse);
    });
  });
}
