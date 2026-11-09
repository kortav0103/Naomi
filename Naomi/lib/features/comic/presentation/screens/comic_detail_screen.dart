import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../library/domain/entities/reading_history_item.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../../library/domain/usecases/check_is_bookmarked.dart';
import '../../../library/domain/usecases/download_chapter.dart';
import '../../../library/domain/usecases/toggle_bookmark.dart';
import '../../../reader/presentation/screens/reader_screen.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/comic.dart';
import '../bloc/detail/comic_detail_bloc.dart';
import '../bloc/detail/comic_detail_event.dart';
import '../bloc/detail/comic_detail_state.dart';

class ComicDetailScreen extends StatelessWidget {
  final String comicId;

  const ComicDetailScreen({super.key, required this.comicId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ComicDetailBloc>()..add(LoadComicDetailEvent(comicId)),
      child: _ComicDetailView(comicId: comicId),
    );
  }
}

class _ComicDetailView extends StatefulWidget {
  final String comicId;

  const _ComicDetailView({required this.comicId});

  @override
  State<_ComicDetailView> createState() => _ComicDetailViewState();
}

class _ComicDetailViewState extends State<_ComicDetailView> {
  bool _isBookmarked = false;
  final Set<String> _downloadedChapterIds = {};
  final Set<String> _downloadingChapterIds = {};
  final Map<String, double> _downloadProgress = {};
  final Map<String, String> _downloadDetailText = {};
  ReadingHistoryItem? _lastReadHistory;

  bool _isDescriptionExpanded = false;
  bool _isAscending = true; // true = 1 -> N, false = N -> 1

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    // 1. Kiểm tra trạng thái yêu thích
    final bookmarkResult = await sl<CheckIsBookmarked>()(widget.comicId);
    bookmarkResult.fold((_) {}, (isFav) {
      if (mounted) setState(() => _isBookmarked = isFav);
    });

    // 2. Nạp danh sách chương ngoại tuyến
    final downloadsResult = await sl<LibraryRepository>().getDownloadedChapters();
    downloadsResult.fold((_) {}, (downloads) {
      if (mounted) {
        setState(() {
          for (final d in downloads) {
            _downloadedChapterIds.add(d.chapterId);
          }
        });
      }
    });

    // 3. Kiểm tra tiến trình đọc dở gần nhất của bộ truyện này (FR-08)
    final historyResult = await sl<LibraryRepository>().getReadingHistory();
    historyResult.fold((_) {}, (historyList) {
      final matches = historyList.where((item) => item.comicId == widget.comicId);
      if (matches.isNotEmpty && mounted) {
        setState(() => _lastReadHistory = matches.first);
      }
    });
  }

  Future<void> _toggleBookmark(Comic comic) async {
    final result = await sl<ToggleBookmark>()(
      comicId: comic.id,
      title: comic.title,
      coverUrl: comic.coverUrl,
      author: comic.author,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}'), backgroundColor: AppColors.error),
          );
        }
      },
      (isFav) {
        if (mounted) {
          setState(() => _isBookmarked = isFav);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFav ? 'Added to Favorites!' : 'Removed from Favorites.'),
              backgroundColor: isFav ? AppColors.primary : context.surfaceColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  Future<void> _downloadChapter(Comic comic, Chapter chapter) async {
    if (_downloadedChapterIds.contains(chapter.id) || _downloadingChapterIds.contains(chapter.id)) {
      return;
    }

    setState(() {
      _downloadingChapterIds.add(chapter.id);
      _downloadProgress[chapter.id] = 0.0;
      _downloadDetailText[chapter.id] = 'Connecting...';
    });

    final result = await sl<DownloadChapter>()(
      DownloadChapterParams(
        comicId: comic.id,
        comicTitle: comic.title,
        coverUrl: comic.coverUrl,
        author: comic.author,
        chapterId: chapter.id,
        chapterNumber: chapter.chapterNumber,
        chapterTitle: chapter.title,
        onProgress: (received, total) {
          if (mounted) {
            setState(() {
              final progress = total > 0 ? (received / total) : 0.0;
              _downloadProgress[chapter.id] = progress;
              _downloadDetailText[chapter.id] = '$received/$total pages (${(progress * 100).toInt()}%)';
            });
          }
        },
      ),
    );

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _downloadingChapterIds.remove(chapter.id);
            _downloadProgress.remove(chapter.id);
            _downloadDetailText.remove(chapter.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error downloading Chapter ${chapter.chapterNumber}: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      (_) {
        if (mounted) {
          setState(() {
            _downloadingChapterIds.remove(chapter.id);
            _downloadProgress.remove(chapter.id);
            _downloadDetailText.remove(chapter.id);
            _downloadedChapterIds.add(chapter.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chapter ${chapter.chapterNumber} downloaded for offline reading!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  List<Chapter> _processChapters(List<Chapter> originalChapters) {
    // Only accept English ('en') chapters
    List<Chapter> filtered = originalChapters.where((c) => c.translatedLanguage == 'en').toList();

    filtered.sort((a, b) {
      final numA = double.tryParse(a.chapterNumber) ?? 0.0;
      final numB = double.tryParse(b.chapterNumber) ?? 0.0;
      return _isAscending ? numA.compareTo(numB) : numB.compareTo(numA);
    });

    return filtered;
  }

  void _openReader(Comic comic, List<Chapter> chapters, int initialIndex) {
    if (chapters.isEmpty) return;
    final clampedIndex = initialIndex.clamp(0, chapters.length - 1);
    final targetChapter = chapters[clampedIndex];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          chapterId: targetChapter.id,
          chapterNumber: targetChapter.chapterNumber,
          chapterTitle: targetChapter.title,
          comicId: comic.id,
          comicTitle: comic.title,
          coverUrl: comic.coverUrl,
          comicGenres: comic.genres,
          chaptersList: chapters,
          currentChapterIndex: clampedIndex,
        ),
      ),
    ).then((_) => _checkInitialStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: BlocBuilder<ComicDetailBloc, ComicDetailState>(
        builder: (context, state) {
          if (state is ComicDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ComicDetailLoaded) {
            final comic = state.comic;
            final processedChapters = _processChapters(state.chapters);

            // Tìm chương đầu tiên (nhỏ nhất) và chương mới nhất (lớn nhất)
            final firstChapterIndex = _isAscending ? 0 : (processedChapters.length - 1);
            final latestChapterIndex = _isAscending ? (processedChapters.length - 1) : 0;

            // Tìm chương phù hợp để tiếp tục đọc
            int resumeIndex = firstChapterIndex.clamp(0, processedChapters.isEmpty ? 0 : processedChapters.length - 1);
            if (_lastReadHistory != null) {
              final idx = processedChapters.indexWhere(
                (c) => c.id == _lastReadHistory!.chapterId || c.chapterNumber == _lastReadHistory!.chapterNumber,
              );
              if (idx != -1) resumeIndex = idx;
            }

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // 1. Sliver AppBar với ảnh bìa lớn & nút Thả tim
                    SliverAppBar(
                      expandedHeight: 340,
                      pinned: true,
                      backgroundColor: context.backgroundColor,
                      leading: IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          tooltip: _isBookmarked ? 'Remove from Favorites' : 'Add to Favorites',
                          icon: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Icon(
                              _isBookmarked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: _isBookmarked ? AppColors.error : Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () => _toggleBookmark(comic),
                        ),
                        const SizedBox(width: 8),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (comic.coverUrl != null)
                              CachedNetworkImage(
                                imageUrl: comic.coverUrl!,
                                fit: BoxFit.cover,
                              ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    context.backgroundColor.withValues(alpha: 0.8),
                                    context.backgroundColor,
                                  ],
                                  stops: const [0.3, 0.7, 1.0],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: comic.coverUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: comic.coverUrl!,
                                            width: 105,
                                            height: 145,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 105,
                                            height: 145,
                                            color: context.surfaceColor,
                                            child: Icon(Icons.book_rounded, color: context.textMuted),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          comic.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: context.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Author: ${comic.author}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            comic.status.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryLight,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Cụm 4 Nút Hành Động Nhanh (S04 / UC-02 / FR-10) + Thể loại + Tóm tắt
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cụm 4 nút chuẩn đặc tả S04: Read First | Read Latest | Favorite | Download
                            if (processedChapters.isNotEmpty) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: context.textPrimary,
                                        side: BorderSide(color: context.borderColor),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.first_page_rounded, size: 18, color: AppColors.primaryLight),
                                      label: const Text('Read First', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      onPressed: () => _openReader(comic, processedChapters, firstChapterIndex),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: context.textPrimary,
                                        side: BorderSide(color: context.borderColor),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.new_releases_outlined, size: 16, color: AppColors.primaryLight),
                                      label: const Text('Latest Chapter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      onPressed: () => _openReader(comic, processedChapters, latestChapterIndex),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.outlined(
                                    tooltip: _isBookmarked ? 'Unfavorite' : 'Save to Favorites',
                                    style: IconButton.styleFrom(
                                      side: BorderSide(color: _isBookmarked ? AppColors.error : context.borderColor),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: Icon(
                                      _isBookmarked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: _isBookmarked ? AppColors.error : context.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => _toggleBookmark(comic),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton.outlined(
                                    tooltip: 'Quick download chapter for offline reading',
                                    style: IconButton.styleFrom(
                                      side: BorderSide(color: context.borderColor),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.primaryLight, size: 20),
                                    onPressed: () => _downloadChapter(comic, processedChapters[resumeIndex]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Danh sách Genre Chips
                            if (comic.genres.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: comic.genres.map((genre) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: context.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: context.borderColor),
                                    ),
                                    child: Text(
                                      genre,
                                      style: TextStyle(fontSize: 11, color: context.textSecondary),
                                    ),
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 16),

                            // Mô tả nội dung có nút Xem thêm / Thu gọn
                            const Text(
                              'SYNOPSIS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comic.description.isNotEmpty ? comic.description : 'No description available for this title.',
                              maxLines: _isDescriptionExpanded ? null : 3,
                              overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: context.textSecondary,
                              ),
                            ),
                            if (comic.description.length > 120)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                                  child: Text(
                                    _isDescriptionExpanded ? 'Show less ▲' : 'Read more ▼',
                                    style: const TextStyle(color: AppColors.primaryLight, fontSize: 12),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Tiêu đề danh sách chương & Bộ lọc ngôn ngữ / Sắp xếp
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'CHAPTER LIST',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${processedChapters.length} chapters)',
                                      style: TextStyle(fontSize: 12, color: context.textMuted),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  tooltip: _isAscending ? 'Sort: 1 -> N (Ascending)' : 'Sort: N -> 1 (Newest first)',
                                  icon: Icon(
                                    _isAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                    color: AppColors.primaryLight,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _isAscending = !_isAscending),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Chỉ hiển thị ngôn ngữ English (EN)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('English (EN)'),
                                    selected: true,
                                    selectedColor: AppColors.primary,
                                    backgroundColor: context.surfaceColor,
                                    side: const BorderSide(color: AppColors.primary),
                                    labelStyle: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                    onSelected: (_) {},
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    // 3. Danh sách các chương (Chapters List) kèm thanh tiến độ tải S11
                    if (processedChapters.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Text(
                              'No English chapters available for this comic.',
                              style: TextStyle(color: context.textMuted, fontSize: 13),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final chapter = processedChapters[index];
                            final isDownloading = _downloadingChapterIds.contains(chapter.id);
                            final isDownloaded = _downloadedChapterIds.contains(chapter.id);
                            final isLastRead = _lastReadHistory?.chapterId == chapter.id ||
                                _lastReadHistory?.chapterNumber == chapter.chapterNumber;
                            final progress = _downloadProgress[chapter.id] ?? 0.0;
                            final progressText = _downloadDetailText[chapter.id] ?? '';

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Material(
                                color: isLastRead ? AppColors.primary.withValues(alpha: 0.12) : context.surfaceColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isLastRead ? AppColors.primaryLight : context.borderColor,
                                    width: isLastRead ? 1.5 : 1.0,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Chapter ${chapter.chapterNumber}${chapter.title.isNotEmpty ? ': ${chapter.title}' : ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isLastRead ? FontWeight.w700 : FontWeight.w600,
                                            color: isLastRead ? AppColors.primaryLight : context.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isLastRead)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Reading',
                                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: isDownloading
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Downloading: $progressText',
                                                style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 4),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(3),
                                                child: LinearProgressIndicator(
                                                  value: progress > 0 ? progress : null,
                                                  backgroundColor: context.borderColor,
                                                  color: AppColors.success,
                                                  minHeight: 4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Text(
                                          'Group: ${chapter.scanlationGroup} • [${chapter.translatedLanguage.toUpperCase()}]',
                                          style: TextStyle(fontSize: 11, color: context.textMuted),
                                        ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Nút tải ngoại tuyến (FR-06 / S11)
                                      if (isDownloading)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: 26,
                                                height: 26,
                                                child: CircularProgressIndicator(
                                                  value: progress > 0 ? progress : null,
                                                  strokeWidth: 2.5,
                                                  color: AppColors.success,
                                                ),
                                              ),
                                              Text(
                                                '${(progress * 100).toInt()}%',
                                                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.success),
                                              ),
                                            ],
                                          ),
                                        )
                                      else if (isDownloaded)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: Icon(Icons.offline_pin_rounded, color: AppColors.success, size: 22),
                                        )
                                      else
                                        IconButton(
                                          tooltip: 'Download for offline reading',
                                          icon: Icon(Icons.download_rounded, color: context.textSecondary, size: 20),
                                          onPressed: () => _downloadChapter(comic, chapter),
                                        ),

                                      // Nút Đọc ngay
                                      IconButton(
                                        tooltip: 'Read this chapter',
                                        icon: const Icon(
                                          Icons.play_circle_outline_rounded,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                        onPressed: () => _openReader(comic, processedChapters, index),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _openReader(comic, processedChapters, index),
                                ),
                              ),
                            );
                          },
                          childCount: processedChapters.length,
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
                ),

                // 4. Thanh Sticky Floating Action Bar ở đáy màn hình: Bắt đầu đọc / Đọc tiếp
                if (processedChapters.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.5 : 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                        ),
                        icon: const Icon(Icons.menu_book_rounded, size: 22),
                        label: Text(
                          _lastReadHistory != null
                              ? 'RESUME CHAPTER ${_lastReadHistory!.chapterNumber} (Page ${_lastReadHistory!.lastPageRead}/${_lastReadHistory!.totalPages})'
                              : 'START READING NOW (Chapter ${processedChapters[resumeIndex].chapterNumber})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                        ),
                        onPressed: () => _openReader(comic, processedChapters, resumeIndex),
                      ),
                    ),
                  ),
              ],
            );
          } else if (state is ComicDetailError) {
            // Trạng thái mất mạng S09 (FR-13)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 60, color: AppColors.warning),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Unable to load comic details',
                      style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: context.textSecondary)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.textPrimary,
                            side: BorderSide(color: context.borderColor),
                          ),
                          onPressed: () => context.read<ComicDetailBloc>().add(LoadComicDetailEvent(widget.comicId)),
                          child: const Text('Retry'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          icon: const Icon(Icons.offline_pin_rounded, color: Colors.white, size: 18),
                          label: const Text('Open Offline Library', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.pop(context);
                            sl<ThemeController>().navigateToOfflineLibrary();
                          },
                        ),
                      ],
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
}
