import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Đăng nhập bằng Email & Mật khẩu
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới.
  /// Trả về [EmailConfirmationRequiredFailure] nếu máy chủ yêu cầu xác nhận email trước khi đăng nhập.
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Tiếp tục với tư cách Khách trải nghiệm (Guest Session)
  Future<Either<Failure, UserEntity>> continueAsGuest();

  /// Lấy thông tin phiên đăng nhập hiện tại từ Secure Storage (Auto-Login)
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Đăng xuất tài khoản
  Future<Either<Failure, void>> logout();

  /// Cập nhật tên hiển thị của người dùng
  Future<Either<Failure, UserEntity>> updateProfile({
    required String displayName,
  });

  /// Gửi email chứa liên kết đặt lại mật khẩu (US-00 / FR-00)
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });
}
