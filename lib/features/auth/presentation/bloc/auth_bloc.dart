import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState(isAuthenticated: false)) {
    on<AuthLoggedIn>(
      (event, emit) => emit(const AuthState(isAuthenticated: true)),
    );
    on<AuthLoggedOut>(
      (event, emit) => emit(const AuthState(isAuthenticated: false)),
    );
  }
}
