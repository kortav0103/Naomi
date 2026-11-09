import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> saveCurrentUser(UserModel user);
  Future<void> clearSession();

  /// Đăng nhập ngoại tuyến bằng tài khoản demo (chỉ khả dụng ở Debug build)
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> createGuestSession();

  /// Cập nhật hồ sơ cục bộ cho phiên Khách / phiên ngoại tuyến
  Future<UserModel> updateProfile({required String displayName});
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  /// Cho phép bật/tắt tài khoản demo (mặc định: chỉ bật khi chạy Debug build)
  final bool enableDemoAccount;

  static const String _keyCurrentUser = 'naomi_current_user';

  // Tài khoản mẫu mặc định phục vụ kiểm thử / demo (chỉ hoạt động ở Debug build)
  static const String demoEmail = 'reader@naomi.app';
  static const String demoPassword = 'naomi123456';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    this.enableDemoAccount = kDebugMode,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userStr = await secureStorage.read(key: _keyCurrentUser);
      if (userStr != null && userStr.isNotEmpty) {
        return UserModel.fromJsonString(userStr);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    try {
      await secureStorage.write(
        key: _keyCurrentUser,
        value: user.toJsonString(),
      );
    } catch (e) {
      throw CacheException('Unable to save login session: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await secureStorage.delete(key: _keyCurrentUser);
    } catch (e) {
      throw CacheException('Unable to clear login session: $e');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!enableDemoAccount || normalizedEmail != demoEmail) {
      throw const AuthException('Account is not registered in the system!');
    }
    if (password != demoPassword) {
      throw const AuthException('Incorrect demo account password!');
    }

    final defaultUser = UserModel(
      id: 'user_default_reader',
      email: demoEmail,
      displayName: 'Naomi Reader',
      isGuest: false,
      isEmailVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    await saveCurrentUser(defaultUser);
    return defaultUser;
  }

  @override
  Future<UserModel> createGuestSession() async {
    try {
      final existingUser = await getCurrentUser();
      if (existingUser != null && existingUser.isGuest) {
        return existingUser;
      }

      // Đồng bộ ID 'guest_default' với cấu trúc DatabaseHelper SQLite
      final guestUser = UserModel(
        id: 'guest_default',
        email: '',
        displayName: 'Guest Reader',
        isGuest: true,
        isEmailVerified: false,
        createdAt: DateTime.now(),
      );

      await saveCurrentUser(guestUser);
      return guestUser;
    } catch (e) {
      throw AuthException('Error creating Guest session: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({required String displayName}) async {
    final current = await getCurrentUser();
    if (current == null) {
      throw const AuthException('Active login session not found');
    }
    if (displayName.trim().isEmpty) {
      throw const AuthException('Display name cannot be empty');
    }

    final updated = UserModel(
      id: current.id,
      email: current.email,
      displayName: displayName.trim(),
      avatarUrl: current.avatarUrl,
      isGuest: current.isGuest,
      isEmailVerified: current.isEmailVerified,
      createdAt: current.createdAt,
    );

    try {
      await saveCurrentUser(updated);
    } on CacheException catch (e) {
      throw AuthException(e.message);
    }
    return updated;
  }
}
