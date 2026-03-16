import 'package:equatable/equatable.dart';

class TraineeExercisePlanDetail extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String difficulty;
  final int exercisesTotal;
  final int durationMinutes;
  final int estimatedCalories;
  final int setsTotal;
  final String coachNote;
  final List<TraineeExerciseItem> exercises;

  const TraineeExercisePlanDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.exercisesTotal,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.setsTotal,
    required this.coachNote,
    required this.exercises,
  });

  factory TraineeExercisePlanDetail.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TraineeExercisePlanDetail(
      id: _toInt(json['id']),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      difficulty: json['difficulty'] ?? '',
      exercisesTotal: _toInt(json['exercisesTotal']),
      durationMinutes: _toInt(json['durationMinutes']),
      estimatedCalories: _toInt(json['estimatedCalories']),
      setsTotal: _toInt(json['setsTotal']),
      coachNote: json['coachNote'] ?? '',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => TraineeExerciseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        difficulty,
        exercisesTotal,
        durationMinutes,
        estimatedCalories,
        setsTotal,
        coachNote,
        exercises,
      ];
}

class TraineeExerciseItem extends Equatable {
  final int order;
  final String name;
  final int sets;
  final String reps;
  final String? load;
  final String rest;
  final String muscleGroup;
  final String status;
  final String? videoUrl;

  const TraineeExerciseItem({
    required this.order,
    required this.name,
    required this.sets,
    required this.reps,
    required this.load,
    required this.rest,
    required this.muscleGroup,
    required this.status,
    required this.videoUrl,
  });

  factory TraineeExerciseItem.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return TraineeExerciseItem(
      order: _toInt(json['order']),
      name: json['name'] ?? '',
      sets: _toInt(json['sets']),
      reps: json['reps'] ?? '',
      load: json['load']?.toString(),
      rest: json['rest']?.toString() ?? '',
      muscleGroup: json['muscleGroup'] ?? '',
      status: json['status'] ?? 'not_started',
      videoUrl: json['videoUrl']?.toString(),
    );
  }

  @override
  List<Object?> get props =>
      [order, name, sets, reps, load, rest, muscleGroup, status, videoUrl];
}

