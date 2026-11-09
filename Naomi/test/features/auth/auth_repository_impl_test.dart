import 'package:flutter_test/flutter_test.dart';
import 'package:naomi/core/errors/exceptions.dart';
import 'package:naomi/core/errors/failures.dart';
import 'package:naomi/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:naomi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:naomi/features/auth/data/models/user_model.dart';
import 'package:naomi/features/auth/data/repositories/auth_repository_impl.dart';

class FakeRemoteDataSource implements AuthRemoteDataSource {
  UserModel? currentUser;
  bool shouldFailLogin = false;
  bool shouldRequireEmailConfirm = false;
  bool shouldFailUpdate = false;
  String? resetEmailCalledWith;

  static final tRemoteUser = UserModel(
    id: 'remote-123',
    email: 'cloud@naomi.app',
    displayName: 'Cloud User',
    isGuest: false,
    createdAt: DateTime(2026, 1, 1),
  );

  @override
  Future<UserModel?> getCurrentUser() async => currentUser;

  @override
  Future<UserModel> login({required String email, required String password}) async {
    if (shouldFailLogin) {
      throw const AuthException('Invalid login credentials');
    }
    return tRemoteUser;
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (shouldRequireEmailConfirm) {
      throw const EmailConfirmationRequiredException();
    }
    return tRemoteUser;
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }

  @override
  Future<UserModel> updateProfile({required String displayName, String? avatarUrl}) async {
    if (shouldFailUpdate) {
      throw const AuthException('Server error updating profile');
    }
    return UserModel(
      id: tRemoteUser.id,
      email: tRemoteUser.email,
      displayName: displayName,
      isGuest: false,
      createdAt: tRemoteUser.createdAt,
    );
  }

  @override
  Future<void> resetPassword({required String email}) async {
    resetEmailCalledWith = email;
  }
}

class FakeLocalDataSource implements AuthLocalDataSource {
  UserModel? savedUser;
  bool shouldFailDemo = false;

  static final tDemoUser = UserModel(
    id: 'demo-user',
    email: 'reader@naomi.app',
    displayName: 'Naomi Reader',
    isGuest: false,
    createdAt: DateTime(2026, 1, 1),
  );

  static final tGuestUser = UserModel(
    id: 'guest_default',
    email: '',
    displayName: 'Guest Reader',
    isGuest: true,
    createdAt: DateTime(2026, 1, 1),
  );

  @override
  Future<UserModel?> getCurrentUser() async => savedUser;

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    savedUser = user;
  }

  @override
  Future<void> clearSession() async {
    savedUser = null;
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    if (shouldFailDemo) {
      throw const AuthException('Demo login failed');
    }
    return tDemoUser;
  }

  @override
  Future<UserModel> createGuestSession() async {
    savedUser = tGuestUser;
    return tGuestUser;
  }

  @override
  Future<UserModel> updateProfile({required String displayName}) async {
    final updated = UserModel(
      id: savedUser?.id ?? 'guest_default',
      email: savedUser?.email ?? '',
      displayName: displayName,
      isGuest: savedUser?.isGuest ?? true,
      createdAt: savedUser?.createdAt ?? DateTime.now(),
    );
    savedUser = updated;
    return updated;
  }
}

void main() {
  late AuthRepositoryImpl repository;
  late FakeRemoteDataSource fakeRemote;
  late FakeLocalDataSource fakeLocal;

  setUp(() {
    fakeRemote = FakeRemoteDataSource();
    fakeLocal = FakeLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: fakeRemote,
      localDataSource: fakeLocal,
    );
  });

  group('AuthRepositoryImpl Unit Tests', () {
    test('login: returns remote user and saves to local when remote succeeds', () async {
      final result = await repository.login(email: 'cloud@naomi.app', password: 'password123');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (user) {
        expect(user.id, equals('remote-123'));
        expect(fakeLocal.savedUser?.id, equals('remote-123'));
      });
    });

    test('login: falls back to local demo when remote fails and demo succeeds', () async {
      fakeRemote.shouldFailLogin = true;
      fakeLocal.shouldFailDemo = false;

      final result = await repository.login(email: 'reader@naomi.app', password: 'naomi123456');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (user) {
        expect(user.id, equals('demo-user'));
      });
    });

    test('login: returns remote failure when both remote and local fail', () async {
      fakeRemote.shouldFailLogin = true;
      fakeLocal.shouldFailDemo = true;

      final result = await repository.login(email: 'unknown@test.com', password: 'wrong');

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('Invalid login credentials'));
      }, (_) => fail('Expected Left'));
    });

    test('signUp: returns EmailConfirmationRequiredFailure when email confirmation required', () async {
      fakeRemote.shouldRequireEmailConfirm = true;

      final result = await repository.signUp(
        email: 'new@naomi.app',
        password: 'password123',
        displayName: 'New User',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<EmailConfirmationRequiredFailure>());
      }, (_) => fail('Expected Left'));
    });

    test('continueAsGuest: creates guest session locally', () async {
      final result = await repository.continueAsGuest();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (user) {
        expect(user.isGuest, isTrue);
        expect(user.id, equals('guest_default'));
      });
    });

    test('updateProfile: updates locally for guest / offline user when cloud session is null', () async {
      fakeRemote.currentUser = null;
      fakeLocal.savedUser = FakeLocalDataSource.tGuestUser;

      final result = await repository.updateProfile(displayName: 'Updated Guest');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (user) {
        expect(user.displayName, equals('Updated Guest'));
        expect(fakeLocal.savedUser?.displayName, equals('Updated Guest'));
      });
    });

    test('updateProfile: calls remote when cloud session is active', () async {
      fakeRemote.currentUser = FakeRemoteDataSource.tRemoteUser;
      fakeLocal.savedUser = FakeRemoteDataSource.tRemoteUser;

      final result = await repository.updateProfile(displayName: 'New Cloud Name');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (user) {
        expect(user.displayName, equals('New Cloud Name'));
        expect(fakeLocal.savedUser?.displayName, equals('New Cloud Name'));
      });
    });

    test('resetPassword: delegates to remote data source with email', () async {
      final result = await repository.resetPassword(email: 'user@naomi.app');

      expect(result.isRight(), isTrue);
      expect(fakeRemote.resetEmailCalledWith, equals('user@naomi.app'));
    });
  });
}
