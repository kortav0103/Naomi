import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpSubmittedEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class GuestLoginEvent extends AuthEvent {
  const GuestLoginEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class UpdateProfileEvent extends AuthEvent {
  final String displayName;

  const UpdateProfileEvent(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

class ResetPasswordSubmittedEvent extends AuthEvent {
  final String email;

  const ResetPasswordSubmittedEvent(this.email);

  @override
  List<Object?> get props => [email];
}
