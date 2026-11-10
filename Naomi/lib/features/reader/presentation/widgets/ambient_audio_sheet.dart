import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/audio/ambient_audio_service.dart';
import '../../../../core/audio/spotify/models/spotify_playlist.dart';
import '../../../../core/audio/spotify/models/spotify_track.dart';
import '../../../../core/audio/spotify/models/spotify_user_profile.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';

/// BottomSheet điều khiển nhạc nền không lời (Offline Lo-Fi & Spotify Music)
class AmbientAudioSheet extends StatefulWidget {
  const AmbientAudioSheet({super.key});

  @override
  State<AmbientAudioSheet> createState() => _AmbientAudioSheetState();
}

class _AmbientAudioSheetState extends State<AmbientAudioSheet> {
  final AmbientAudioService _audioService = sl<AmbientAudioService>();
  static const Color spotifyGreen = Color(0xFF1DB954);

  late int _selectedTab; // 0: Offline, 1: Spotify
  double _volume = 0.5;

  final TextEditingController _searchController = TextEditingController();
  List<SpotifyTrack> _searchResults = [];
  bool _isSearching = false;
  SpotifyPlaylist? _selectedPlaylist;

  @override
  void initState() {
    super.initState();
    _selectedTab = _audioService.currentMode == AudioSourceMode.spotify ? 1 : 0;
    _volume = _audioService.volume;
    _selectedPlaylist = SpotifyPlaylist.curatedReadingPlaylists.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final client = _audioService.spotifyClient;
    if (client != null) {
      final results = await client.searchTracks(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } else {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo nhỏ
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header: Chuyển đổi giữa Offline Lo-Fi và Spotify
          Row(
            children: [
              const Icon(Icons.music_note_rounded, color: AppColors.primaryLight, size: 22),
              const SizedBox(width: 8),
              Text(
                'AMBIENT AUDIO',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              // Segmented Switch
              Container(
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.borderColor),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _buildTabButton(
                      index: 0,
                      label: 'Lo-Fi',
                      icon: Icons.headphones_rounded,
                      activeColor: AppColors.primary,
                    ),
                    _buildTabButton(
                      index: 1,
                      label: 'Spotify',
                      icon: Icons.graphic_eq_rounded,
                      activeColor: spotifyGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nội dung theo Tab đã chọn
          Flexible(
            child: _selectedTab == 0 ? _buildOfflineView() : _buildSpotifyView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() => _selectedTab = index);
        _audioService.switchMode(index == 0 ? AudioSourceMode.offline : AudioSourceMode.spotify);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : context.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: OFFLINE LO-FI
  // ==========================================
  Widget _buildOfflineView() {
    final tracks = AmbientAudioService.defaultTracks;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player controller
          StreamBuilder<PlayerState>(
            stream: _audioService.playerStateStream,
            builder: (context, snapshot) {
              final isPlaying = _audioService.isPlaying && _audioService.currentMode == AudioSourceMode.offline;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          onPressed: () {
                            if (isPlaying) {
                              _audioService.pause();
                            } else {
                              if (_audioService.player.audioSource == null) {
                                final first = tracks.first;
                                _audioService.playTrack(asset: first['asset']!, title: first['title']!);
                              } else {
                                _audioService.resume();
                              }
                            }
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _audioService.currentTrackTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                isPlaying ? 'Playing offline soundtrack...' : 'Tap Play to start listening',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: context.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildVolumeSlider(AppColors.primary),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          Text(
            'OFFLINE SOUNDTRACKS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: context.textMuted,
            ),
          ),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tracks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final track = tracks[index];
              final isCurrent = _audioService.currentMode == AudioSourceMode.offline &&
                  _audioService.currentTrackTitle == track['title'];

              return ListTile(
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isCurrent ? AppColors.primary : Colors.transparent,
                  ),
                ),
                tileColor: isCurrent ? AppColors.primary.withValues(alpha: 0.15) : context.backgroundColor,
                leading: Icon(
                  isCurrent ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                  color: isCurrent ? AppColors.primaryLight : context.textMuted,
                  size: 18,
                ),
                title: Text(
                  track['title']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? AppColors.primaryLight : context.textPrimary,
                  ),
                ),
                trailing: isCurrent
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                        ),
                      )
                    : null,
                onTap: () {
                  _audioService.playTrack(
                    asset: track['asset']!,
                    title: track['title']!,
                  );
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: SPOTIFY MUSIC
  // ==========================================
  Widget _buildSpotifyView() {
    final authService = _audioService.spotifyAuthService;

    return ValueListenableBuilder<SpotifyUserProfile?>(
      valueListenable: authService?.userProfileNotifier ?? ValueNotifier(null),
      builder: (context, profile, _) {
        final isConnected = profile != null;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Khung trạng thái tài khoản Spotify
              _buildSpotifyAccountBanner(isConnected, profile),
              const SizedBox(height: 12),

              // 2. Khung điều khiển Player Spotify
              _buildSpotifyPlayerCard(),
              const SizedBox(height: 16),

              // 3. Thanh tìm kiếm bài hát trên Spotify
              _buildSpotifySearchBar(),
              const SizedBox(height: 12),

              // Kết quả tìm kiếm (nếu có)
              if (_isSearching)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: spotifyGreen, strokeWidth: 2),
                  ),
                )
              else if (_searchResults.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 14, color: spotifyGreen),
                    const SizedBox(width: 4),
                    Text(
                      'SEARCH RESULTS (${_searchResults.length})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildTracksList(_searchResults),
                const SizedBox(height: 16),
              ],

              // 4. Danh sách Curated Playlists
              Text(
                'CURATED READING PLAYLISTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: context.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              _buildCuratedPlaylistsRow(),
              const SizedBox(height: 12),

              // 5. Danh sách bài hát trong Playlist đang chọn
              if (_selectedPlaylist != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedPlaylist!.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: spotifyGreen,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _audioService.spotifyClient?.openInSpotify(_selectedPlaylist!.uri);
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Open Playlist',
                            style: TextStyle(fontSize: 11, color: spotifyGreen, fontWeight: FontWeight.w600),
                          ),
                          Icon(Icons.arrow_outward_rounded, size: 13, color: spotifyGreen),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildTracksList(_selectedPlaylist!.sampleTracks, contextUri: _selectedPlaylist!.uri),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpotifyAccountBanner(bool isConnected, SpotifyUserProfile? profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: spotifyGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: spotifyGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: spotifyGreen,
            backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
            child: profile?.avatarUrl == null
                ? const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isConnected ? profile!.displayName : 'Spotify Connect',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    if (isConnected && profile!.isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: spotifyGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  isConnected
                      ? 'Connected to Spotify API'
                      : 'Connect your Spotify account to listen while reading',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: spotifyGreen,
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {
              if (isConnected) {
                _audioService.spotifyAuthService?.disconnect();
              } else {
                _showConnectSpotifyDialog();
              }
            },
            child: Text(
              isConnected ? 'Disconnect' : 'Connect',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotifyPlayerCard() {
    return ValueListenableBuilder<SpotifyTrack?>(
      valueListenable: _audioService.spotifyTrackNotifier,
      builder: (context, track, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _audioService.isSpotifyPlayingNotifier,
          builder: (context, isPlaying, _) {
            final hasTrack = track != null;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: spotifyGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: track?.albumArtUrl != null
                            ? CachedNetworkImage(
                                imageUrl: track!.albumArtUrl!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => _buildAlbumFallback(),
                              )
                            : _buildAlbumFallback(),
                      ),
                      const SizedBox(width: 12),
                      // Tên bài & nghệ sĩ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasTrack ? track.name : 'No track selected',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              hasTrack ? track.artistNames : 'Select a track or playlist below',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      // Controls: Prev / Play / Next
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.skip_previous_rounded, size: 20),
                        onPressed: () => _audioService.previous(),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: spotifyGreen,
                          foregroundColor: Colors.black,
                        ),
                        icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        onPressed: () {
                          if (hasTrack) {
                            if (isPlaying) {
                              _audioService.pause();
                            } else {
                              _audioService.playSpotifyTrack(track);
                            }
                          } else if (SpotifyPlaylist.curatedReadingPlaylists.isNotEmpty) {
                            _audioService.playSpotifyPlaylist(SpotifyPlaylist.curatedReadingPlaylists.first);
                          }
                        },
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.skip_next_rounded, size: 20),
                        onPressed: () => _audioService.next(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildVolumeSlider(spotifyGreen),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumFallback() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: spotifyGreen.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note_rounded, color: spotifyGreen, size: 22),
    );
  }

  Widget _buildVolumeSlider(Color activeColor) {
    return Row(
      children: [
        Icon(Icons.volume_mute_rounded, size: 16, color: context.textMuted),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: context.borderColor,
              thumbColor: activeColor,
              trackHeight: 2,
            ),
            child: Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              onChanged: (val) {
                setState(() => _volume = val);
                _audioService.setVolume(val);
              },
            ),
          ),
        ),
        Icon(Icons.volume_up_rounded, size: 16, color: context.textMuted),
      ],
    );
  }

  Widget _buildSpotifySearchBar() {
    return TextField(
      controller: _searchController,
      onSubmitted: _onSearch,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 13, color: context.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search anime OST, lofi, or artist...',
        hintStyle: TextStyle(fontSize: 12, color: context.textMuted),
        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: spotifyGreen),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 16),
                onPressed: () {
                  _searchController.clear();
                  _onSearch('');
                },
              )
            : null,
        filled: true,
        fillColor: context.backgroundColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: spotifyGreen),
        ),
      ),
    );
  }

  Widget _buildCuratedPlaylistsRow() {
    final playlists = SpotifyPlaylist.curatedReadingPlaylists;

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = playlists[index];
          final isSelected = _selectedPlaylist?.id == p.id;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() => _selectedPlaylist = p);
            },
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? spotifyGreen.withValues(alpha: 0.15) : context.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? spotifyGreen : context.borderColor,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? spotifyGreen : context.textPrimary,
                    ),
                  ),
                  Text(
                    p.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: context.textMuted),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${p.totalTracks} tracks',
                        style: TextStyle(fontSize: 9, color: context.textSecondary),
                      ),
                      const Icon(Icons.play_circle_outline_rounded, size: 14, color: spotifyGreen),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTracksList(List<SpotifyTrack> tracks, {String? contextUri}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isCurrent = _audioService.currentMode == AudioSourceMode.spotify &&
            _audioService.currentSpotifyTrack?.id == track.id;

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isCurrent ? spotifyGreen : Colors.transparent,
            ),
          ),
          tileColor: isCurrent ? spotifyGreen.withValues(alpha: 0.15) : context.backgroundColor,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: track.albumArtUrl != null
                ? CachedNetworkImage(
                    imageUrl: track.albumArtUrl!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _buildTrackLeadingIcon(isCurrent),
                  )
                : _buildTrackLeadingIcon(isCurrent),
          ),
          title: Text(
            track.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent ? spotifyGreen : context.textPrimary,
            ),
          ),
          subtitle: Text(
            track.artistNames,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: context.textSecondary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track.formattedDuration,
                style: TextStyle(fontSize: 10, color: context.textMuted),
              ),
              const SizedBox(width: 6),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isCurrent && _audioService.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isCurrent ? spotifyGreen : context.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  _audioService.playSpotifyTrack(track, contextUri: contextUri);
                },
              ),
            ],
          ),
          onTap: () {
            _audioService.playSpotifyTrack(track, contextUri: contextUri);
          },
        );
      },
    );
  }

  Widget _buildTrackLeadingIcon(bool isCurrent) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isCurrent ? spotifyGreen.withValues(alpha: 0.2) : context.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        isCurrent ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
        color: isCurrent ? spotifyGreen : context.textMuted,
        size: 16,
      ),
    );
  }

  // ==========================================
  // DIALOG KẾT NỐI SPOTIFY
  // ==========================================
  void _showConnectSpotifyDialog() {
    final tokenController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: ctx.surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: spotifyGreen,
                      child: Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CONNECT TO SPOTIFY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: ctx.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose a method to connect Spotify to Naomi for background music:',
                  style: TextStyle(fontSize: 12, color: ctx.textSecondary),
                ),
                const SizedBox(height: 16),

                // Nút 1: Demo / Quick Explore (1-click)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: spotifyGreen,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: const Text(
                    'Quick Connect (Explore Curated Tracks)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _audioService.spotifyAuthService?.connectDemo();
                  },
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: Divider(color: ctx.borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OR USE YOUR OWN TOKEN', style: TextStyle(fontSize: 10, color: ctx.textMuted)),
                    ),
                    Expanded(child: Divider(color: ctx.borderColor)),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: tokenController,
                  style: TextStyle(fontSize: 12, color: ctx.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Spotify Access Token',
                    hintText: 'Paste token from Spotify Developer Console...',
                    hintStyle: TextStyle(fontSize: 11, color: ctx.textMuted),
                    filled: true,
                    fillColor: ctx.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    _audioService.spotifyClient?.openInSpotify('https://developer.spotify.com/dashboard');
                  },
                  child: const Text(
                    'Get token from Spotify Developer Dashboard ↗',
                    style: TextStyle(fontSize: 11, color: spotifyGreen, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: spotifyGreen,
                    side: const BorderSide(color: spotifyGreen),
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Connect with Token', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    final token = tokenController.text.trim();
                    if (token.isEmpty) return;
                    Navigator.pop(ctx);
                    final success = await _audioService.spotifyAuthService?.connectWithAccessToken(token);
                    if (!mounted) return;
                    if (!(success ?? false)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to authenticate token with Spotify API')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
