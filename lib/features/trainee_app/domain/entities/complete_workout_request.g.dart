// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_workout_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSetLogRequest _$ExerciseSetLogRequestFromJson(
  Map<String, dynamic> json,
) => ExerciseSetLogRequest(
  outcome: $enumDecode(_$SetLogOutcomeEnumMap, json['outcome']),
  reason: json['reason'] as String?,
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  reps: (json['reps'] as num?)?.toInt(),
);

Map<String, dynamic> _$ExerciseSetLogRequestToJson(
  ExerciseSetLogRequest instance,
) => <String, dynamic>{
  'outcome': _$SetLogOutcomeEnumMap[instance.outcome]!,
  'reason': ?instance.reason,
  'weightKg': ?instance.weightKg,
  'reps': ?instance.reps,
};

const _$SetLogOutcomeEnumMap = {
  SetLogOutcome.completed: 'COMPLETED',
  SetLogOutcome.skipped: 'SKIPPED',
  SetLogOutcome.missed: 'MISSED',
};

ExerciseLogItemRequest _$ExerciseLogItemRequestFromJson(
  Map<String, dynamic> json,
) => ExerciseLogItemRequest(
  planSessionExerciseId: json['planSessionExerciseId'] as String,
  setOutcomes: (json['setOutcomes'] as List<dynamic>?)
      ?.map((e) => ExerciseSetLogRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  // actualSetsCompleted: (json['actualSetsCompleted'] as num?)?.toInt(),
  // skippedSets: (json['skippedSets'] as num?)?.toInt(),
  // excuse: json['excuse'] as String?,
);

Map<String, dynamic> _$ExerciseLogItemRequestToJson(
  ExerciseLogItemRequest instance,
) => <String, dynamic>{
  'planSessionExerciseId': instance.planSessionExerciseId,
  'setOutcomes': ?instance.setOutcomes?.map((e) => e.toJson()).toList(),
  // 'actualSetsCompleted': ?instance.actualSetsCompleted,
  // 'skippedSets': ?instance.skippedSets,
  // 'excuse': ?instance.excuse,
};

CompleteWorkoutRequest _$CompleteWorkoutRequestFromJson(
  Map<String, dynamic> json,
) => CompleteWorkoutRequest(
  exerciseLogs: (json['exerciseLogs'] as List<dynamic>)
      .map((e) => ExerciseLogItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CompleteWorkoutRequestToJson(
  CompleteWorkoutRequest instance,
) => <String, dynamic>{
  'exerciseLogs': instance.exerciseLogs.map((e) => e.toJson()).toList(),
};
