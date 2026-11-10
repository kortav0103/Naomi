/// Model đại diện cho một bài hát từ Spotify
class SpotifyTrack {
  final String id;
  final String name;
  final List<String> artists;
  final String albumName;
  final String? albumArtUrl;
  final String uri;
  final String? externalUrl;
  final int durationMs;
  final String? previewUrl;

  const SpotifyTrack({
    required this.id,
    required this.name,
    required this.artists,
    required this.albumName,
    this.albumArtUrl,
    required this.uri,
    this.externalUrl,
    this.durationMs = 0,
    this.previewUrl,
  });

  /// Chuỗi hiển thị toàn bộ tên nghệ sĩ nối nhau bằng dấu phẩy
  String get artistNames => artists.isEmpty ? 'Unknown Artist' : artists.join(', ');

  /// Định dạng thời lượng bài hát mm:ss
  String get formattedDuration {
    if (durationMs <= 0) return '--:--';
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Khởi tạo đối tượng từ JSON của Spotify Web API
  factory SpotifyTrack.fromMap(Map<String, dynamic> map) {
    // Trích xuất danh sách nghệ sĩ
    final artistsList = <String>[];
    if (map['artists'] is List) {
      for (final a in map['artists']) {
        if (a is Map && a['name'] != null) {
          artistsList.add(a['name'].toString());
        }
      }
    }

    // Trích xuất ảnh bìa album
    String? artUrl;
    if (map['album'] is Map && map['album']['images'] is List) {
      final images = map['album']['images'] as List;
      if (images.isNotEmpty && images.first is Map) {
        artUrl = images.first['url']?.toString();
      }
    }

    // Trích xuất URL nghe trên Spotify
    String? extUrl;
    if (map['external_urls'] is Map) {
      extUrl = map['external_urls']['spotify']?.toString();
    }

    final id = map['id']?.toString() ?? '';
    return SpotifyTrack(
      id: id,
      name: map['name']?.toString() ?? 'Unknown Track',
      artists: artistsList.isNotEmpty ? artistsList : ['Unknown Artist'],
      albumName: map['album'] is Map ? (map['album']['name']?.toString() ?? '') : '',
      albumArtUrl: artUrl,
      uri: map['uri']?.toString() ?? 'spotify:track:$id',
      externalUrl: extUrl,
      durationMs: map['duration_ms'] is int ? map['duration_ms'] as int : 0,
      previewUrl: map['preview_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'artists': artists.map((a) => {'name': a}).toList(),
      'album': {
        'name': albumName,
        'images': albumArtUrl != null ? [{'url': albumArtUrl}] : [],
      },
      'uri': uri,
      'external_urls': externalUrl != null ? {'spotify': externalUrl} : {},
      'duration_ms': durationMs,
      'preview_url': previewUrl,
    };
  }
}
