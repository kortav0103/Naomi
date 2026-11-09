import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/audio/ambient_audio_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';

/// BottomSheet điều khiển nhạc nền không lời thư giãn
class AmbientAudioSheet extends StatefulWidget {
  const AmbientAudioSheet({super.key});

  @override
  State<AmbientAudioSheet> createState() => _AmbientAudioSheetState();
}

class _AmbientAudioSheetState extends State<AmbientAudioSheet> {
  final AmbientAudioService _audioService = sl<AmbientAudioService>();
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _volume = _audioService.player.volume;
  }

  @override
  Widget build(BuildContext context) {
    final tracks = AmbientAudioService.defaultTracks;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo nhỏ trên đỉnh
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Tiêu đề
          Row(
            children: [
              const Icon(Icons.music_note_rounded, color: AppColors.primaryLight, size: 22),
              const SizedBox(width: 8),
              Text(
                'AMBIENT BACKGROUND AUDIO',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bộ điều khiển Play/Pause & Âm lượng
          StreamBuilder<PlayerState>(
            stream: _audioService.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final isPlaying = playerState?.playing ?? false;

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
                                final firstTrack = tracks.first;
                                _audioService.playTrack(
                                  asset: firstTrack['asset']!,
                                  title: firstTrack['title']!,
                                );
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
                                isPlaying ? 'Playing ambient audio...' : 'Tap Play to start listening',
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
                    // Thanh trượt âm lượng (Volume)
                    Row(
                      children: [
                        Icon(Icons.volume_mute_rounded, size: 16, color: context.textMuted),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primaryLight,
                              inactiveTrackColor: context.borderColor,
                              thumbColor: AppColors.primary,
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
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Tiêu đề danh sách bản nhạc
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SOUNDTRACK PLAYLIST',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: context.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách toàn bộ các bản nhạc
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: tracks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final track = tracks[index];
                final isCurrent = _audioService.currentTrackTitle == track['title'];

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
          ),
        ],
      ),
    );
  }
}
