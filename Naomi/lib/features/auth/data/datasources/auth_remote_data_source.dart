import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> logout();
  Future<UserModel> updateProfile({required String displayName, String? avatarUrl});
  Future<void> resetPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final sp.SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      } else {
        throw const AuthException('Login failed: No user information received from server.');
      }
    } on sp.AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        throw const AuthException('Invalid email or password. Please try again!');
      } else if (msg.contains('email not confirmed')) {
        throw const AuthException(
            'Account created on Supabase but email is not confirmed yet. (Tip: Disable "Confirm email" in Supabase Dashboard -> Auth -> Providers -> Email to sign in immediately).');
      }
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Supabase Cloud connection error: $e');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'display_name': displayName.trim(),
        },
      );

      final user = response.user;
      if (user != null) {
        // Kiểm tra nếu email đã đăng ký
        if (user.identities != null && user.identities!.isEmpty) {
          throw const AuthException('This email address is already registered!');
        }
        // Supabase bật "Confirm email": tài khoản đã tạo nhưng chưa có phiên đăng nhập hợp lệ
        if (response.session == null) {
          throw const EmailConfirmationRequiredException();
        }
        return UserModel.fromSupabaseUser(user, fallbackDisplayName: displayName);
      } else {
        throw const AuthException('Sign up failed. Please check your information.');
      }
    } on sp.AuthException catch (e) {
      if (e.message.toLowerCase().contains('user already registered')) {
        throw const AuthException('This email address is already registered!');
      } else if (e.message.toLowerCase().contains('password should be at least')) {
        throw const AuthException('Password must be at least 6 characters long.');
      }
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Supabase Cloud sign up error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {}
  }

  @override
  Future<UserModel> updateProfile({required String displayName, String? avatarUrl}) async {
    try {
      final data = <String, dynamic>{'display_name': displayName.trim()};
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await supabase.auth.updateUser(
        sp.UserAttributes(data: data),
      );

      final user = response.user;
      if (user != null) {
        return UserModel.fromSupabaseUser(user, fallbackDisplayName: displayName);
      }
      throw const AuthException('Unable to update user profile.');
    } on sp.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Profile update error: $e');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email.trim());
    } on sp.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error sending password reset email: $e');
    }
  }
}
