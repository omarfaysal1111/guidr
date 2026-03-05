import 'package:equatable/equatable.dart';

class Invitation extends Equatable {
  final String id;
  final String email;
  final String token;

  const Invitation({
    required this.id,
    required this.email,
    required this.token,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, email, token];
}
