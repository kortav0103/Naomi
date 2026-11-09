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
    email: 'reader@naomi.app',
    displayName: 'Alex Mercer',
    isGuest: false,
    createdAt: DateTime(2026, 11, 6),
  );

  static final tGuest = UserEntity(
    id: 'guest_default',
    email: '',
    displayName: 'Guest Reader',
    isGuest: true,
    createdAt: DateTime(2026, 11, 6),
  );

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (shouldFail) return const Left(CacheFailure('Not logged in'));
    return Right(tUser);
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) return const Left(AuthFailure('Incorrect email or password.'));
    return Right(tUser);
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (shouldFail) return const Left(AuthFailure('Email already exists.'));
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
  }) async {
    return Right(tUser.copyWith(displayName: displayName));
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    if (shouldFail) return const Left(AuthFailure('Account not found with this email.'));
    return const Right(null);
  }
}

void main() {
  group('AuthBloc Unit Tests', () {
    test('Initial state of AuthBloc should be AuthInitial', () {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());
      expect(bloc.state, equals(const AuthInitial()));
      bloc.close();
    });

    test('Emits [Authenticated] on CheckAuthEvent when user exists', () async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());

      expectLater(
        bloc.stream,
        emitsInOrder([
          Authenticated(FakeAuthRepository.tUser, isGuest: false),
        ]),
      );

      bloc.add(const CheckAuthEvent());
    });

    test('Emits [AuthLoading, Authenticated] on successful login', () async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());

      expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          Authenticated(FakeAuthRepository.tUser, isGuest: false),
        ]),
      );

      bloc.add(const LoginSubmittedEvent(email: 'reader@naomi.app', password: 'password123'));
    });

    test('Emits [AuthLoading, Authenticated(isGuest: true)] on continue as guest', () async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());

      expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          Authenticated(FakeAuthRepository.tGuest, isGuest: true),
        ]),
      );

      bloc.add(const GuestLoginEvent());
    });

    test('Emits [AuthLoading, PasswordResetSuccess] on successful password reset', () async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());

      expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          isA<PasswordResetSuccess>(),
        ]),
      );

      bloc.add(const ResetPasswordSubmittedEvent('reader@naomi.app'));
    });

    test('Emits [AuthLoading, Unauthenticated] on logout', () async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());

      expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const Unauthenticated(),
        ]),
      );

      bloc.add(const LogoutEvent());
    });
  });
}
