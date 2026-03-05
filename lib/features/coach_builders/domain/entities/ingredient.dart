import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final int id;
  final String name;
  final double calories;

  const Ingredient({required this.id, required this.name, required this.calories});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int? ?? 0,
      name: json['name'] ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, name, calories];
}
