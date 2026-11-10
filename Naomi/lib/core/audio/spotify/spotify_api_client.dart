import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/spotify_playlist.dart';
import 'models/spotify_track.dart';
import 'spotify_auth_service.dart';

/// Client tương tác trực tiếp với Spotify Web API (REST & Spotify Connect)
class SpotifyApiClient {
  final Dio _dio;
  final SpotifyAuthService authService;

  static const String _baseUrl = 'https://api.spotify.com/v1';

  SpotifyApiClient({
    required this.authService,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// Header ủy quyền Bearer token
  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.getAccessToken();
    if (token != null && token.isNotEmpty && token != 'demo_token') {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  /// Tìm kiếm bài hát trên Spotify theo từ khóa (VD: "Anime lofi", "Manga chill")
  Future<List<SpotifyTrack>> searchTracks(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      final headers = await _getHeaders();
      if (headers.isEmpty) {
        // Fallback demo: Lọc từ danh sách mẫu
        return _searchSampleTracks(cleanQuery);
      }

      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': cleanQuery,
          'type': 'track',
          'limit': 15,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['tracks'] is Map &&
          response.data['tracks']['items'] is List) {
        final items = response.data['tracks']['items'] as List;
        return items
            .whereType<Map<String, dynamic>>()
            .map((item) => SpotifyTrack.fromMap(item))
            .toList();
      }
    } catch (e) {
      debugPrint('SpotifyApiClient searchTracks error: $e');
    }

    return _searchSampleTracks(cleanQuery);
  }

  /// Lấy danh sách bài hát trong một Playlist
  Future<List<SpotifyTrack>> getPlaylistTracks(String playlistId) async {
    try {
      final headers = await _getHeaders();
      if (headers.isEmpty) {
        // Trả về sample tracks từ curated playlists
        for (final p in SpotifyPlaylist.curatedReadingPlaylists) {
          if (p.id == playlistId) return p.sampleTracks;
        }
        return SpotifyPlaylist.curatedReadingPlaylists.first.sampleTracks;
      }

      final response = await _dio.get(
        '$_baseUrl/playlists/$playlistId/tracks',
        queryParameters: {'limit': 20},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data is Map && response.data['items'] is List) {
        final items = response.data['items'] as List;
        final tracks = <SpotifyTrack>[];
        for (final item in items) {
          if (item is Map && item['track'] is Map) {
            tracks.add(SpotifyTrack.fromMap(item['track'] as Map<String, dynamic>));
          }
        }
        return tracks;
      }
    } catch (e) {
      debugPrint('SpotifyApiClient getPlaylistTracks error: $e');
    }

    // Fallback nếu không có mạng hoặc token demo
    for (final p in SpotifyPlaylist.curatedReadingPlaylists) {
      if (p.id == playlistId) return p.sampleTracks;
    }
    return SpotifyPlaylist.curatedReadingPlaylists.first.sampleTracks;
  }

  /// Lấy thông tin bài hát đang phát trên Spotify của người dùng
  Future<SpotifyTrack?> getCurrentlyPlaying() async {
    try {
      final headers = await _getHeaders();
      if (headers.isEmpty) return null;

      final response = await _dio.get(
        '$_baseUrl/me/player/currently-playing',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data is Map && response.data['item'] is Map) {
        return SpotifyTrack.fromMap(response.data['item'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('SpotifyApiClient getCurrentlyPlaying error: $e');
    }
    return null;
  }

  /// Điều khiển phát bài hát qua Spotify Connect API hoặc mở ứng dụng Spotify
  Future<bool> play({
    String? contextUri,
    String? trackUri,
    int? positionMs,
  }) async {
    try {
      final headers = await _getHeaders();
      if (headers.isNotEmpty) {
        final body = <String, dynamic>{};
        if (contextUri != null) {
          body['context_uri'] = contextUri;
          if (trackUri != null) {
            body['offset'] = {'uri': trackUri};
          }
        } else if (trackUri != null) {
          body['uris'] = [trackUri];
        }

        if (positionMs != null) {
          body['position_ms'] = positionMs;
        }

        final response = await _dio.put(
          '$_baseUrl/me/player/play',
          data: body.isNotEmpty ? body : null,
          options: Options(headers: headers, validateStatus: (status) => status != null && status < 500),
        );

        if (response.statusCode == 204 || response.statusCode == 200) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('SpotifyApiClient play error: $e');
    }

    // Fallback: Mở trực tiếp bài hát / danh sách phát trong ứng dụng Spotify
    if (trackUri != null) {
      await openInSpotify(trackUri);
      return true;
    } else if (contextUri != null) {
      await openInSpotify(contextUri);
      return true;
    }
    return false;
  }

  /// Tạm dừng phát
  Future<void> pause() async {
    try {
      final headers = await _getHeaders();
      if (headers.isNotEmpty) {
        await _dio.put(
          '$_baseUrl/me/player/pause',
          options: Options(headers: headers, validateStatus: (_) => true),
        );
      }
    } catch (e) {
      debugPrint('SpotifyApiClient pause error: $e');
    }
  }

  /// Tiếp tục phát
  Future<void> resume() async {
    await play();
  }

  /// Chuyển bài kế tiếp
  Future<void> next() async {
    try {
      final headers = await _getHeaders();
      if (headers.isNotEmpty) {
        await _dio.post(
          '$_baseUrl/me/player/next',
          options: Options(headers: headers, validateStatus: (_) => true),
        );
      }
    } catch (e) {
      debugPrint('SpotifyApiClient next error: $e');
    }
  }

  /// Quay lại bài trước
  Future<void> previous() async {
    try {
      final headers = await _getHeaders();
      if (headers.isNotEmpty) {
        await _dio.post(
          '$_baseUrl/me/player/previous',
          options: Options(headers: headers, validateStatus: (_) => true),
        );
      }
    } catch (e) {
      debugPrint('SpotifyApiClient previous error: $e');
    }
  }

  /// Điều chỉnh âm lượng Spotify (0 - 100)
  Future<void> setVolume(int volumePercent) async {
    try {
      final headers = await _getHeaders();
      if (headers.isNotEmpty) {
        await _dio.put(
          '$_baseUrl/me/player/volume',
          queryParameters: {'volume_percent': volumePercent.clamp(0, 100)},
          options: Options(headers: headers, validateStatus: (_) => true),
        );
      }
    } catch (e) {
      debugPrint('SpotifyApiClient setVolume error: $e');
    }
  }

  /// Mở liên kết hoặc URI bài hát trong ứng dụng Spotify hoặc Web Player
  Future<bool> openInSpotify(String uriOrUrl) async {
    try {
      Uri? launchUri;
      if (uriOrUrl.startsWith('spotify:')) {
        launchUri = Uri.parse(uriOrUrl);
      } else if (uriOrUrl.startsWith('http')) {
        launchUri = Uri.parse(uriOrUrl);
      } else {
        launchUri = Uri.parse('spotify:track:$uriOrUrl');
      }

      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback mở phiên bản web
        final webUrl = _convertToWebUrl(uriOrUrl);
        if (webUrl != null) {
          final webUri = Uri.parse(webUrl);
          return await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('SpotifyApiClient openInSpotify error: $e');
    }
    return false;
  }

  String? _convertToWebUrl(String uri) {
    if (uri.startsWith('http')) return uri;
    final parts = uri.split(':');
    if (parts.length >= 3 && parts[0] == 'spotify') {
      return 'https://open.spotify.com/${parts[1]}/${parts[2]}';
    }
    return null;
  }

  List<SpotifyTrack> _searchSampleTracks(String query) {
    final lower = query.toLowerCase();
    final results = <SpotifyTrack>[];
    for (final p in SpotifyPlaylist.curatedReadingPlaylists) {
      for (final t in p.sampleTracks) {
        if (t.name.toLowerCase().contains(lower) ||
            t.artistNames.toLowerCase().contains(lower) ||
            t.albumName.toLowerCase().contains(lower)) {
          if (!results.any((r) => r.id == t.id)) {
            results.add(t);
          }
        }
      }
    }
    // Nếu tìm không thấy trong sample, trả về tất cả sample tracks để người dùng chọn
    if (results.isEmpty) {
      for (final p in SpotifyPlaylist.curatedReadingPlaylists) {
        results.addAll(p.sampleTracks);
      }
    }
    return results;
  }
}
