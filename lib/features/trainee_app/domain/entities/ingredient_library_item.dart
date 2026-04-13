import 'package:equatable/equatable.dart';

class IngredientLibraryItem extends Equatable {
  final int id;
  final String name;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  const IngredientLibraryItem({
    required this.id,
    required this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory IngredientLibraryItem.fromJson(Map<String, dynamic> json) {
    return IngredientLibraryItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, calories, protein, carbs, fat];
}
