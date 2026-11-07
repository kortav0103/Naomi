import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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
  late String _selectedLanguage; // 'all', 'vi', 'en'
  bool _isAscending = true; // true = 1 -> N, false = N -> 1

  @override
  void initState() {
    super.initState();
    _selectedLanguage = sl<ThemeController>().preferredLanguage;
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
            SnackBar(content: Text('Lỗi: ${failure.message}'), backgroundColor: AppColors.error),
          );
        }
      },
      (isFav) {
        if (mounted) {
          setState(() => _isBookmarked = isFav);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFav ? 'Đã thêm vào Tủ sách yêu thích!' : 'Đã xóa khỏi Tủ sách yêu thích.'),
              backgroundColor: isFav ? AppColors.primary : AppColors.darkSurface,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  Future<void> _downloadChapter(Comic comic, Chapter chapter) async {
    if (_downloadingChapterIds.contains(chapter.id) || _downloadedChapterIds.contains(chapter.id)) return;

    setState(() {
      _downloadingChapterIds.add(chapter.id);
      _downloadProgress[chapter.id] = 0.0;
      _downloadDetailText[chapter.id] = 'Đang khởi tạo...';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang tải Chương ${chapter.chapterNumber} để đọc ngoại tuyến (FR-06)...'),
        duration: const Duration(seconds: 2),
      ),
    );

    final result = await sl<DownloadChapter>()(
      DownloadChapterParams(
        comicId: comic.id,
        comicTitle: comic.title,
        coverUrl: comic.coverUrl,
        author: comic.author,
        chapterId: chapter.id,
        chapterNumber: chapter.chapterNumber,
        chapterTitle: chapter.title,
        onProgress: (downloaded, total) {
          if (mounted && total > 0) {
            setState(() {
              _downloadProgress[chapter.id] = downloaded / total;
              _downloadDetailText[chapter.id] = '$downloaded/$total trang (${((downloaded / total) * 100).toInt()}%)';
            });
          }
        },
      ),
    );

    if (mounted) {
      setState(() {
        _downloadingChapterIds.remove(chapter.id);
        _downloadProgress.remove(chapter.id);
        _downloadDetailText.remove(chapter.id);
      });
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tải thất bại: ${failure.message}'), backgroundColor: AppColors.error),
          );
        },
        (_) {
          setState(() => _downloadedChapterIds.add(chapter.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tải xong Chương ${chapter.chapterNumber}! Có thể đọc 100% Offline trong Tủ sách.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    }
  }

  List<Chapter> _processChapters(List<Chapter> rawChapters) {
    // 1. Lọc theo ngôn ngữ
    List<Chapter> filtered = rawChapters;
    if (_selectedLanguage != 'all') {
      filtered = rawChapters.where((c) => c.translatedLanguage.toLowerCase() == _selectedLanguage).toList();
    }

    // 2. Khử trùng lặp thông minh theo số chương (Ưu tiên giữ bản Tiếng Việt 'vi' trước, sau đó đến 'en')
    final Map<String, Chapter> uniqueByNumber = {};
    for (final ch in filtered) {
      final key = ch.chapterNumber.trim();
      if (!uniqueByNumber.containsKey(key)) {
        uniqueByNumber[key] = ch;
      } else {
        final existing = uniqueByNumber[key]!;
        if (existing.translatedLanguage.toLowerCase() != 'vi' &&
            ch.translatedLanguage.toLowerCase() == 'vi') {
          uniqueByNumber[key] = ch;
        }
      }
    }

    // 3. Sắp xếp tăng dần hoặc giảm dần
    final sorted = uniqueByNumber.values.toList();
    sorted.sort((a, b) {
      final numA = double.tryParse(a.chapterNumber) ?? 0.0;
      final numB = double.tryParse(b.chapterNumber) ?? 0.0;
      return _isAscending ? numA.compareTo(numB) : numB.compareTo(numA);
    });

    return sorted;
  }

  void _openReader(Comic comic, List<Chapter> chapters, int initialIndex) {
    if (chapters.isEmpty || initialIndex < 0 || initialIndex >= chapters.length) return;

    final targetChapter = chapters[initialIndex];
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
          currentChapterIndex: initialIndex,
        ),
      ),
    ).then((_) {
      _checkInitialStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
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
                      backgroundColor: AppColors.darkBackground,
                      leading: IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          tooltip: _isBookmarked ? 'Bỏ thích' : 'Yêu thích (Tủ sách)',
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
                                    AppColors.darkBackground.withValues(alpha: 0.8),
                                    AppColors.darkBackground,
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
                                            color: AppColors.darkSurface,
                                            child: const Icon(Icons.book_rounded, color: AppColors.darkTextMuted),
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
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tác giả: ${comic.author}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkTextSecondary,
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
                                        foregroundColor: AppColors.darkTextPrimary,
                                        side: const BorderSide(color: AppColors.darkBorder),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.first_page_rounded, size: 18, color: AppColors.primaryLight),
                                      label: const Text('Đọc từ đầu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      onPressed: () => _openReader(comic, processedChapters, firstChapterIndex),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.darkTextPrimary,
                                        side: const BorderSide(color: AppColors.darkBorder),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.new_releases_outlined, size: 16, color: AppColors.primaryLight),
                                      label: const Text('Chương mới nhất', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      onPressed: () => _openReader(comic, processedChapters, latestChapterIndex),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.outlined(
                                    tooltip: _isBookmarked ? 'Bỏ Yêu thích' : 'Lưu Yêu thích (FR-07)',
                                    style: IconButton.styleFrom(
                                      side: BorderSide(color: _isBookmarked ? AppColors.error : AppColors.darkBorder),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: Icon(
                                      _isBookmarked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: _isBookmarked ? AppColors.error : AppColors.darkTextSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => _toggleBookmark(comic),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton.outlined(
                                    tooltip: 'Tải nhanh chương đầu ngoại tuyến (FR-06)',
                                    style: IconButton.styleFrom(
                                      side: const BorderSide(color: AppColors.darkBorder),
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
                                      color: AppColors.darkSurface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.darkBorder),
                                    ),
                                    child: Text(
                                      genre,
                                      style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                                    ),
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 16),

                            // Mô tả nội dung có nút Xem thêm / Thu gọn
                            const Text(
                              'TÓM TẮT NỘI DUNG',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comic.description.isNotEmpty ? comic.description : 'Chưa có mô tả cho tác phẩm này.',
                              maxLines: _isDescriptionExpanded ? null : 3,
                              overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                            if (comic.description.length > 120)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                                  child: Text(
                                    _isDescriptionExpanded ? 'Thu gọn ▲' : 'Xem thêm ▼',
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
                                      'DANH SÁCH CHƯƠNG',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${processedChapters.length} chương)',
                                      style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  tooltip: _isAscending ? 'Sắp xếp: 1 -> N (Nhỏ đến lớn)' : 'Sắp xếp: N -> 1 (Mới nhất trước)',
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

                            // Bộ lọc ngôn ngữ chương (Tất cả / Tiếng Việt / English)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('Tất cả (Ưu tiên VI)'),
                                    selected: _selectedLanguage == 'all',
                                    selectedColor: AppColors.primary,
                                    backgroundColor: AppColors.darkSurface,
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      color: _selectedLanguage == 'all' ? Colors.white : AppColors.darkTextSecondary,
                                    ),
                                    onSelected: (_) => setState(() => _selectedLanguage = 'all'),
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text('Tiếng Việt (VI)'),
                                    selected: _selectedLanguage == 'vi',
                                    selectedColor: AppColors.primary,
                                    backgroundColor: AppColors.darkSurface,
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      color: _selectedLanguage == 'vi' ? Colors.white : AppColors.darkTextSecondary,
                                    ),
                                    onSelected: (_) => setState(() => _selectedLanguage = 'vi'),
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text('English (EN)'),
                                    selected: _selectedLanguage == 'en',
                                    selectedColor: AppColors.primary,
                                    backgroundColor: AppColors.darkSurface,
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      color: _selectedLanguage == 'en' ? Colors.white : AppColors.darkTextSecondary,
                                    ),
                                    onSelected: (_) => setState(() => _selectedLanguage = 'en'),
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
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Text(
                              'Không tìm thấy chương nào với bộ lọc ngôn ngữ này.',
                              style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
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
                                color: isLastRead ? AppColors.primary.withValues(alpha: 0.12) : AppColors.darkSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isLastRead ? AppColors.primaryLight : AppColors.darkBorder,
                                    width: isLastRead ? 1.5 : 1.0,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Chương ${chapter.chapterNumber}${chapter.title.isNotEmpty ? ': ${chapter.title}' : ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isLastRead ? FontWeight.w700 : FontWeight.w600,
                                            color: isLastRead ? AppColors.primaryLight : AppColors.darkTextPrimary,
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
                                            'Đang đọc',
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
                                                'Đang tải: $progressText',
                                                style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 4),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(3),
                                                child: LinearProgressIndicator(
                                                  value: progress > 0 ? progress : null,
                                                  backgroundColor: AppColors.darkBorder,
                                                  color: AppColors.success,
                                                  minHeight: 4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Text(
                                          'Nhóm dịch: ${chapter.scanlationGroup} • [${chapter.translatedLanguage.toUpperCase()}]',
                                          style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
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
                                          tooltip: 'Tải đọc ngoại tuyến (FR-06)',
                                          icon: const Icon(Icons.download_rounded, color: AppColors.darkTextSecondary, size: 20),
                                          onPressed: () => _downloadChapter(comic, chapter),
                                        ),

                                      // Nút Đọc ngay
                                      IconButton(
                                        tooltip: 'Đọc chương này',
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
                            color: Colors.black.withValues(alpha: 0.5),
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
                              ? 'ĐỌC TIẾP CHƯƠNG ${_lastReadHistory!.chapterNumber} (Trang ${_lastReadHistory!.lastPageRead}/${_lastReadHistory!.totalPages})'
                              : 'BẮT ĐẦU ĐỌC NGAY (Chương ${processedChapters[resumeIndex].chapterNumber})',
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
                    const Text(
                      'Oops! Không thể tải thông tin truyện',
                      style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.darkTextSecondary)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkTextPrimary,
                            side: const BorderSide(color: AppColors.darkBorder),
                          ),
                          onPressed: () => context.read<ComicDetailBloc>().add(LoadComicDetailEvent(widget.comicId)),
                          child: const Text('Thử lại'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          icon: const Icon(Icons.offline_pin_rounded, color: Colors.white, size: 18),
                          label: const Text('Mở Kho Ngoại Tuyến', style: TextStyle(color: Colors.white)),
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
