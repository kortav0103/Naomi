import 'package:equatable/equatable.dart';

/// Lớp cơ sở cho toàn bộ các lỗi nghiệp vụ trong hệ thống
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Unable to connect to MangaDex server. Please try again later.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'You are offline. Please check your internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Unable to load data from device storage.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Account authentication failed.']);
}

/// Đăng ký thành công nhưng cần xác nhận email trước khi đăng nhập
class EmailConfirmationRequiredFailure extends AuthFailure {
  const EmailConfirmationRequiredFailure([
    super.message = 'Account created! Please check your inbox to confirm your email, then sign in.',
  ]);
}
