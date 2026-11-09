import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/audio/ambient_audio_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../reader/presentation/widgets/ambient_audio_sheet.dart';

class FloatingMiniPlayer extends StatelessWidget {
  const FloatingMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = sl<AmbientAudioService>();

    return ValueListenableBuilder<bool>(
      valueListenable: audioService.isMiniPlayerVisible,
      builder: (context, isVisible, _) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<PlayerState>(
          stream: audioService.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final isPlaying = playerState?.playing ?? false;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDarkMode ? 0.4 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
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
                    // Icon nhạc nền nhấp nháy khi đang phát
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isPlaying ? AppColors.primary : context.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPlaying ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                        color: isPlaying ? Colors.white : AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tên bản nhạc
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
                          const Text(
                            'Relaxing Ambient Audio',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nút Play / Pause
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          audioService.pause();
                        } else {
                          audioService.resume();
                        }
                      },
                    ),
                    // Nút Đóng hẳn mini player
                    IconButton(
                      tooltip: 'Stop & Close',
                      icon: Icon(Icons.close_rounded, color: context.textMuted, size: 20),
                      onPressed: () {
                        audioService.stopAndDismiss();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
