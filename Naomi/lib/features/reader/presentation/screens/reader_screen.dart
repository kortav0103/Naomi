import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/reader_bloc.dart';
import '../bloc/reader_event.dart';
import '../bloc/reader_state.dart';
import '../widgets/ambient_audio_sheet.dart';

class ReaderScreen extends StatelessWidget {
  final String chapterId;
  final String chapterNumber;
  final String? chapterTitle;

  const ReaderScreen({
    super.key,
    required this.chapterId,
    required this.chapterNumber,
    this.chapterTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReaderBloc>()..add(LoadChapterPagesEvent(chapterId)),
      child: _ReaderView(
        chapterId: chapterId,
        chapterNumber: chapterNumber,
        chapterTitle: chapterTitle,
      ),
    );
  }
}

class _ReaderView extends StatefulWidget {
  final String chapterId;
  final String chapterNumber;
  final String? chapterTitle;

  const _ReaderView({
    required this.chapterId,
    required this.chapterNumber,
    this.chapterTitle,
  });

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  late PageController _pageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: BlocConsumer<ReaderBloc, ReaderState>(
        listener: (context, state) {
          if (state is ReaderLoaded && _pageController.hasClients) {
            final targetIndex = state.currentPage - 1;
            if (targetIndex >= 0 && _pageController.page?.round() != targetIndex) {
              _pageController.jumpToPage(targetIndex);
            }
          }
        },
        builder: (context, state) {
          if (state is ReaderLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Đang nạp các trang truyện...',
                    style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          } else if (state is ReaderLoaded) {
            final pages = state.pages;
            final isFocus = state.isFocusMode;

            return Stack(
              children: [
                // 1. Trình hiển thị trang ảnh (Cuộn dọc hoặc Lật ngang)
                GestureDetector(
                  onTap: () {
                    // Chạm giữa màn hình để Bật/Tắt Focus Mode (FR-02)
                    context.read<ReaderBloc>().add(const ToggleFocusModeEvent());
                  },
                  child: state.isWebtoonMode
                      ? _buildWebtoonViewer(context, state)
                      : _buildMangaViewer(context, state),
                ),

                // 2. Thanh App Bar phía trên (Tự ẩn khi Focus Mode)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  top: isFocus ? -100 : 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 4,
                      left: 8,
                      right: 16,
                      bottom: 8,
                    ),
                    color: Colors.black.withValues(alpha: 0.85),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Chương ${widget.chapterNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.chapterTitle != null && widget.chapterTitle!.isNotEmpty)
                                Text(
                                  widget.chapterTitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        // Nút đổi chế độ Cuộn dọc / Lật ngang (FR-03)
                        IconButton(
                          tooltip: state.isWebtoonMode ? 'Chuyển sang Lật ngang' : 'Chuyển sang Cuộn dọc',
                          icon: Icon(
                            state.isWebtoonMode ? Icons.view_day_rounded : Icons.view_carousel_rounded,
                            color: AppColors.primaryLight,
                          ),
                          onPressed: () {
                            context.read<ReaderBloc>().add(const ToggleReaderModeEvent());
                          },
                        ),
                        // Nút bật Data Saver
                        IconButton(
                          tooltip: state.isDataSaver ? 'Chất lượng gốc' : 'Tiết kiệm 4G',
                          icon: Icon(
                            state.isDataSaver ? Icons.data_saver_on_rounded : Icons.high_quality_rounded,
                            color: state.isDataSaver ? AppColors.warning : AppColors.darkTextSecondary,
                          ),
                          onPressed: () {
                            context.read<ReaderBloc>().add(const ToggleDataSaverEvent());
                          },
                        ),
                        // Nút mở Nhạc nền Ambient (FR-05 & S06)
                        IconButton(
                          tooltip: 'Nhạc nền thư giãn',
                          icon: const Icon(
                            Icons.music_note_rounded,
                            color: AppColors.primaryLight,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const AmbientAudioSheet(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Thanh công cụ phía dưới (Hiển thị số trang & trượt nhanh)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  bottom: isFocus ? -100 : 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 8,
                      top: 8,
                      left: 16,
                      right: 16,
                    ),
                    color: Colors.black.withValues(alpha: 0.85),
                    child: Row(
                      children: [
                        Text(
                          '${state.currentPage} / ${pages.totalPages}',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.darkBorder,
                              thumbColor: AppColors.primaryLight,
                              overlayColor: AppColors.primary.withValues(alpha: 0.2),
                              trackHeight: 3,
                            ),
                            child: Slider(
                              value: state.currentPage.toDouble().clamp(1.0, pages.totalPages.toDouble()),
                              min: 1.0,
                              max: pages.totalPages > 0 ? pages.totalPages.toDouble() : 1.0,
                              divisions: pages.totalPages > 1 ? pages.totalPages - 1 : 1,
                              onChanged: (val) {
                                final index = val.round() - 1;
                                context.read<ReaderBloc>().add(ChangePageEvent(index));
                                if (!state.isWebtoonMode && _pageController.hasClients) {
                                  _pageController.jumpToPage(index);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is ReaderError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => context.read<ReaderBloc>().add(LoadChapterPagesEvent(widget.chapterId)),
                      child: const Text('Thử tải lại', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Trình dựng ảnh hỗ trợ cả URL mạng lẫn file ngoại tuyến tải về thiết bị
  Widget _buildImagePage(String url, {BoxFit fit = BoxFit.fitWidth}) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (context, url) => Container(
          height: 300,
          color: AppColors.darkSurface,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: AppColors.darkSurface,
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: AppColors.darkTextMuted),
          ),
        ),
      );
    } else {
      return Image.file(
        File(url),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: AppColors.darkSurface,
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: AppColors.darkTextMuted),
          ),
        ),
      );
    }
  }

  /// Chế độ cuộn dọc liên tục kiểu Webtoon
  Widget _buildWebtoonViewer(BuildContext context, ReaderLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: state.pages.totalPages,
      itemBuilder: (context, index) {
        final url = state.pages.getPageUrl(index, isDataSaver: state.isDataSaver);
        return _buildImagePage(url, fit: BoxFit.fitWidth);
      },
    );
  }

  /// Chế độ lật ngang từng trang kiểu Manga truyền thống (có Zoom)
  Widget _buildMangaViewer(BuildContext context, ReaderLoaded state) {
    return PageView.builder(
      controller: _pageController,
      itemCount: state.pages.totalPages,
      onPageChanged: (index) {
        context.read<ReaderBloc>().add(ChangePageEvent(index));
      },
      itemBuilder: (context, index) {
        final url = state.pages.getPageUrl(index, isDataSaver: state.isDataSaver);
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.5,
          child: Center(
            child: _buildImagePage(url, fit: BoxFit.contain),
          ),
        );
      },
    );
  }
}
