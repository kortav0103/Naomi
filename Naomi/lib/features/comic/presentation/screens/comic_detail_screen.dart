import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final bookmarkResult = await sl<CheckIsBookmarked>()(widget.comicId);
    bookmarkResult.fold((_) {}, (isFav) {
      if (mounted) setState(() => _isBookmarked = isFav);
    });

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

    setState(() => _downloadingChapterIds.add(chapter.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bắt đầu tải Chương ${chapter.chapterNumber} ngoại tuyến...'),
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
      ),
    );

    if (mounted) {
      setState(() => _downloadingChapterIds.remove(chapter.id));
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
              content: Text('Đã tải xong Chương ${chapter.chapterNumber}! Có thể đọc offline trong Tủ sách.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    }
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
            final chapters = state.chapters;

            return CustomScrollView(
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
                        // Lớp phủ Gradient mờ dần xuống nền tối
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
                        // Bìa nổi bật + Thông tin ngắn gọn
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
                                        width: 100,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 140,
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
                                    const SizedBox(height: 4),
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

                // 2. Nội dung tóm tắt & danh mục thể loại
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        // Mô tả nội dung
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
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tiêu đề danh sách chương
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Text(
                              '${chapters.length} chương',
                              style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // 3. Danh sách các chương (Chapters List)
                if (chapters.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Chưa có chương nào được dịch sang ngôn ngữ này.',
                          style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chapter = chapters[index];
                        final isDownloading = _downloadingChapterIds.contains(chapter.id);
                        final isDownloaded = _downloadedChapterIds.contains(chapter.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Material(
                            color: AppColors.darkSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.darkBorder),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              title: Text(
                                'Chương ${chapter.chapterNumber}${chapter.title.isNotEmpty ? ': ${chapter.title}' : ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkTextPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Nhóm dịch: ${chapter.scanlationGroup} • [${chapter.translatedLanguage.toUpperCase()}]',
                                style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Nút tải ngoại tuyến (FR-06)
                                  if (isDownloading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
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
                                    tooltip: 'Đọc ngay',
                                    icon: const Icon(
                                      Icons.play_circle_outline_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReaderScreen(
                                            chapterId: chapter.id,
                                            chapterNumber: chapter.chapterNumber,
                                            chapterTitle: chapter.title,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: chapters.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          } else if (state is ComicDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.darkTextPrimary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => context.read<ComicDetailBloc>().add(LoadComicDetailEvent(widget.comicId)),
                      child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
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
