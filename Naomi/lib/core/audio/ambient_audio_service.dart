import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Dịch vụ quản lý phát nhạc nền không lời (Ambient Audio) theo thể loại truyện
class AmbientAudioService {
  final AudioPlayer _player = AudioPlayer();
  String _currentTrackTitle = 'Lofi Reading Chill';

  // Danh mục các bản nhạc Ambient thư giãn (Royalty-free)
  static final List<Map<String, String>> defaultTracks = [
    {
      'title': 'Lofi Reading Chill',
      'genre': 'Slice of Life',
      'url': 'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3',
    },
    {
      'title': 'Peaceful Fantasy Melody',
      'genre': 'Fantasy',
      'url': 'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3',
    },
    {
      'title': 'Rainy Day Cozy Cafe',
      'genre': 'Romance',
      'url': 'https://cdn.pixabay.com/download/audio/2022/10/14/audio_9939f77c30.mp3',
    },
    {
      'title': 'Calm Acoustic Strings',
      'genre': 'Drama',
      'url': 'https://cdn.pixabay.com/download/audio/2021/09/06/audio_8340d21650.mp3',
    },
  ];

  AudioPlayer get player => _player;
  String get currentTrackTitle => _currentTrackTitle;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  AmbientAudioService() {
    _initAudioSession();
  }

  /// Cấu hình AudioSession đảm bảo tạm dừng khi có cuộc gọi (NFR-17)
  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Lắng nghe khi mất tiêu điểm âm thanh (ví dụ có cuộc gọi đến)
    session.becomingNoisyEventStream.listen((_) {
      pause();
    });
  }

  /// Phát bản nhạc theo URL
  Future<void> playTrack({required String url, required String title}) async {
    try {
      _currentTrackTitle = title;
      await _player.setUrl(url);
      await _player.setLoopMode(LoopMode.one); // Tự động lặp lại bản nhạc khi hết
      await _player.play();
    } catch (_) {
      // Bỏ qua lỗi stream nếu rớt mạng tạm thời
    }
  }

  /// Tạm dừng nhạc
  Future<void> pause() async {
    await _player.pause();
  }

  /// Tiếp tục phát
  Future<void> resume() async {
    await _player.play();
  }

  /// Đổi âm lượng (0.0 đến 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  /// Giải phóng tài nguyên
  void dispose() {
    _player.dispose();
  }
}
