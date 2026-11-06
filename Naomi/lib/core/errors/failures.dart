import 'package:equatable/equatable.dart';

/// Lớp cơ sở cho toàn bộ các lỗi nghiệp vụ trong hệ thống
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Không thể kết nối đến máy chủ MangaDex. Vui lòng thử lại sau.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Bạn đang ngoại tuyến. Vui lòng kiểm tra lại kết nối mạng.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Không thể nạp dữ liệu từ bộ nhớ thiết bị.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Xác thực tài khoản không thành công.']);
}