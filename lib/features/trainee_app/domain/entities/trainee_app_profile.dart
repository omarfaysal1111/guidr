import 'package:equatable/equatable.dart';

class TraineeAppProfile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? fitnessGoal;

  const TraineeAppProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.fitnessGoal,
  });

  factory TraineeAppProfile.fromJson(Map<String, dynamic> json) {
    return TraineeAppProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      fitnessGoal: json['fitnessGoal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'fitnessGoal': fitnessGoal,
    };
  }

  @override
  List<Object?> get props => [id, fullName, email, fitnessGoal];
}
