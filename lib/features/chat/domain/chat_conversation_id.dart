/// Stable id for the 1:1 thread between one coach and one trainee (backend ids).
String chatConversationId({
  required String coachId,
  required String traineeId,
}) {
  final a = coachId.trim();
  final b = traineeId.trim();
  if (a.isEmpty || b.isEmpty) {
    throw ArgumentError('coachId and traineeId must be non-empty');
  }
  final sorted = [a, b]..sort();
  return '${sorted[0]}__${sorted[1]}';
}
