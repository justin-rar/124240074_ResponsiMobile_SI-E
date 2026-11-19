import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:latresuas/models/recipe_model.dart';
import 'package:latresuas/screens/login_screen.dart';
import 'package:latresuas/screens/detail_screen.dart';
import 'package:latresuas/screens/favorite_screen.dart';
import 'package:latresuas/services/favorite_service.dart';

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox(FavoriteService.boxName);
  });

  testWidgets('LoginScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Selamat Datang di Resep Masakan'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('DetailScreen renders recipe information properly',
      (WidgetTester tester) async {
    final recipe = RecipeModel(
      id: 1,
      name: 'Classic Margherita Pizza',
      ingredients: ['Pizza dough', 'Tomato sauce', 'Mozzarella'],
      instructions: ['Preheat oven.', 'Bake for 15 minutes.'],
      prepTimeMinutes: 20,
      cookTimeMinutes: 15,
      servings: 4,
      difficulty: 'Easy',
      cuisine: 'Italian',
      caloriesPerServing: 300,
      tags: ['Pizza'],
      userId: 1,
      image: '',
      rating: 4.6,
      reviewCount: 98,
      mealType: ['Dinner'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DetailScreen(
          recipeId: recipe.id,
          initialRecipe: recipe,
        ),
      ),
    );

    expect(find.text('Detail Resep'), findsOneWidget);
    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    expect(find.text('Bahan-bahan'), findsOneWidget);
    expect(find.text('Langkah Memasak'), findsOneWidget);
    expect(find.text('Pizza dough'), findsOneWidget);
    expect(find.text('Preheat oven.'), findsOneWidget);
  });

  testWidgets('FavoriteScreen renders empty state when no favorites exist',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FavoriteScreen(),
      ),
    );

    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Belum Ada Resep Favorit'), findsOneWidget);
  });
}
