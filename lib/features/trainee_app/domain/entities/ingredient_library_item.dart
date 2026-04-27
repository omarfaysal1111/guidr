import 'package:equatable/equatable.dart';

class IngredientLibraryItem extends Equatable {
  final int id;
  final String name;
  final double? servingQuantityG;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  const IngredientLibraryItem({
    required this.id,
    required this.name,
    this.servingQuantityG,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory IngredientLibraryItem.fromJson(Map<String, dynamic> json) {
    return IngredientLibraryItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      servingQuantityG:
          (json['servingQuantityG'] as num?)?.toDouble(),
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbohydrates'] as num?)?.toDouble() ??
          (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }

  bool get hasMacros =>
      calories != null || protein != null || carbs != null || fat != null;

  /// Calories scaled to [qty] grams (uses servingQuantityG as the base).
  double? caloriesForQty(double qty) {
    if (calories == null) return null;
    final base = servingQuantityG ?? 100.0;
    return base > 0 ? calories! * qty / base : null;
  }

  double? proteinForQty(double qty) {
    if (protein == null) return null;
    final base = servingQuantityG ?? 100.0;
    return base > 0 ? protein! * qty / base : null;
  }

  double? carbsForQty(double qty) {
    if (carbs == null) return null;
    final base = servingQuantityG ?? 100.0;
    return base > 0 ? carbs! * qty / base : null;
  }

  double? fatForQty(double qty) {
    if (fat == null) return null;
    final base = servingQuantityG ?? 100.0;
    return base > 0 ? fat! * qty / base : null;
  }

  @override
  List<Object?> get props =>
      [id, name, servingQuantityG, calories, protein, carbs, fat];
}
