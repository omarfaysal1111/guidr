import 'package:equatable/equatable.dart';

class NutritionPlan extends Equatable {
  final int id;
  final String title;
  final String description;

  const NutritionPlan({
    required this.id,
    required this.title,
    required this.description,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    return NutritionPlan(
      id: json['id'] as int? ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, description];
}

class ExercisePlan extends Equatable {
  final int id;
  final String title;
  final String description;

  const ExercisePlan({
    required this.id,
    required this.title,
    required this.description,
  });

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    return ExercisePlan(
      id: json['id'] as int? ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, description];
}
