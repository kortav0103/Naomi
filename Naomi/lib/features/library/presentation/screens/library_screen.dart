import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../comic/presentation/screens/comic_detail_screen.dart';
import '../../../reader/presentation/screens/reader_screen.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LibraryBloc>()..add(const LoadLibraryEvent()),
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatefulWidget {
  const _LibraryView();

  @override
  State<_LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<_LibraryView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ThemeController _themeController = sl<ThemeController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _themeController.libraryTabIndex.clamp(0, 2),
    );
    _themeController.addListener(_onThemeControllerChanged);
  }

  void _onThemeControllerChanged() {
    if (!mounted) return;
    final targetTab = _themeController.libraryTabIndex.clamp(0, 2);
    if (_tabController.index != targetTab) {
      _tabController.animateTo(targetTab);
    }
    if (_themeController.mainNavIndex == 1) {
      context.read<LibraryBloc>().add(const LoadLibraryEvent());
    }
  }

  @override
  void dispose() {
    _themeController.removeListener(_onThemeControllerChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        int bookmarkCount = 0;
        int historyCount = 0;
        int downloadCount = 0;

        if (state is LibraryLoaded) {
          bookmarkCount = state.bookmarks.length;
          historyCount = state.history.length;
          downloadCount = state.downloads.length;
        }

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: AppBar(
            title: Text(
              'MY LIBRARY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: context.textPrimary,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              onTap: (index) => _themeController.setLibraryTabIndex(index),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: context.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: [
                Tab(
                  icon: const Icon(Icons.favorite_rounded, size: 18),
                  text: 'FAVORITES ($bookmarkCount)',
                ),
                Tab(
                  icon: const Icon(Icons.history_rounded, size: 18),
                  text: 'HISTORY ($historyCount)',
                ),
                Tab(
                  icon: const Icon(Icons.offline_pin_rounded, size: 18),
                  text: 'DOWNLOADS ($downloadCount)',
                ),
              ],
            ),
          ),
          body: Builder(
            builder: (ctx) {
              if (state is LibraryLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (state is LibraryLoaded) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Danh sách Yêu thích (FR-07)
                    _buildBookmarksTab(context, state),
                    // Tab 2: Lịch sử đọc dở (FR-04 & FR-08)
                    _buildHistoryTab(context, state),
                    // Tab 3: Danh sách Tải ngoại tuyến (FR-06)
                    _buildDownloadsTab(context, state),
                  ],
                );
              } else if (state is LibraryError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(state.message, style: TextStyle(color: context.textPrimary)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () => context.read<LibraryBloc>().add(const LoadLibraryEvent()),
                        child: const Text('Reload', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  /// Giao diện Tab 1: Truyện Yêu thích
  Widget _buildBookmarksTab(BuildContext context, LibraryLoaded state) {
    if (state.bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 64, color: context.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Your Favorites list is empty.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the heart icon on comics in Discover to save them here!',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: context.surfaceColor,
      onRefresh: () async {
        context.read<LibraryBloc>().add(const LoadLibraryEvent());
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
        ),
        itemCount: state.bookmarks.length,
        itemBuilder: (context, index) {
          final item = state.bookmarks[index];
          return GestureDetector(
            onTap: () {
              final bloc = context.read<LibraryBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ComicDetailScreen(comicId: item.comicId)),
              ).then((_) => bloc.add(const LoadLibraryEvent()));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.coverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: item.coverUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Container(
                                color: context.surfaceColor,
                                child: Center(child: Icon(Icons.book_rounded, color: context.textMuted)),
                              ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            context.read<LibraryBloc>().add(
                                  ToggleBookmarkEvent(
                                    comicId: item.comicId,
                                    title: item.title,
                                    coverUrl: item.coverUrl,
                                    author: item.author,
                                  ),
                                );
                          },
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.favorite_rounded, color: AppColors.error, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
                ),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Giao diện Tab 2: Lịch sử đọc dở (FR-04, FR-08)
  Widget _buildHistoryTab(BuildContext context, LibraryLoaded state) {
    if (state.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: context.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No reading history yet.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Chapters you start reading will automatically appear here.',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Nút xóa toàn bộ lịch sử
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.history.length} titles viewed',
                style: TextStyle(fontSize: 12, color: context.textMuted),
              ),
              TextButton.icon(
                icon: Icon(Icons.delete_sweep_rounded, size: 16, color: context.textMuted),
                label: Text('Clear History', style: TextStyle(color: context.textMuted, fontSize: 12)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor: context.surfaceColor,
                      title: Text('Clear Reading History?', style: TextStyle(color: context.textPrimary)),
                      content: Text(
                        'Are you sure you want to clear all reading history for this account?',
                        style: TextStyle(color: context.textSecondary, fontSize: 13),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: Text('Cancel', style: TextStyle(color: context.textMuted)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () {
                            Navigator.pop(dCtx);
                            context.read<LibraryBloc>().add(const ClearReadingHistoryEvent());
                          },
                          child: const Text('Clear', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Danh sách lịch sử đọc
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: context.surfaceColor,
            onRefresh: () async {
              context.read<LibraryBloc>().add(const LoadLibraryEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final item = state.history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: context.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: context.borderColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        final bloc = context.read<LibraryBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReaderScreen(
                              chapterId: item.chapterId,
                              chapterNumber: item.chapterNumber,
                              comicId: item.comicId,
                              comicTitle: item.comicTitle,
                              coverUrl: item.coverUrl,
                            ),
                          ),
                        ).then((_) => bloc.add(const LoadLibraryEvent()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            // Ảnh bìa
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.coverUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: item.coverUrl!,
                                      width: 50,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 50,
                                      height: 70,
                                      color: context.backgroundColor,
                                      child: Icon(Icons.book_rounded, color: context.textMuted),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Thông tin đọc dở
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.comicTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Chapter ${item.chapterNumber} • Page ${item.lastPageRead}/${item.totalPages}',
                                    style: TextStyle(fontSize: 12, color: context.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
                                          child: LinearProgressIndicator(
                                            value: item.readPercentage.clamp(0.0, 1.0),
                                            backgroundColor: context.borderColor,
                                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(item.readPercentage * 100).toInt()}%',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Nút Đọc tiếp
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 28),
                              tooltip: 'Resume Reading',
                              onPressed: () {
                                final bloc = context.read<LibraryBloc>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReaderScreen(
                                      chapterId: item.chapterId,
                                      chapterNumber: item.chapterNumber,
                                      comicId: item.comicId,
                                      comicTitle: item.comicTitle,
                                      coverUrl: item.coverUrl,
                                    ),
                                  ),
                                ).then((_) => bloc.add(const LoadLibraryEvent()));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Giao diện Tab 3: Chương Tải ngoại tuyến (FR-06)
  Widget _buildDownloadsTab(BuildContext context, LibraryLoaded state) {
    if (state.downloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_for_offline_outlined, size: 64, color: context.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No downloaded chapters yet.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Download chapters to read smoothly even without an internet connection!',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    final totalPages = state.downloads.fold<int>(0, (sum, d) => sum + d.totalPages);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.downloads.length} offline chapters ($totalPages pages)',
                style: TextStyle(fontSize: 12, color: context.textMuted),
              ),
              const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.success),
                  SizedBox(width: 4),
                  Text('100% Offline', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: state.downloads.length,
            itemBuilder: (context, index) {
              final download = state.downloads[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: context.surfaceColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: context.borderColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.backgroundColor,
                      child: const Icon(Icons.offline_pin_rounded, color: AppColors.success, size: 20),
                    ),
                    title: Text(
                      download.comicTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary),
                    ),
                    subtitle: Text(
                      'Chapter ${download.chapterNumber} • ${download.totalPages} pages',
                      style: TextStyle(fontSize: 12, color: context.textSecondary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      tooltip: 'Delete from storage',
                      onPressed: () {
                        context.read<LibraryBloc>().add(DeleteDownloadedChapterEvent(download.chapterId));
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderScreen(
                            chapterId: download.chapterId,
                            chapterNumber: download.chapterNumber,
                            comicTitle: download.comicTitle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
