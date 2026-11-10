import 'spotify_track.dart';

/// Model đại diện cho danh sách phát (Playlist) từ Spotify
class SpotifyPlaylist {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String uri;
  final String? externalUrl;
  final int totalTracks;
  final List<SpotifyTrack> sampleTracks;

  const SpotifyPlaylist({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl,
    required this.uri,
    this.externalUrl,
    this.totalTracks = 0,
    this.sampleTracks = const [],
  });

  factory SpotifyPlaylist.fromMap(Map<String, dynamic> map) {
    String? img;
    if (map['images'] is List) {
      final images = map['images'] as List;
      if (images.isNotEmpty && images.first is Map) {
        img = images.first['url']?.toString();
      }
    }

    String? extUrl;
    if (map['external_urls'] is Map) {
      extUrl = map['external_urls']['spotify']?.toString();
    }

    int tracksCount = 0;
    if (map['tracks'] is Map && map['tracks']['total'] is int) {
      tracksCount = map['tracks']['total'] as int;
    }

    final id = map['id']?.toString() ?? '';
    return SpotifyPlaylist(
      id: id,
      name: map['name']?.toString() ?? 'Spotify Playlist',
      description: map['description']?.toString() ?? '',
      imageUrl: img,
      uri: map['uri']?.toString() ?? 'spotify:playlist:$id',
      externalUrl: extUrl,
      totalTracks: tracksCount,
    );
  }

  /// Danh sách các Playlist tuyển chọn đặc biệt phù hợp khi đọc Manga / Light Novel
  static const List<SpotifyPlaylist> curatedReadingPlaylists = [
    SpotifyPlaylist(
      id: '37i9dQZF1DXc8kgYqQLMfH',
      name: 'Anime Lofi Chill',
      description: 'Nostalgic anime instrumental beats for reading and relaxing.',
      imageUrl: 'https://i.scdn.co/image/ab67706f00000003b6e80b2a752e50529944dc6a',
      uri: 'spotify:playlist:37i9dQZF1DXc8kgYqQLMfH',
      externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXc8kgYqQLMfH',
      totalTracks: 50,
      sampleTracks: [
        SpotifyTrack(
          id: 'sample_1',
          name: 'A Town with an Ocean View (Lofi)',
          artists: ['Kato', 'Ghibli Chill'],
          albumName: 'Anime Chillhop Vol. 1',
          uri: 'spotify:track:sample_1',
          durationMs: 142000,
        ),
        SpotifyTrack(
          id: 'sample_2',
          name: 'Spirited Away Theme (Lofi Remix)',
          artists: ['Kalaido'],
          albumName: 'Spirited Lofi',
          uri: 'spotify:track:sample_2',
          durationMs: 168000,
        ),
        SpotifyTrack(
          id: 'sample_3',
          name: 'Suzume Nostalgia',
          artists: ['Mondo Loops', 'Kanisan'],
          albumName: 'Suzume Instrumental',
          uri: 'spotify:track:sample_3',
          durationMs: 155000,
        ),
      ],
    ),
    SpotifyPlaylist(
      id: '37i9dQZF1DX8Uebhn9wzrS',
      name: 'Manga Reading Beats',
      description: 'Mellow chillhop beats crafted to boost focus during long manga sessions.',
      imageUrl: 'https://i.scdn.co/image/ab67706f00000003ca2207a90962057393d25816',
      uri: 'spotify:playlist:37i9dQZF1DX8Uebhn9wzrS',
      totalTracks: 60,
      externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX8Uebhn9wzrS',
      sampleTracks: [
        SpotifyTrack(
          id: 'sample_4',
          name: 'Midnight Study Session',
          artists: ['Lofi Fruits Music', 'Chill Select'],
          albumName: 'Focus Beats',
          uri: 'spotify:track:sample_4',
          durationMs: 135000,
        ),
        SpotifyTrack(
          id: 'sample_5',
          name: 'Rainy Day in Akihabara',
          artists: ['Kupla', 'Jinsang'],
          albumName: 'Tokyo Memories',
          uri: 'spotify:track:sample_5',
          durationMs: 178000,
        ),
      ],
    ),
    SpotifyPlaylist(
      id: '37i9dQZF1DXdLEN7aqioXM',
      name: 'Tokyo Rain & Coffee',
      description: 'Soothing rain ambient sounds and mellow vinyl chillhop from Shibuya.',
      imageUrl: 'https://i.scdn.co/image/ab67706f00000003b879a6176313ff78f3078a63',
      uri: 'spotify:playlist:37i9dQZF1DXdLEN7aqioXM',
      totalTracks: 45,
      externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXdLEN7aqioXM',
      sampleTracks: [
        SpotifyTrack(
          id: 'sample_6',
          name: 'Coffee Shop in Shibuya',
          artists: ['Saib', 'Idealism'],
          albumName: 'Tokyo Rain Cafe',
          uri: 'spotify:track:sample_6',
          durationMs: 154000,
        ),
        SpotifyTrack(
          id: 'sample_7',
          name: 'Under the Umbrella',
          artists: ['Sarcastic Sounds'],
          albumName: 'Rainy Moments',
          uri: 'spotify:track:sample_7',
          durationMs: 148000,
        ),
      ],
    ),
    SpotifyPlaylist(
      id: '37i9dQZF1DX7K31D69s4M1',
      name: 'Ghibli Piano & Chill',
      description: 'Peaceful piano instrumental covers inspired by classic Studio Ghibli films.',
      imageUrl: 'https://i.scdn.co/image/ab67706f0000000388b0a94fb215a78cff932789',
      uri: 'spotify:playlist:37i9dQZF1DX7K31D69s4M1',
      totalTracks: 40,
      externalUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX7K31D69s4M1',
      sampleTracks: [
        SpotifyTrack(
          id: 'sample_8',
          name: 'One Summer\'s Day (Piano Ver.)',
          artists: ['The Piano Guys', 'Joe Hisaishi Cover'],
          albumName: 'Ghibli Memories',
          uri: 'spotify:track:sample_8',
          durationMs: 185000,
        ),
      ],
    ),
  ];
}
