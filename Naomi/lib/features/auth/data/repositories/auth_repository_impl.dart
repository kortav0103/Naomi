import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Thử xác thực trực tiếp qua máy chủ Supabase Cloud
      final user = await remoteDataSource.login(email: email, password: password);
      await localDataSource.saveCurrentUser(user);
      return Right(user);
    } catch (e) {
      final remoteMessage = e is AuthException ? e.message : e.toString();
      // 2. Dự phòng tài khoản demo (chỉ bật ở Debug build) khi Supabase từ chối / mất kết nối
      try {
        final localUser = await localDataSource.login(email: email, password: password);
        return Right(localUser);
      } catch (_) {
        return Left(AuthFailure(remoteMessage));
      }
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Đăng ký trực tiếp lên Supabase Cloud Auth
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      await localDataSource.saveCurrentUser(user);
      return Right(user);
    } on EmailConfirmationRequiredException catch (e) {
      return Left(EmailConfirmationRequiredFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> continueAsGuest() async {
    try {
      final guest = await localDataSource.createGuestSession();
      return Right(guest);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // 1. Kiểm tra phiên Supabase Cloud hiện hành
      final cloudUser = await remoteDataSource.getCurrentUser();
      if (cloudUser != null) {
        await localDataSource.saveCurrentUser(cloudUser);
        return Right(cloudUser);
      }

      // 2. Kiểm tra phiên đăng nhập lưu cục bộ (ví dụ Guest hoặc Offline)
      final localUser = await localDataSource.getCurrentUser();
      return Right(localUser);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({required String displayName}) async {
    // Phiên Khách hoặc phiên ngoại tuyến (không có session Supabase) → chỉ cập nhật cục bộ
    final hasCloudSession = await remoteDataSource.getCurrentUser() != null;
    if (!hasCloudSession) {
      try {
        final updatedLocal = await localDataSource.updateProfile(displayName: displayName);
        return Right(updatedLocal);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(AuthFailure(e.toString()));
      }
    }

    try {
      final updated = await remoteDataSource.updateProfile(displayName: displayName);
      await localDataSource.saveCurrentUser(updated);
      return Right(updated);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
