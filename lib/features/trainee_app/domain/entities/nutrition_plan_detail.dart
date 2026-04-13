import 'package:equatable/equatable.dart';

class NutritionIngredient extends Equatable {
  final int id;
  final String name;

  const NutritionIngredient({required this.id, required this.name});

  factory NutritionIngredient.fromJson(Map<String, dynamic> json) {
    return NutritionIngredient(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
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
  List<Object?> get props => [id, name, calories, protein, carbs, fat, ingredients];
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
