import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/audio/ambient_audio_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';

/// BottomSheet S06 điều khiển nhạc nền Ambient theo đặc tả
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo nhỏ trên đỉnh
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Tiêu đề
          const Row(
            children: [
              Icon(Icons.music_note_rounded, color: AppColors.primaryLight, size: 20),
              SizedBox(width: 8),
              Text(
                'NHẠC NỀN AMBIENT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bộ điều khiển Play/Pause & Âm lượng
          StreamBuilder<PlayerState>(
            stream: _audioService.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final isPlaying = playerState?.playing ?? false;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorder),
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
                                final first = AmbientAudioService.defaultTracks.first;
                                _audioService.playTrack(url: first['url']!, title: first['title']!);
                              } else {
                                _audioService.resume();
                              }
                            }
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkTextPrimary,
                                ),
                              ),
                              Text(
                                isPlaying ? 'Đang phát thư giãn...' : 'Đang tạm dừng',
                                style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
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
                        const Icon(Icons.volume_mute_rounded, size: 16, color: AppColors.darkTextMuted),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primaryLight,
                              inactiveTrackColor: AppColors.darkBorder,
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
                        const Icon(Icons.volume_up_rounded, size: 16, color: AppColors.darkTextMuted),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Danh sách các giai điệu để lựa chọn
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'DANH SÁCH GIAI ĐIỆU GỢI Ý',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppColors.darkTextMuted,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: AmbientAudioService.defaultTracks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final track = AmbientAudioService.defaultTracks[index];
                final isCurrent = _audioService.currentTrackTitle == track['title'];

                return ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isCurrent ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  tileColor: isCurrent ? AppColors.primary.withValues(alpha: 0.15) : AppColors.darkBackground,
                  leading: Icon(
                    isCurrent ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                    color: isCurrent ? AppColors.primaryLight : AppColors.darkTextMuted,
                    size: 18,
                  ),
                  title: Text(
                    track['title']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent ? AppColors.primaryLight : AppColors.darkTextPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Thể loại: ${track['genre']}',
                    style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                  ),
                  onTap: () {
                    _audioService.playTrack(url: track['url']!, title: track['title']!);
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