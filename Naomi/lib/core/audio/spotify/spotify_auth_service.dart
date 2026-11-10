import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/spotify_user_profile.dart';

/// Dịch vụ quản lý xác thực và lưu trữ phiên đăng nhập Spotify
class SpotifyAuthService {
  final FlutterSecureStorage secureStorage;
  final Dio _dio;

  static const String _keyAccessToken = 'spotify_access_token';
  static const String _keyRefreshToken = 'spotify_refresh_token';
  static const String _keyClientId = 'spotify_client_id';
  static const String _keyUserProfile = 'spotify_user_profile_json';
  static const String _keyIsDemo = 'spotify_is_demo_mode';

  final ValueNotifier<SpotifyUserProfile?> userProfileNotifier = ValueNotifier<SpotifyUserProfile?>(null);

  bool get isConnected => userProfileNotifier.value != null;
  SpotifyUserProfile? get currentUser => userProfileNotifier.value;

  SpotifyAuthService({
    required this.secureStorage,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// Khôi phục trạng thái đăng nhập đã lưu trong SecureStorage khi mở ứng dụng
  Future<void> init() async {
    try {
      final isDemo = await secureStorage.read(key: _keyIsDemo);
      if (isDemo == 'true') {
        userProfileNotifier.value = SpotifyUserProfile.demoUser;
        return;
      }

      final profileJson = await secureStorage.read(key: _keyUserProfile);
      final token = await secureStorage.read(key: _keyAccessToken);

      if (token != null && profileJson != null) {
        final decoded = jsonDecode(profileJson) as Map<String, dynamic>;
        userProfileNotifier.value = SpotifyUserProfile.fromMap(decoded);
      }
    } catch (e) {
      debugPrint('SpotifyAuthService init error: $e');
    }
  }

  /// Lấy Access Token hiện tại
  Future<String?> getAccessToken() async {
    try {
      final isDemo = await secureStorage.read(key: _keyIsDemo);
      if (isDemo == 'true') {
        return 'demo_token';
      }
      return await secureStorage.read(key: _keyAccessToken);
    } catch (_) {
      if (userProfileNotifier.value == SpotifyUserProfile.demoUser) {
        return 'demo_token';
      }
      return null;
    }
  }

  /// Kết nối tài khoản Spotify bằng Access Token do người dùng hoặc OAuth cấp
  Future<bool> connectWithAccessToken(
    String token, {
    String? refreshToken,
    String? clientId,
  }) async {
    try {
      final cleanToken = token.trim();
      if (cleanToken.isEmpty) return false;

      // Xác minh token với Spotify Web API
      final response = await _dio.get(
        'https://api.spotify.com/v1/me',
        options: Options(
          headers: {'Authorization': 'Bearer $cleanToken'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final profile = SpotifyUserProfile.fromMap(response.data as Map<String, dynamic>);

        // Lưu thông tin an toàn
        try {
          await secureStorage.write(key: _keyAccessToken, value: cleanToken);
          if (refreshToken != null) {
            await secureStorage.write(key: _keyRefreshToken, value: refreshToken);
          }
          if (clientId != null) {
            await secureStorage.write(key: _keyClientId, value: clientId);
          }
          await secureStorage.write(key: _keyUserProfile, value: jsonEncode(response.data));
          await secureStorage.delete(key: _keyIsDemo);
        } catch (_) {}

        userProfileNotifier.value = profile;
        return true;
      } else {
        debugPrint('Spotify auth failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Spotify connect error: $e');
      return false;
    }
  }

  /// Bật chế độ Demo / Quick Connect (Cho phép trải nghiệm ngay giao diện & playlist mà chưa cần tạo app Developer)
  Future<void> connectDemo() async {
    try {
      await secureStorage.write(key: _keyIsDemo, value: 'true');
      await secureStorage.delete(key: _keyAccessToken);
    } catch (_) {}
    userProfileNotifier.value = SpotifyUserProfile.demoUser;
  }

  /// Đăng xuất và ngắt kết nối Spotify khỏi Naomi
  Future<void> disconnect() async {
    try {
      await secureStorage.delete(key: _keyAccessToken);
      await secureStorage.delete(key: _keyRefreshToken);
      await secureStorage.delete(key: _keyClientId);
      await secureStorage.delete(key: _keyUserProfile);
      await secureStorage.delete(key: _keyIsDemo);
    } catch (_) {}
    userProfileNotifier.value = null;
  }

  void dispose() {
    userProfileNotifier.dispose();
  }
}
