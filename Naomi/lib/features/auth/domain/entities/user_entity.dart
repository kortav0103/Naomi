import 'package:equatable/equatable.dart';

/// Thực thể Người dùng chuẩn thương mại (FR-00 & NFR-05)
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool isGuest;
  final bool isEmailVerified;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.isGuest,
    this.isEmailVerified = false,
    required this.createdAt,
  });

  /// Factory khởi tạo nhanh đối tượng Khách vãng lai chuẩn hóa
  factory UserEntity.guest() {
    return UserEntity(
      id: 'guest_default',
      email: '',
      displayName: 'Guest Reader',
      avatarUrl: null,
      isGuest: true,
      isEmailVerified: false,
      createdAt: DateTime.now(),
    );
  }

  /// Tạo một bản sao mới với các trường được cập nhật
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isGuest,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        isGuest,
        isEmailVerified,
        createdAt,
      ];
}