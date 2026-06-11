import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuth extends AuthEvent {}

class LoginUser extends AuthEvent {
  final String email;
  final String password;
  const LoginUser({required this.email, required this.password});
  @override
  List<Object?> get props => [email];
}

class RegisterUser extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const RegisterUser(
      {required this.name, required this.email, required this.password});
  @override
  List<Object?> get props => [email];
}

class LogoutUser extends AuthEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user.id];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<CheckAuth>(_onCheckAuth);
    on<LoginUser>(_onLogin);
    on<RegisterUser>(_onRegister);
    on<LogoutUser>(_onLogout);
  }

  Future<void> _onCheckAuth(CheckAuth event, Emitter<AuthState> emit) async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Invalid email or password'));
    }
  }

  Future<void> _onRegister(RegisterUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.register(
          event.name, event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> _onLogout(LogoutUser event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(AuthUnauthenticated());
  }
}
