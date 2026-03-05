import 'package:equatable/equatable.dart';

enum UserRole {
  coach,
  trainee,
  unauthenticated
}

class User extends Equatable {
  final String id;
  final String email;
  final UserRole role;
  
  const User({
    required this.id,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, role];
}
