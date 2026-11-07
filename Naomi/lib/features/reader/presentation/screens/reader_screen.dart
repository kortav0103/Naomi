import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../comic/domain/entities/chapter.dart';
import '../bloc/reader_bloc.dart';
import '../bloc/reader_event.dart';
import '../bloc/reader_state.dart';
import '../widgets/ambient_audio_sheet.dart';

class ReaderScreen extends StatelessWidget {
  final String chapterId;
  final String chapterNumber;
  final String? chapterTitle;
  final String comicId;
  final String comicTitle;
  final String? coverUrl;
  final List<Chapter> chaptersList;
  final int currentChapterIndex;

  const ReaderScreen({
    super.key,
    required this.chapterId,
    required this.chapterNumber,
    this.chapterTitle,
    this.comicId = '',
    this.comicTitle = 'Manga',
    this.coverUrl,
    this.chaptersList = const [],
    this.currentChapterIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReaderBloc>()
        ..add(LoadChapterPagesEvent(
          chapterId: chapterId,
          comicId: comicId,
          comicTitle: comicTitle,
          coverUrl: coverUrl,
          chapterNumber: chapterNumber,
        )),
      child: _ReaderView(
        initialChapterId: chapterId,
        initialChapterNumber: chapterNumber,
        initialChapterTitle: chapterTitle,
        comicId: comicId,
        comicTitle: comicTitle,
        coverUrl: coverUrl,
        chaptersList: chaptersList,
        initialChapterIndex: currentChapterIndex,
      ),
    );
  }
}

class _ReaderView extends StatefulWidget {
  final String initialChapterId;
  final String initialChapterNumber;
  final String? initialChapterTitle;
  final String comicId;
  final String comicTitle;
  final String? coverUrl;
  final List<Chapter> chaptersList;
  final int initialChapterIndex;

  const _ReaderView({
    required this.initialChapterId,
    required this.initialChapterNumber,
    this.initialChapterTitle,
    required this.comicId,
    required this.comicTitle,
    this.coverUrl,
    required this.chaptersList,
    required this.initialChapterIndex,
  });

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  late PageController _pageController;
  late ScrollController _scrollController;

  late int _currentIndex;
  late String _activeChapterId;
  late String _activeChapterNumber;
  late String? _activeChapterTitle;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _currentIndex = widget.initialChapterIndex;
    _activeChapterId = widget.initialChapterId;
    _activeChapterNumber = widget.initialChapterNumber;
    _activeChapterTitle = widget.initialChapterTitle;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _switchChapter(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.chaptersList.length) return;

    final newChapter = widget.chaptersList[newIndex];
    setState(() {
      _currentIndex = newIndex;
      _activeChapterId = newChapter.id;
      _activeChapterNumber = newChapter.chapterNumber;
      _activeChapterTitle = newChapter.title;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    context.read<ReaderBloc>().add(LoadChapterPagesEvent(
          chapterId: newChapter.id,
          comicId: widget.comicId,
          comicTitle: widget.comicTitle,
          coverUrl: widget.coverUrl,
          chapterNumber: newChapter.chapterNumber,
        ));
  }

  void _showChapterListModal(BuildContext context) {
    if (widget.chaptersList.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DANH SÁCH CHƯƠNG',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    Text(
                      '${widget.chaptersList.length} chương',
                      style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.darkBorder, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.chaptersList.length,
                  itemBuilder: (ctx, index) {
                    final chapter = widget.chaptersList[index];
                    final isCurrent = index == _currentIndex;

                    return ListTile(
                      dense: true,
                      tileColor: isCurrent ? AppColors.primary.withValues(alpha: 0.15) : null,
                      leading: Icon(
                        isCurrent ? Icons.play_arrow_rounded : Icons.menu_book_rounded,
                        color: isCurrent ? AppColors.primaryLight : AppColors.darkTextMuted,
                        size: 20,
                      ),
                      title: Text(
                        'Chương ${chapter.chapterNumber}${chapter.title.isNotEmpty ? ': ${chapter.title}' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.primaryLight : AppColors.darkTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '[${chapter.translatedLanguage.toUpperCase()}] • ${chapter.scanlationGroup}',
                        style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                      ),
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _switchChapter(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
            final hasPrevious = widget.chaptersList.isNotEmpty && _currentIndex > 0;
            final hasNext = widget.chaptersList.isNotEmpty && _currentIndex < widget.chaptersList.length - 1;

            return Stack(
              children: [
                // 1. Trình hiển thị trang ảnh (Cuộn dọc Webtoon hoặc Lật ngang Manga)
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
                  top: isFocus ? -120 : 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 4,
                      left: 8,
                      right: 12,
                      bottom: 8,
                    ),
                    color: Colors.black.withValues(alpha: 0.88),
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
                                'Chương $_activeChapterNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _activeChapterTitle != null && _activeChapterTitle!.isNotEmpty
                                    ? _activeChapterTitle!
                                    : widget.comicTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // Nút mở Drawer danh sách tất cả các chương
                        if (widget.chaptersList.isNotEmpty)
                          IconButton(
                            tooltip: 'Danh sách chương',
                            icon: const Icon(Icons.format_list_bulleted_rounded, color: Colors.white),
                            onPressed: () => _showChapterListModal(context),
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
                        // Nút đổi hướng đọc Manga: LTR vs RTL (Chuẩn Nhật Bản)
                        if (!state.isWebtoonMode)
                          IconButton(
                            tooltip: state.isRTL ? 'Hướng đọc: Phải sang Trái (RTL)' : 'Hướng đọc: Trái sang Phải (LTR)',
                            icon: Icon(
                              state.isRTL ? Icons.swap_horizontal_circle : Icons.swap_horizontal_circle_outlined,
                              color: state.isRTL ? AppColors.primaryLight : AppColors.darkTextSecondary,
                            ),
                            onPressed: () {
                              context.read<ReaderBloc>().add(const ToggleReadingDirectionEvent());
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

                // 3. Thanh công cụ phía dưới (Hiển thị số trang & trượt nhanh & chuyển chương)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  bottom: isFocus ? -120 : 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 8,
                      top: 8,
                      left: 12,
                      right: 12,
                    ),
                    color: Colors.black.withValues(alpha: 0.88),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Nút lùi về chương trước
                            if (widget.chaptersList.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.skip_previous_rounded, size: 22),
                                color: hasPrevious ? Colors.white : AppColors.darkTextMuted,
                                onPressed: hasPrevious ? () => _switchChapter(_currentIndex - 1) : null,
                                tooltip: 'Chương trước',
                              ),
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
                            // Nút chuyển sang chương kế tiếp
                            if (widget.chaptersList.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.skip_next_rounded, size: 22),
                                color: hasNext ? Colors.white : AppColors.darkTextMuted,
                                onPressed: hasNext ? () => _switchChapter(_currentIndex + 1) : null,
                                tooltip: 'Chương sau',
                              ),
                          ],
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
                      onPressed: () => context.read<ReaderBloc>().add(LoadChapterPagesEvent(
                            chapterId: _activeChapterId,
                            comicId: widget.comicId,
                            comicTitle: widget.comicTitle,
                            coverUrl: widget.coverUrl,
                            chapterNumber: _activeChapterNumber,
                          )),
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
    final hasNext = widget.chaptersList.isNotEmpty && _currentIndex < widget.chaptersList.length - 1;
    final nextChapter = hasNext ? widget.chaptersList[_currentIndex + 1] : null;

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.pages.totalPages + 1, // +1 cho thẻ Điều hướng cuối chương
      itemBuilder: (context, index) {
        if (index < state.pages.totalPages) {
          final url = state.pages.getPageUrl(index, isDataSaver: state.isDataSaver);
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.5,
            child: _buildImagePage(url, fit: BoxFit.fitWidth),
          );
        }

        // Thẻ chuyển sang chương tiếp theo ở đáy trang cuối
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          alignment: Alignment.center,
          color: AppColors.darkSurface,
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 48),
              const SizedBox(height: 12),
              Text(
                'Bạn vừa hoàn thành Chương $_activeChapterNumber',
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (hasNext && nextChapter != null) ...[
                Text(
                  'Tiếp theo: Chương ${nextChapter.chapterNumber}${nextChapter.title.isNotEmpty ? ' - ${nextChapter.title}' : ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.navigate_next_rounded),
                  label: Text('Đọc Chương ${nextChapter.chapterNumber} ngay'),
                  onPressed: () => _switchChapter(_currentIndex + 1),
                ),
              ] else ...[
                const Text(
                  'Chúc mừng! Bạn đã đọc đến chương mới nhất của bộ truyện này.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Quay lại trang chi tiết', style: TextStyle(color: AppColors.primaryLight)),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  /// Chế độ lật ngang từng trang kiểu Manga truyền thống (Hỗ trợ LTR & RTL chuẩn Nhật Bản)
  Widget _buildMangaViewer(BuildContext context, ReaderLoaded state) {
    return PageView.builder(
      controller: _pageController,
      reverse: state.isRTL, // Hỗ trợ lật từ Phải sang Trái chuẩn Manga Nhật
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
