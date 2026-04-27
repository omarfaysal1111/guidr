import 'package:json_annotation/json_annotation.dart';

part 'complete_workout_request.g.dart';

@JsonEnum(alwaysCreate: true)
enum SetLogOutcome {
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('SKIPPED')
  skipped,
  @JsonValue('MISSED')
  missed,
}

@JsonSerializable(includeIfNull: false)
class ExerciseSetLogRequest {
  final SetLogOutcome outcome;
  final String? reason;
  final double? weightKg;
  final int? reps;

  const ExerciseSetLogRequest({
    required this.outcome,
    this.reason,
    this.weightKg,
    this.reps,
  });

  factory ExerciseSetLogRequest.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSetLogRequestToJson(this);
}

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ExerciseLogItemRequest {
  final String planSessionExerciseId;
  final List<ExerciseSetLogRequest>? setOutcomes;
  // final int? actualSetsCompleted;
  // final int? skippedSets;
  // final String? excuse;

  const ExerciseLogItemRequest({
    required this.planSessionExerciseId,
    this.setOutcomes,
    // this.actualSetsCompleted,
    // this.skippedSets,
    // this.excuse,
  });

  factory ExerciseLogItemRequest.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseLogItemRequestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CompleteWorkoutRequest {
  final List<ExerciseLogItemRequest> exerciseLogs;

  const CompleteWorkoutRequest({ required this.exerciseLogs,});

  factory CompleteWorkoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CompleteWorkoutRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteWorkoutRequestToJson(this);
}
