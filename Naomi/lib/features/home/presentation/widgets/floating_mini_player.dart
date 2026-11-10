import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/audio/ambient_audio_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../reader/presentation/widgets/ambient_audio_sheet.dart';

class FloatingMiniPlayer extends StatelessWidget {
  const FloatingMiniPlayer({super.key});

  static const Color spotifyGreen = Color(0xFF1DB954);

  @override
  Widget build(BuildContext context) {
    final audioService = sl<AmbientAudioService>();

    return ValueListenableBuilder<bool>(
      valueListenable: audioService.isMiniPlayerVisible,
      builder: (context, isVisible, _) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }

        return ListenableBuilder(
          listenable: Listenable.merge([
            audioService.modeNotifier,
            audioService.spotifyTrackNotifier,
            audioService.isSpotifyPlayingNotifier,
          ]),
          builder: (context, _) {
            return StreamBuilder<PlayerState>(
              stream: audioService.playerStateStream,
              builder: (context, snapshot) {
                final isSpotify = audioService.currentMode == AudioSourceMode.spotify;
                final isPlaying = audioService.isPlaying;
                final artworkUrl = audioService.currentArtworkUrl;
                final primaryColor = isSpotify ? spotifyGreen : AppColors.primary;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: context.isDarkMode ? 0.4 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const AmbientAudioSheet(),
                      );
                    },
                    child: Row(
                      children: [
                        // Ảnh thumbnail album hoặc icon nhạc
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: artworkUrl != null && artworkUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: artworkUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => _buildPlaceholderIcon(isPlaying, primaryColor, context),
                                  errorWidget: (context, url, error) => _buildPlaceholderIcon(isPlaying, primaryColor, context),
                                )
                              : _buildPlaceholderIcon(isPlaying, primaryColor, context),
                        ),
                        const SizedBox(width: 12),

                        // Thông tin bài hát & chế độ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                audioService.currentTrackTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (isSpotify) ...[
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: spotifyGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(
                                    child: Text(
                                      audioService.currentTrackSubtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSpotify ? spotifyGreen : AppColors.primaryLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Nút Next (Hữu ích khi nghe Spotify hoặc chuyển bài offline)
                        IconButton(
                          tooltip: 'Next Track',
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: context.textPrimary,
                            size: 22,
                          ),
                          onPressed: () => audioService.next(),
                        ),

                        // Nút Play / Pause
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                            color: primaryColor,
                            size: 34,
                          ),
                          onPressed: () => audioService.togglePlayPause(),
                        ),

                        // Nút Đóng hẳn mini player
                        IconButton(
                          tooltip: 'Stop & Close',
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.close_rounded, color: context.textMuted, size: 20),
                          onPressed: () => audioService.stopAndDismiss(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholderIcon(bool isPlaying, Color primaryColor, BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isPlaying ? primaryColor : context.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isPlaying ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
        color: isPlaying ? Colors.white : primaryColor,
        size: 20,
      ),
    );
  }
}
