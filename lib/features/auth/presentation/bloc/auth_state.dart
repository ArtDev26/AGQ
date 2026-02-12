import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  const AuthState({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}
