import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Dịch vụ quản lý phát nhạc nền không lời (Ambient Audio) theo thể loại truyện (FR-05, FR-09, NFR-17)
class AmbientAudioService {
  final AudioPlayer _player = AudioPlayer();
  String _currentTrackTitle = 'Lofi Reading Chill';
  String _currentTrackGenre = 'Slice of Life';
  final ValueNotifier<bool> isMiniPlayerVisible = ValueNotifier<bool>(false);

  // Danh mục các bản nhạc Ambient thư giãn (Royalty-free) ánh xạ theo thể loại truyện
  static final List<Map<String, String>> defaultTracks = [
    {
      'title': 'Lofi Reading Chill',
      'genre': 'Slice of Life',
      'keywords': 'slice of life,comedy,school life,iyashikei',
      'url': 'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3',
    },
    {
      'title': 'Peaceful Fantasy Melody',
      'genre': 'Fantasy',
      'keywords': 'fantasy,adventure,isekai,magic,supernatural',
      'url': 'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3',
    },
    {
      'title': 'Rainy Day Cozy Cafe',
      'genre': 'Romance',
      'keywords': 'romance,shoujo,josei,slice of life',
      'url': 'https://cdn.pixabay.com/download/audio/2022/10/14/audio_9939f77c30.mp3',
    },
    {
      'title': 'Calm Acoustic Strings',
      'genre': 'Drama',
      'keywords': 'drama,tragedy,historical,psychological,mystery',
      'url': 'https://cdn.pixabay.com/download/audio/2021/09/06/audio_8340d21650.mp3',
    },
    {
      'title': 'Cyberpunk Night Drive',
      'genre': 'Action / Sci-Fi',
      'keywords': 'action,sci-fi,mecha,martial arts,thriller,sports',
      'url': 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3',
    },
  ];

  AudioPlayer get player => _player;
  String get currentTrackTitle => _currentTrackTitle;
  String get currentTrackGenre => _currentTrackGenre;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  AmbientAudioService() {
    _initAudioSession();
  }

  /// Tự động đề xuất bản nhạc phù hợp nhất dựa trên danh sách thể loại của bộ truyện (FR-05)
  Map<String, String> recommendTrackForGenres(List<String> comicGenres) {
    if (comicGenres.isEmpty) return defaultTracks.first;

    final normalizedGenres = comicGenres.map((g) => g.toLowerCase()).toList();
    for (final track in defaultTracks) {
      final keywords = (track['keywords'] ?? '').split(',');
      for (final g in normalizedGenres) {
        if (keywords.any((k) => g.contains(k.trim()) || k.trim().contains(g))) {
          return track;
        }
      }
    }
    return defaultTracks.first;
  }

  /// Cấu hình AudioSession đảm bảo tạm dừng khi có cuộc gọi (NFR-17)
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Lắng nghe khi mất tiêu điểm âm thanh (ví dụ có cuộc gọi đến hoặc rút tai nghe)
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

  /// Phát bản nhạc theo URL
  Future<void> playTrack({
    required String url,
    required String title,
    String genre = 'Ambient',
  }) async {
    try {
      _currentTrackTitle = title;
      _currentTrackGenre = genre;
      isMiniPlayerVisible.value = true;
      await _player.setUrl(url);
      await _player.setLoopMode(LoopMode.one); // Tự động lặp lại bản nhạc khi hết
      await _player.play();
    } catch (_) {
      // Bỏ qua lỗi stream nếu rớt mạng tạm thời
    }
  }

  /// Tạm dừng nhạc
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  /// Tiếp tục phát
  Future<void> resume() async {
    try {
      isMiniPlayerVisible.value = true;
      await _player.play();
    } catch (_) {}
  }

  /// Dừng hẳn nhạc và đóng thanh Mini Player (Sửa lỗi nút X không đóng được)
  Future<void> stopAndDismiss() async {
    isMiniPlayerVisible.value = false;
    try {
      await _player.stop();
    } catch (_) {}
  }

  /// Đổi âm lượng (0.0 đến 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  /// Giải phóng tài nguyên
  void dispose() {
    isMiniPlayerVisible.dispose();
    _player.dispose();
  }
}
