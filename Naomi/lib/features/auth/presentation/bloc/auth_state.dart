import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo khi vừa mở app
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Đang xử lý các tác vụ xác thực (Login, Register, Guest, Reset Password)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Đã xác thực thành công (hoặc đang duyệt app dưới tư cách Guest)
class Authenticated extends AuthState {
  final UserEntity user;
  final bool isGuest;
  final String? updateError; // Giữ thông báo lỗi cập nhật mà không hủy state đăng nhập
  final String? updateSuccessMessage;

  const Authenticated(
    this.user, {
    this.isGuest = false,
    this.updateError,
    this.updateSuccessMessage,
  });

  Authenticated copyWith({
    UserEntity? user,
    bool? isGuest,
    String? updateError,
    String? updateSuccessMessage,
  }) {
    return Authenticated(
      user ?? this.user,
      isGuest: isGuest ?? this.isGuest,
      updateError: updateError,
      updateSuccessMessage: updateSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [user, isGuest, updateError, updateSuccessMessage];
}

/// Chưa xác thực hoặc đã đăng xuất an toàn
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Trạng thái gửi yêu cầu đặt lại mật khẩu thành công
class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Phát sinh lỗi trong các tác vụ đăng nhập/đăng ký/quên mật khẩu chính
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}