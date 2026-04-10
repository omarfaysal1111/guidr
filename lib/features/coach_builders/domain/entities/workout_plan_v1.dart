import 'package:equatable/equatable.dart';

/// Response from `POST /v1/plans`.
class CreatedCoachWorkoutPlanV1 extends Equatable {
  final String id;
  final String title;
  final String description;

  const CreatedCoachWorkoutPlanV1({
    required this.id,
    required this.title,
    required this.description,
  });

  factory CreatedCoachWorkoutPlanV1.fromJson(Map<String, dynamic> json) {
    return CreatedCoachWorkoutPlanV1(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, description];
}

/// Response from `POST /v1/plans/{planId}/workouts`.
class CreatedPlanSessionV1 extends Equatable {
  final String planSessionId;

  const CreatedPlanSessionV1({required this.planSessionId});

  factory CreatedPlanSessionV1.fromJson(Map<String, dynamic> json) {
    final sid = json['planSessionId']?.toString() ?? json['id']?.toString() ?? '';
    return CreatedPlanSessionV1(planSessionId: sid);
  }

  @override
  List<Object?> get props => [planSessionId];
}
