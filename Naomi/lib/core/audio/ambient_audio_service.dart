import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'spotify/models/spotify_playlist.dart';
import 'spotify/models/spotify_track.dart';
import 'spotify/spotify_api_client.dart';
import 'spotify/spotify_auth_service.dart';

/// Chế độ phát âm thanh nền
enum AudioSourceMode {
  /// Nhạc Lofi không lời nhúng sẵn trong ứng dụng (Offline, miễn phí, độc lập)
  offline,

  /// Nhạc trực tuyến qua Spotify (Kho nhạc phong phú, hỗ trợ tài khoản Spotify cá nhân)
  spotify,
}

/// Dịch vụ quản lý phát nhạc nền hợp nhất (Unified Ambient Audio Service)
/// Hỗ trợ chuyển đổi liền mạch giữa Offline Lo-fi và Spotify Music khi đọc truyện.
class AmbientAudioService {
  final AudioPlayer _player = AudioPlayer();
  final SpotifyApiClient? spotifyClient;
  final SpotifyAuthService? spotifyAuthService;

  // Trạng thái nguồn phát hiện tại
  final ValueNotifier<AudioSourceMode> modeNotifier = ValueNotifier<AudioSourceMode>(AudioSourceMode.offline);
  AudioSourceMode get currentMode => modeNotifier.value;

  // Trạng thái bài hát Offline
  String _currentOfflineTrackTitle = 'Sakura Girl - Flowers';

  // Trạng thái bài hát Spotify
  final ValueNotifier<SpotifyTrack?> spotifyTrackNotifier = ValueNotifier<SpotifyTrack?>(null);
  final ValueNotifier<bool> isSpotifyPlayingNotifier = ValueNotifier<bool>(false);
  SpotifyTrack? get currentSpotifyTrack => spotifyTrackNotifier.value;

  // Hiển thị thanh Floating Mini Player
  final ValueNotifier<bool> isMiniPlayerVisible = ValueNotifier<bool>(false);

  // Âm lượng chung (0.0 đến 1.0)
  double _volume = 0.5;
  double get volume => _volume;

  /// Danh mục các bản nhạc không lời offline nhúng sẵn trong ứng dụng
  static final List<Map<String, String>> defaultTracks = [
    {
      'title': 'Sakura Girl - Flowers',
      'asset': 'assets/audio/sakura_flowers.mp3',
    },
    {
      'title': 'Sakura Girl - Sweet Note',
      'asset': 'assets/audio/sakura_sweet_note.mp3',
    },
  ];

  AudioPlayer get player => _player;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Tên bài hát đang phát (Tự động lấy theo chế độ hiện tại)
  String get currentTrackTitle {
    if (currentMode == AudioSourceMode.spotify) {
      return spotifyTrackNotifier.value?.name ?? 'Spotify Music';
    }
    return _currentOfflineTrackTitle;
  }

  /// Tên phụ / Tên nghệ sĩ
  String get currentTrackSubtitle {
    if (currentMode == AudioSourceMode.spotify) {
      return spotifyTrackNotifier.value?.artistNames ?? 'Spotify Ambient';
    }
    return 'Offline Lo-Fi Soundtrack';
  }

  /// Ảnh bìa bài hát (nếu có từ Spotify)
  String? get currentArtworkUrl {
    if (currentMode == AudioSourceMode.spotify) {
      return spotifyTrackNotifier.value?.albumArtUrl;
    }
    return null;
  }

  /// Kiểm tra có đang phát nhạc hay không (cả Local và Spotify)
  bool get isPlaying {
    if (currentMode == AudioSourceMode.spotify) {
      return isSpotifyPlayingNotifier.value;
    }
    return _player.playing;
  }

  AmbientAudioService({
    this.spotifyClient,
    this.spotifyAuthService,
  }) {
    _initAudioSession();

    // Khởi tạo bài hát mẫu cho Spotify nếu có
    if (SpotifyPlaylist.curatedReadingPlaylists.isNotEmpty &&
        SpotifyPlaylist.curatedReadingPlaylists.first.sampleTracks.isNotEmpty) {
      spotifyTrackNotifier.value = SpotifyPlaylist.curatedReadingPlaylists.first.sampleTracks.first;
    }
  }

  /// Cấu hình AudioSession đảm bảo tạm dừng khi có cuộc gọi hoặc rút tai nghe
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      session.becomingNoisyEventStream.listen((_) {
        pause();
      });
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          pause();
        }
      });
    } catch (_) {
      // Bỏ qua trên môi trường kiểm thử không có AudioSession phần cứng
    }
  }

  /// Chuyển đổi giữa chế độ Offline Lo-Fi và Spotify
  void switchMode(AudioSourceMode newMode) {
    if (modeNotifier.value == newMode) return;

    if (newMode == AudioSourceMode.spotify) {
      // Dừng nhạc offline nếu đang phát
      _player.pause();
    } else {
      // Dừng nhạc Spotify nếu đang phát
      isSpotifyPlayingNotifier.value = false;
      spotifyClient?.pause();
    }

    modeNotifier.value = newMode;
  }

  /// Phát bản nhạc theo Asset nội bộ (Offline Lo-Fi)
  Future<void> playTrack({
    required String asset,
    required String title,
  }) async {
    try {
      if (currentMode != AudioSourceMode.offline) {
        modeNotifier.value = AudioSourceMode.offline;
        isSpotifyPlayingNotifier.value = false;
        spotifyClient?.pause();
      }

      _currentOfflineTrackTitle = title;
      isMiniPlayerVisible.value = true;
      if (asset.startsWith('assets/')) {
        await _player.setAsset(asset);
      } else {
        await _player.setUrl(asset);
      }
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(_volume);
      await _player.play();
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  /// Phát một bài hát từ Spotify
  Future<void> playSpotifyTrack(SpotifyTrack track, {String? contextUri}) async {
    try {
      if (currentMode != AudioSourceMode.spotify) {
        modeNotifier.value = AudioSourceMode.spotify;
        await _player.pause();
      }

      spotifyTrackNotifier.value = track;
      isSpotifyPlayingNotifier.value = true;
      isMiniPlayerVisible.value = true;

      final client = spotifyClient;
      if (client != null) {
        await client.play(
          contextUri: contextUri,
          trackUri: track.uri,
        );
      }
    } catch (e) {
      debugPrint('playSpotifyTrack error: $e');
    }
  }

  /// Phát một Playlist từ Spotify
  Future<void> playSpotifyPlaylist(SpotifyPlaylist playlist) async {
    try {
      if (currentMode != AudioSourceMode.spotify) {
        modeNotifier.value = AudioSourceMode.spotify;
        await _player.pause();
      }

      isMiniPlayerVisible.value = true;
      isSpotifyPlayingNotifier.value = true;

      if (playlist.sampleTracks.isNotEmpty) {
        spotifyTrackNotifier.value = playlist.sampleTracks.first;
      }

      final client = spotifyClient;
      if (client != null) {
        await client.play(contextUri: playlist.uri);
      }
    } catch (e) {
      debugPrint('playSpotifyPlaylist error: $e');
    }
  }

  /// Tạm dừng nhạc hiện tại (tùy thuộc theo chế độ đang chạy)
  Future<void> pause() async {
    try {
      if (currentMode == AudioSourceMode.spotify) {
        isSpotifyPlayingNotifier.value = false;
        await spotifyClient?.pause();
      } else {
        await _player.pause();
      }
    } catch (_) {}
  }

  /// Tiếp tục phát
  Future<void> resume() async {
    try {
      isMiniPlayerVisible.value = true;
      if (currentMode == AudioSourceMode.spotify) {
        isSpotifyPlayingNotifier.value = true;
        await spotifyClient?.resume();
      } else {
        // Nếu chưa nạp bản nhạc offline nào, tự động nạp bài đầu tiên
        if (_player.audioSource == null && defaultTracks.isNotEmpty) {
          final first = defaultTracks.first;
          await playTrack(asset: first['asset']!, title: first['title']!);
          return;
        }
        await _player.play();
      }
    } catch (_) {}
  }

  /// Đảo trạng thái Play / Pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Chuyển bài kế tiếp
  Future<void> next() async {
    if (currentMode == AudioSourceMode.spotify) {
      await spotifyClient?.next();
      // Nếu có sample tracks trong curated playlist, nhảy sang track kế tiếp
      final current = spotifyTrackNotifier.value;
      final samples = SpotifyPlaylist.curatedReadingPlaylists.expand((p) => p.sampleTracks).toList();
      if (current != null && samples.isNotEmpty) {
        final idx = samples.indexWhere((t) => t.id == current.id);
        if (idx >= 0 && idx + 1 < samples.length) {
          spotifyTrackNotifier.value = samples[idx + 1];
        } else if (samples.isNotEmpty) {
          spotifyTrackNotifier.value = samples.first;
        }
      }
    } else {
      // Chuyển sang bài offline kế tiếp
      final currentIndex = defaultTracks.indexWhere((t) => t['title'] == _currentOfflineTrackTitle);
      final nextIndex = (currentIndex + 1) % defaultTracks.length;
      final nextTrack = defaultTracks[nextIndex];
      await playTrack(asset: nextTrack['asset']!, title: nextTrack['title']!);
    }
  }

  /// Quay lại bài trước
  Future<void> previous() async {
    if (currentMode == AudioSourceMode.spotify) {
      await spotifyClient?.previous();
      final current = spotifyTrackNotifier.value;
      final samples = SpotifyPlaylist.curatedReadingPlaylists.expand((p) => p.sampleTracks).toList();
      if (current != null && samples.isNotEmpty) {
        final idx = samples.indexWhere((t) => t.id == current.id);
        if (idx > 0) {
          spotifyTrackNotifier.value = samples[idx - 1];
        } else if (samples.isNotEmpty) {
          spotifyTrackNotifier.value = samples.last;
        }
      }
    } else {
      final currentIndex = defaultTracks.indexWhere((t) => t['title'] == _currentOfflineTrackTitle);
      final prevIndex = (currentIndex - 1 + defaultTracks.length) % defaultTracks.length;
      final prevTrack = defaultTracks[prevIndex];
      await playTrack(asset: prevTrack['asset']!, title: prevTrack['title']!);
    }
  }

  /// Dừng hẳn nhạc và đóng thanh Mini Player
  Future<void> stopAndDismiss() async {
    isMiniPlayerVisible.value = false;
    try {
      if (currentMode == AudioSourceMode.spotify) {
        isSpotifyPlayingNotifier.value = false;
        await spotifyClient?.pause();
      } else {
        await _player.stop();
      }
    } catch (_) {}
  }

  /// Đổi âm lượng (0.0 đến 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume);
      final client = spotifyClient;
      if (currentMode == AudioSourceMode.spotify && client != null) {
        await client.setVolume((_volume * 100).round());
      }
    } catch (_) {}
  }

  /// Giải phóng tài nguyên
  void dispose() {
    isMiniPlayerVisible.dispose();
    modeNotifier.dispose();
    spotifyTrackNotifier.dispose();
    isSpotifyPlayingNotifier.dispose();
    _player.dispose();
  }
}
