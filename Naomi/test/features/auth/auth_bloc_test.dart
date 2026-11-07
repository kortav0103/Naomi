import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naomi/core/errors/failures.dart';
import 'package:naomi/features/auth/domain/entities/user_entity.dart';
import 'package:naomi/features/auth/domain/repositories/auth_repository.dart';
import 'package:naomi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naomi/features/auth/presentation/bloc/auth_event.dart';
import 'package:naomi/features/auth/presentation/bloc/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  final bool shouldFail;

  FakeAuthRepository({this.shouldFail = false});

  static final tUser = UserEntity(
    id: 'user-001',
    email: 'kiet@hcmut.edu.vn',
    displayName: 'Nguyễn Tuấn Kiệt',
    isGuest: false,
    createdAt: DateTime(2026, 11, 6),
  );

  static final tGuest = UserEntity(
    id: 'guest_user',
    email: 'guest@naomi.local',
    displayName: 'Độc giả Khách',
    isGuest: true,
    createdAt: DateTime(2026, 11, 6),
  );

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (shouldFail) return const Left(CacheFailure('Chưa đăng nhập'));
    return Right(tUser);
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) return const Left(CacheFailure('Email hoặc mật khẩu không chính xác.'));
    return Right(tUser);
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (shouldFail) return const Left(CacheFailure('Email đã tồn tại.'));
    return Right(tUser.copyWith(email: email, displayName: displayName));
  }

  @override
  Future<Either<Failure, UserEntity>> continueAsGuest() async {
    return Right(tGuest);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    return Right(tUser.copyWith(displayName: displayName));
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    if (shouldFail) return const Left(CacheFailure('Không tìm thấy tài khoản với email này.'));
    return const Right(null);
  }
}

void main() {
  group('AuthBloc Unit Tests (US-00 / FR-00)', () {
    test('Trạng thái khởi tạo của AuthBloc phải là AuthInitial', () {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());
      expect(bloc.state, equals(const AuthInitial()));
      bloc.close();
    });

    test('Phát ra [AuthLoading, Authenticated] khi đăng nhập thành công', () async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());

      expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          Authenticated(FakeAuthRepository.tUser),
        ]),
      );

      bloc.add(const LoginSubmittedEvent(email: 'kiet@hcmut.edu.vn', password: 'password123'));
    });

    test('Phát ra [AuthLoading, Authenticated(isGuest: true)] khi chọn Chế độ Khách', () async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());

      expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          Authenticated(FakeAuthRepository.tGuest),
        ]),
      );

      bloc.add(const GuestLoginEvent());
    });

    test('Phát ra [AuthLoading, PasswordResetSuccess] khi khôi phục mật khẩu thành công', () async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());

      expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          isA<PasswordResetSuccess>(),
        ]),
      );

      bloc.add(const ResetPasswordSubmittedEvent(
        email: 'kiet@hcmut.edu.vn',
        newPassword: 'newPassword123',
      ));
    });
  });
}
