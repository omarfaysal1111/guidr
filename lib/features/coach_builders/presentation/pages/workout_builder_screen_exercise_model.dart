class BuilderExercise {
  final String name;
  int sets;
  String reps;
  String? load;
  String? rest;
  String? videoUrl;

   BuilderExercise({
    required this.name,
    this.sets = 3,
    this.reps = '10',
    this.load,
    this.rest,
    this.videoUrl,
  });
}

