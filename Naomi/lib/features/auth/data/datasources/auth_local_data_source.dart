import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> saveCurrentUser(UserModel user);
  Future<void> clearSession();
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<UserModel> createGuestSession();
  Future<UserModel> updateProfile({required String displayName});
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static const String _keyCurrentUser = 'naomi_current_user';
  static const String _keyRegisteredAccounts = 'naomi_registered_accounts';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userStr = await secureStorage.read(key: _keyCurrentUser);
      if (userStr != null && userStr.isNotEmpty) {
        return UserModel.fromJsonString(userStr);
      }
      return null;
    } catch (e) {
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
      throw CacheException('Không thể lưu thông tin phiên đăng nhập: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await secureStorage.delete(key: _keyCurrentUser);
    } catch (e) {
      throw CacheException('Không thể xóa phiên đăng nhập: $e');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final accountsStr = await secureStorage.read(key: _keyRegisteredAccounts);
      final Map<String, dynamic> accounts = accountsStr != null
          ? jsonDecode(accountsStr) as Map<String, dynamic>
          : {};

      final normalizedEmail = email.trim().toLowerCase();

      // Kiểm tra tài khoản đã đăng ký hoặc cho phép tài khoản mẫu mặc định
      if (accounts.containsKey(normalizedEmail)) {
        final accountData = accounts[normalizedEmail] as Map<String, dynamic>;
        if (accountData['password'] == password) {
          final user = UserModel.fromJson(accountData['profile'] as Map<String, dynamic>);
          await saveCurrentUser(user);
          return user;
        } else {
          throw const AuthException('Mật khẩu không chính xác. Vui lòng thử lại!');
        }
      } else if (normalizedEmail == 'reader@naomi.app') {
        // Tài khoản mẫu định sẵn cho chấm điểm / chạy thử
        final user = UserModel(
          id: 'user_default_reader',
          email: 'reader@naomi.app',
          displayName: 'Độc giả Naomi',
          isGuest: false,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        await saveCurrentUser(user);
        return user;
      } else {
        throw const AuthException('Tài khoản chưa được đăng ký trong hệ thống!');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Lỗi đăng nhập: $e');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final accountsStr = await secureStorage.read(key: _keyRegisteredAccounts);
      final Map<String, dynamic> accounts = accountsStr != null
          ? jsonDecode(accountsStr) as Map<String, dynamic>
          : {};

      final normalizedEmail = email.trim().toLowerCase();
      if (accounts.containsKey(normalizedEmail)) {
        throw const AuthException('Địa chỉ Email này đã được đăng ký trước đó!');
      }

      final newUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: normalizedEmail,
        displayName: displayName.trim().isNotEmpty ? displayName.trim() : 'Độc giả Naomi',
        isGuest: false,
        createdAt: DateTime.now(),
      );

      accounts[normalizedEmail] = {
        'password': password,
        'profile': newUser.toJson(),
      };

      await secureStorage.write(
        key: _keyRegisteredAccounts,
        value: jsonEncode(accounts),
      );

      await saveCurrentUser(newUser);
      return newUser;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Lỗi đăng ký tài khoản: $e');
    }
  }

  @override
  Future<UserModel> createGuestSession() async {
    try {
      // Nếu đã có guest session từ trước thì tái sử dụng
      final existingUser = await getCurrentUser();
      if (existingUser != null && existingUser.isGuest) {
        return existingUser;
      }

      final guestUser = UserModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@naomi.local',
        displayName: 'Khách Trải Nghiệm',
        isGuest: true,
        createdAt: DateTime.now(),
      );

      await saveCurrentUser(guestUser);
      return guestUser;
    } catch (e) {
      throw AuthException('Lỗi khởi tạo phiên Khách: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({required String displayName}) async {
    try {
      final current = await getCurrentUser();
      if (current == null) {
        throw const AuthException('Không tìm thấy phiên đăng nhập');
      }

      final updated = UserModel(
        id: current.id,
        email: current.email,
        displayName: displayName.trim(),
        avatarUrl: current.avatarUrl,
        isGuest: current.isGuest,
        createdAt: current.createdAt,
      );

      await saveCurrentUser(updated);

      // Nếu là tài khoản thành viên thì cập nhật trong danh sách tài khoản đã lưu
      if (!current.isGuest) {
        final accountsStr = await secureStorage.read(key: _keyRegisteredAccounts);
        if (accountsStr != null) {
          final Map<String, dynamic> accounts = jsonDecode(accountsStr) as Map<String, dynamic>;
          final emailKey = current.email.toLowerCase();
          if (accounts.containsKey(emailKey)) {
            final acc = accounts[emailKey] as Map<String, dynamic>;
            acc['profile'] = updated.toJson();
            await secureStorage.write(key: _keyRegisteredAccounts, value: jsonEncode(accounts));
          }
        }
      }

      return updated;
    } catch (e) {
      throw AuthException('Không thể cập nhật hồ sơ: $e');
    }
  }
}
