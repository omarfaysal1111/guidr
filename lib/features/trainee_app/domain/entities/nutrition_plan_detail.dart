import 'package:equatable/equatable.dart';

class NutritionIngredient extends Equatable {
  final int id;
  final String name;
  final double servingQuantityG;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionIngredient({
    required this.id,
    required this.name,
    this.servingQuantityG = 100.0,
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
  });

  factory NutritionIngredient.fromJson(Map<String, dynamic> json) {
    return NutritionIngredient(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      servingQuantityG:
          (json['servingQuantityG'] as num?)?.toDouble() ?? 100.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbohydrates'] as num?)?.toDouble() ??
          (json['carbs'] as num?)?.toDouble() ??
          0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool get hasMacros => calories > 0 || protein > 0 || carbs > 0 || fat > 0;

  /// Calories for a given quantity (scales linearly from servingQuantityG).
  double caloriesForQty(double qty) =>
      servingQuantityG > 0 ? calories * qty / servingQuantityG : 0;

  double proteinForQty(double qty) =>
      servingQuantityG > 0 ? protein * qty / servingQuantityG : 0;

  double carbsForQty(double qty) =>
      servingQuantityG > 0 ? carbs * qty / servingQuantityG : 0;

  double fatForQty(double qty) =>
      servingQuantityG > 0 ? fat * qty / servingQuantityG : 0;

  @override
  List<Object?> get props =>
      [id, name, servingQuantityG, calories, protein, carbs, fat];
}

class NutritionMealDetail extends Equatable {
  final int id;
  final String name;
  final double calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final List<NutritionIngredient> ingredients;

  const NutritionMealDetail({
    required this.id,
    required this.name,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    required this.ingredients,
  });

  factory NutritionMealDetail.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'] as List<dynamic>? ?? [];
    return NutritionMealDetail(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      ingredients: rawIngredients
          .map((e) => NutritionIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, calories, protein, carbs, fat, ingredients];
}

class NutritionPlanDetail extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type;
  final List<NutritionMealDetail> meals;

  const NutritionPlanDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.meals,
  });

  factory NutritionPlanDetail.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'] as List<dynamic>? ?? [];
    return NutritionPlanDetail(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      meals: rawMeals
          .map((e) => NutritionMealDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, description, type, meals];
}
