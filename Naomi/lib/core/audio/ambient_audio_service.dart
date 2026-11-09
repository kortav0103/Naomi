import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Dịch vụ quản lý phát nhạc nền không lời nội bộ (Offline Ambient Audio)
class AmbientAudioService {
  final AudioPlayer _player = AudioPlayer();
  String _currentTrackTitle = 'Sakura Girl - Flowers';
  final ValueNotifier<bool> isMiniPlayerVisible = ValueNotifier<bool>(false);

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
  String get currentTrackTitle => _currentTrackTitle;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  AmbientAudioService() {
    _initAudioSession();
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

  /// Phát bản nhạc theo Asset nội bộ
  Future<void> playTrack({
    required String asset,
    required String title,
  }) async {
    try {
      _currentTrackTitle = title;
      isMiniPlayerVisible.value = true;
      if (asset.startsWith('assets/')) {
        await _player.setAsset(asset);
      } else {
        await _player.setUrl(asset);
      }
      await _player.setLoopMode(LoopMode.one); // Tự động lặp lại bản nhạc khi hết
      await _player.play();
    } catch (e) {
      debugPrint('Audio playback error: $e');
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

  /// Dừng hẳn nhạc và đóng thanh Mini Player
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
