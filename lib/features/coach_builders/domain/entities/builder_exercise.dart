class BuilderExercise {
  final int? exerciseId;
  final String name;
  final int sets;
  final String reps;
  final String? load;
  final String? rest;
  final String? videoUrl;

  const BuilderExercise({
    this.exerciseId,
    required this.name,
    this.sets = 3,
    this.reps = '10',
    this.load,
    this.rest,
    this.videoUrl,
  });

  BuilderExercise copyWith({
    int? exerciseId,
    String? name,
    int? sets,
    String? reps,
    String? load,
    String? rest,
    String? videoUrl,
  }) {
    return BuilderExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      load: load ?? this.load,
      rest: rest ?? this.rest,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
