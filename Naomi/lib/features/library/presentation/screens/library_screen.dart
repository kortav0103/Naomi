import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: const Text(
            'TỦ SÁCH CÁ NHÂN',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.darkTextPrimary,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primaryLight,
            unselectedLabelColor: AppColors.darkTextSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.favorite_rounded, size: 18), text: 'YÊU THÍCH'),
              Tab(icon: Icon(Icons.offline_pin_rounded, size: 18), text: 'ĐÃ TẢI XUỐNG'),
            ],
          ),
        ),
        body: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is LibraryLoaded) {
              return TabBarView(
                children: [
                  // Tab 1: Danh sách Yêu thích
                  _buildBookmarksTab(context, state),
                  // Tab 2: Danh sách Tải ngoại tuyến
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
                    Text(state.message, style: const TextStyle(color: AppColors.darkTextPrimary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => context.read<LibraryBloc>().add(const LoadLibraryEvent()),
                      child: const Text('Tải lại', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Giao diện Tab 1: Truyện Yêu thích
  Widget _buildBookmarksTab(BuildContext context, LibraryLoaded state) {
    if (state.bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.darkTextMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Tủ truyện yêu thích đang trống.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hãy thả tim những bộ truyện hay ở mục Khám phá nhé!',
              style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.darkSurface,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ComicDetailScreen(comicId: item.comicId)),
              );
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
                                color: AppColors.darkSurface,
                                child: const Center(child: Icon(Icons.book_rounded, color: AppColors.darkTextMuted)),
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
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
                ),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Giao diện Tab 2: Chương Tải ngoại tuyến
  Widget _buildDownloadsTab(BuildContext context, LibraryLoaded state) {
    if (state.downloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_for_offline_outlined, size: 64, color: AppColors.darkTextMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Chưa có chương nào được tải về máy.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tải truyện về để đọc mượt mà kể cả khi không có mạng!',
              style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.downloads.length,
      itemBuilder: (context, index) {
        final download = state.downloads[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.darkBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.darkBackground,
                child: Icon(Icons.offline_pin_rounded, color: AppColors.success, size: 20),
              ),
              title: Text(
                download.comicTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
              ),
              subtitle: Text(
                'Chương ${download.chapterNumber} • ${download.totalPages} trang',
                style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
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
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
