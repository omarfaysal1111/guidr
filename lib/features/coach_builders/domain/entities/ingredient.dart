import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final int id;
  final String name;
  final double servingQuantityG;
  final double calories;
  final double fat;
  final double carbohydrates;
  final double protein;
  final double? water;
  final double? totalMinerals;

  const Ingredient({
    required this.id,
    required this.name,
    required this.servingQuantityG,
    required this.calories,
    required this.fat,
    required this.carbohydrates,
    required this.protein,
    this.water,
    this.totalMinerals,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int? ?? 0,
      name: json['name'] ?? '',
      servingQuantityG:
          (json['servingQuantityG'] as num?)?.toDouble() ?? 100.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      water: (json['water'] as num?)?.toDouble(),
      totalMinerals: (json['totalMinerals'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, servingQuantityG, calories, fat, carbohydrates, protein];
}

/// Represents a single ingredient added to a meal section in the builder,
/// carrying either a library [Ingredient] + quantity, or a free-text entry.
class MealIngredientEntry extends Equatable {
  final Ingredient? ingredient;
  final String name;
  final double quantityG;

  const MealIngredientEntry({
    this.ingredient,
    required this.name,
    required this.quantityG,
  });

  factory MealIngredientEntry.fromLibrary(Ingredient ing, double qty) =>
      MealIngredientEntry(
        ingredient: ing,
        name: ing.name,
        quantityG: qty,
      );

  factory MealIngredientEntry.custom(String customName) =>
      MealIngredientEntry(name: customName, quantityG: 0);

  bool get isFromLibrary => ingredient != null;

  MealIngredientEntry copyWithQty(double newQty) => MealIngredientEntry(
        ingredient: ingredient,
        name: name,
        quantityG: newQty,
      );

  double get calories => _scale(ingredient?.calories);
  double get protein => _scale(ingredient?.protein);
  double get carbs => _scale(ingredient?.carbohydrates);
  double get fat => _scale(ingredient?.fat);

  double _scale(double? perServing) {
    if (perServing == null || ingredient == null) return 0;
    final base = ingredient!.servingQuantityG;
    return base > 0 ? perServing * quantityG / base : 0;
  }

  @override
  List<Object?> get props => [ingredient, name, quantityG];
}
