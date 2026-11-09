/// Các ngoại lệ phát sinh ở tầng Data Layer
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'MangaDex server error']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Local database access error']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'User authentication error']);
}

/// Tài khoản đã được tạo nhưng cần xác nhận email trước khi đăng nhập
class EmailConfirmationRequiredException extends AuthException {
  const EmailConfirmationRequiredException([
    super.message = 'Account created! Please check your inbox to confirm your email, then sign in.',
  ]);
}
