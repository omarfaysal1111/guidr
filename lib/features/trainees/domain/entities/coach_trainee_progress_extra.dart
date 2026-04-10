import 'package:equatable/equatable.dart';

/// Trainee-submitted feedback note (Progress tab).
class CoachTraineeFeedbackEntry extends Equatable {
  final String id;
  final String message;
  final DateTime? submittedAt;

  const CoachTraineeFeedbackEntry({
    required this.id,
    required this.message,
    this.submittedAt,
  });

  factory CoachTraineeFeedbackEntry.fromJson(Map<String, dynamic> json) {
    final rawDate = json['submittedAt'] ?? json['date'] ?? json['createdAt'];
    DateTime? at;
    if (rawDate is String && rawDate.isNotEmpty) {
      at = DateTime.tryParse(rawDate);
    }
    return CoachTraineeFeedbackEntry(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ??
          json['body']?.toString() ??
          json['text']?.toString() ??
          '',
      submittedAt: at,
    );
  }

  @override
  List<Object?> get props => [id, message, submittedAt];
}

/// Trainee goal row (Progress tab).
class CoachTraineeGoalItem extends Equatable {
  final String id;
  final String title;
  final bool completed;

  const CoachTraineeGoalItem({
    required this.id,
    required this.title,
    this.completed = false,
  });

  factory CoachTraineeGoalItem.fromJson(Map<String, dynamic> json) {
    return CoachTraineeGoalItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ??
          json['text']?.toString() ??
          json['description']?.toString() ??
          '',
      completed: json['completed'] == true ||
          json['done'] == true ||
          json['isCompleted'] == true,
    );
  }

  @override
  List<Object?> get props => [id, title, completed];
}

List<CoachTraineeFeedbackEntry> parseFeedbackList(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(CoachTraineeFeedbackEntry.fromJson)
      .where((e) => e.message.isNotEmpty)
      .toList();
}

List<CoachTraineeGoalItem> parseGoalsList(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(CoachTraineeGoalItem.fromJson)
      .where((e) => e.title.isNotEmpty)
      .toList();
}
