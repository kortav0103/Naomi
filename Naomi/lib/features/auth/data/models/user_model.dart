import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    required super.isGuest,
    super.isEmailVerified = false,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? 'user_guest',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Naomi Reader',
      avatarUrl: json['avatarUrl'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isGuest': isGuest,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String str) =>
      UserModel.fromJson(jsonDecode(str) as Map<String, dynamic>);

  factory UserModel.fromSupabaseUser(User user, {String? fallbackDisplayName}) {
    final meta = user.userMetadata ?? {};
    final displayName = meta['display_name'] as String? ??
        meta['full_name'] as String? ??
        fallbackDisplayName ??
        (user.email != null && user.email!.isNotEmpty ? user.email!.split('@').first : 'Naomi Reader');

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: displayName,
      avatarUrl: meta['avatar_url'] as String?,
      isGuest: false,
      isEmailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      isGuest: entity.isGuest,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
    );
  }
}
