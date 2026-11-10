import 'package:flutter_test/flutter_test.dart';
import 'package:naomi/core/audio/ambient_audio_service.dart';
import 'package:naomi/core/audio/spotify/models/spotify_playlist.dart';
import 'package:naomi/core/audio/spotify/models/spotify_track.dart';
import 'package:naomi/core/audio/spotify/models/spotify_user_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpotifyTrack Model Tests', () {
    test('should parse correctly from Spotify Web API track JSON map', () {
      final map = {
        'id': 'track_123',
        'name': 'Ghibli Chillhop Beat',
        'artists': [
          {'name': 'Kato'},
          {'name': 'Lofi Beats'},
        ],
        'album': {
          'name': 'Spirited Vibes',
          'images': [
            {'url': 'https://image.spotify.com/album123.jpg'},
          ],
        },
        'uri': 'spotify:track:track_123',
        'external_urls': {
          'spotify': 'https://open.spotify.com/track/track_123',
        },
        'duration_ms': 184000,
        'preview_url': 'https://p.scdn.co/mp3-preview/123',
      };

      final track = SpotifyTrack.fromMap(map);

      expect(track.id, 'track_123');
      expect(track.name, 'Ghibli Chillhop Beat');
      expect(track.artists, ['Kato', 'Lofi Beats']);
      expect(track.artistNames, 'Kato, Lofi Beats');
      expect(track.albumName, 'Spirited Vibes');
      expect(track.albumArtUrl, 'https://image.spotify.com/album123.jpg');
      expect(track.uri, 'spotify:track:track_123');
      expect(track.externalUrl, 'https://open.spotify.com/track/track_123');
      expect(track.durationMs, 184000);
      expect(track.formattedDuration, '3:04');
    });

    test('should handle fallback for empty artists and images', () {
      final map = {
        'id': 'empty_track',
        'name': 'Solo Track',
      };

      final track = SpotifyTrack.fromMap(map);

      expect(track.id, 'empty_track');
      expect(track.name, 'Solo Track');
      expect(track.artistNames, 'Unknown Artist');
      expect(track.albumArtUrl, isNull);
      expect(track.formattedDuration, '--:--');
    });
  });

  group('SpotifyPlaylist Model Tests', () {
    test('should provide curated reading playlists with sample tracks', () {
      final playlists = SpotifyPlaylist.curatedReadingPlaylists;

      expect(playlists, isNotEmpty);
      expect(playlists.first.name, 'Anime Lofi Chill');
      expect(playlists.first.sampleTracks, isNotEmpty);
      expect(playlists.first.uri.startsWith('spotify:playlist:'), isTrue);
    });

    test('should parse correctly from playlist JSON map', () {
      final map = {
        'id': 'pl_456',
        'name': 'Tokyo Study Beats',
        'description': 'Calm lofi for reading',
        'images': [
          {'url': 'https://image.spotify.com/pl456.jpg'},
        ],
        'uri': 'spotify:playlist:pl_456',
        'tracks': {'total': 42},
      };

      final playlist = SpotifyPlaylist.fromMap(map);

      expect(playlist.id, 'pl_456');
      expect(playlist.name, 'Tokyo Study Beats');
      expect(playlist.description, 'Calm lofi for reading');
      expect(playlist.imageUrl, 'https://image.spotify.com/pl456.jpg');
      expect(playlist.totalTracks, 42);
    });
  });

  group('SpotifyUserProfile Model Tests', () {
    test('should identify premium status correctly', () {
      final premiumMap = {
        'id': 'user_premium',
        'display_name': 'Otaku Reader',
        'email': 'reader@manga.com',
        'product': 'premium',
      };

      final freeMap = {
        'id': 'user_free',
        'display_name': 'Free Listener',
        'product': 'free',
      };

      final premiumUser = SpotifyUserProfile.fromMap(premiumMap);
      final freeUser = SpotifyUserProfile.fromMap(freeMap);

      expect(premiumUser.isPremium, isTrue);
      expect(freeUser.isPremium, isFalse);
    });

    test('should provide valid demo user', () {
      final demo = SpotifyUserProfile.demoUser;
      expect(demo.displayName, contains('Demo'));
      expect(demo.isPremium, isTrue);
    });
  });

  group('AmbientAudioService Integration Tests', () {
    test('should default to offline mode and switch to spotify mode cleanly', () {
      final service = AmbientAudioService();

      expect(service.currentMode, AudioSourceMode.offline);

      service.switchMode(AudioSourceMode.spotify);
      expect(service.currentMode, AudioSourceMode.spotify);

      service.switchMode(AudioSourceMode.offline);
      expect(service.currentMode, AudioSourceMode.offline);
    });

    test('playSpotifyTrack should activate Spotify mode and set track metadata', () async {
      final service = AmbientAudioService();

      const track = SpotifyTrack(
        id: 'track_test',
        name: 'Suzume Nostalgia',
        artists: ['Mondo Loops'],
        albumName: 'Anime Chill',
        uri: 'spotify:track:track_test',
      );

      await service.playSpotifyTrack(track);

      expect(service.currentMode, AudioSourceMode.spotify);
      expect(service.currentTrackTitle, 'Suzume Nostalgia');
      expect(service.currentTrackSubtitle, 'Mondo Loops');
      expect(service.isMiniPlayerVisible.value, isTrue);
      expect(service.isPlaying, isTrue);

      await service.pause();
      expect(service.isPlaying, isFalse);
    });
  });
}
