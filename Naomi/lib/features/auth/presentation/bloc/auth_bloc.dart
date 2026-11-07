import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginSubmittedEvent>(_onLogin);
    on<SignUpSubmittedEvent>(_onSignUp);
    on<GuestLoginEvent>(_onGuestLogin);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    final result = await authRepository.getCurrentUser();
    result.fold(
      (_) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(LoginSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUp(SignUpSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authRepository.signUp(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onGuestLogin(GuestLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authRepository.continueAsGuest();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await authRepository.logout();
    emit(const Unauthenticated());
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is Authenticated) {
      final result = await authRepository.updateProfile(displayName: event.displayName);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (updatedUser) => emit(Authenticated(updatedUser)),
      );
    }
  }
}
