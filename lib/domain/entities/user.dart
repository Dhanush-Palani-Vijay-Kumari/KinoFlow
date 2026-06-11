import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, email];
}
