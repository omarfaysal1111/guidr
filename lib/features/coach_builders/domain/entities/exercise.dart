import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? videoUrl;

  const Exercise({
    required this.id,
    required this.name,
    this.description,
    this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int? ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      // Backend can send either `videoUrl` or `videoLink`
      videoUrl: (json['videoUrl'] ?? json['videoLink'])?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name, description, videoUrl];
}
