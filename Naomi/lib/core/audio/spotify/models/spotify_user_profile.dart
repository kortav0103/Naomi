/// Model đại diện cho thông tin tài khoản người dùng Spotify
class SpotifyUserProfile {
  final String id;
  final String displayName;
  final String? email;
  final String product; // 'premium', 'free', 'open'
  final String? avatarUrl;
  final String? country;

  const SpotifyUserProfile({
    required this.id,
    required this.displayName,
    this.email,
    this.product = 'premium',
    this.avatarUrl,
    this.country,
  });

  bool get isPremium => product.toLowerCase() == 'premium';

  factory SpotifyUserProfile.fromMap(Map<String, dynamic> map) {
    String? avatar;
    if (map['images'] is List) {
      final images = map['images'] as List;
      if (images.isNotEmpty && images.first is Map) {
        avatar = images.first['url']?.toString();
      }
    }

    return SpotifyUserProfile(
      id: map['id']?.toString() ?? '',
      displayName: map['display_name']?.toString() ?? 'Spotify Reader',
      email: map['email']?.toString(),
      product: map['product']?.toString() ?? 'free',
      avatarUrl: avatar,
      country: map['country']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'product': product,
      'avatarUrl': avatarUrl,
      'country': country,
    };
  }

  /// Tài khoản mẫu dùng cho chế độ Demo / Quick Explore
  static const SpotifyUserProfile demoUser = SpotifyUserProfile(
    id: 'naomi_demo_user',
    displayName: 'Naomi Reader (Demo)',
    email: 'reader@naomi.app',
    product: 'premium',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    country: 'VN',
  );
}
