/// Các ngoại lệ phát sinh ở tầng Data Layer
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Lỗi máy chủ MangaDex']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Lỗi truy xuất cơ sở dữ liệu cục bộ']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Mất kết nối mạng Internet']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Lỗi xác thực người dùng']);
}