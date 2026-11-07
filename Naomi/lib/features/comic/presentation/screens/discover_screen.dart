import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/domain/entities/reading_history_item.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../../reader/presentation/screens/reader_screen.dart';
import '../bloc/discover/discover_bloc.dart';
import '../bloc/discover/discover_event.dart';
import '../bloc/discover/discover_state.dart';
import '../widgets/comic_card.dart';
import 'comic_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _selectedGenre = 'All';
  ReadingHistoryItem? _lastReadComic;

  // Danh mục tag thể loại phổ biến trên MangaDex v5
  final List<Map<String, String>> _genres = [
    {'name': 'All', 'id': ''},
    {'name': 'Action', 'id': '391b0423-d847-456f-aff0-8b0cfc03066b'},
    {'name': 'Romance', 'id': '423e2eae-a7a2-4a8b-ac03-a8351462d71d'},
    {'name': 'Comedy', 'id': '4d32cc48-9f00-4cca-9b5a-a839f0764984'},
    {'name': 'Fantasy', 'id': 'cdc58593-87dd-415e-bbc0-2ec27bf404cc'},
    {'name': 'Slice of Life', 'id': 'e5301a23-ebd9-49dd-a0cb-2add944c7fe9'},
    {'name': 'Sci-Fi', 'id': '256c8bd9-4904-4360-bf4f-508a76d67183'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent());
    _loadLastReadComic();
  }

  Future<void> _loadLastReadComic() async {
    final result = await sl<LibraryRepository>().getLastReadComic();
    result.fold((_) {}, (item) {
      if (mounted) setState(() => _lastReadComic = item);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (query.trim().isEmpty) {
        context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent());
      } else {
        context.read<DiscoverBloc>().add(SearchComicsEvent(query.trim()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'KHÁM PHÁ TRUYỆN',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.darkTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.darkTextSecondary),
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedGenre = 'All');
              _loadInitialData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.darkSurface,
        onRefresh: () async {
          _searchController.clear();
          setState(() => _selectedGenre = 'All');
          _loadInitialData();
        },
        child: Column(
          children: [
            // 1. Search Bar với Debounce 400ms (FR-01)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm manga, tác giả, webtoon...',
                  hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.darkTextMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.darkBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.darkBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            // 2. Banner "Tiếp tục đọc" (FR-08) - Chỉ hiển thị khi có tiến trình đọc dở
            if (_lastReadComic != null && _searchController.text.isEmpty && _selectedGenre == 'All')
              _buildContinueReadingBanner(context, _lastReadComic!),

            // 3. Thanh thể loại (Genre Chips Bar)
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _genres.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = _selectedGenre == genre['name'];
                  return ChoiceChip(
                    label: Text(
                      genre['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.darkTextSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.darkSurface,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.darkBorder,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedGenre = genre['name']!);
                        if (genre['id']!.isEmpty) {
                          context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent());
                        } else {
                          context.read<DiscoverBloc>().add(
                                FilterComicsByGenreEvent(
                                  genreTagId: genre['id']!,
                                  genreName: genre['name']!,
                                ),
                              );
                        }
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // 4. Nội dung danh sách truyện (Trending Carousel & Grid)
            Expanded(
              child: BlocBuilder<DiscoverBloc, DiscoverState>(
                builder: (context, state) {
                  if (state is DiscoverLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Đang tải truyện từ MangaDex...',
                            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  } else if (state is DiscoverLoaded) {
                    if (state.comics.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.darkTextMuted),
                            const SizedBox(height: 16),
                            const Text(
                              'Không tìm thấy bộ truyện nào phù hợp.',
                              style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _selectedGenre = 'All');
                                context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent());
                              },
                              child: const Text('Xem danh mục thịnh hành', style: TextStyle(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      );
                    }

                    final showCarousel = _searchController.text.isEmpty && _selectedGenre == 'All' && state.comics.length >= 4;
                    final featuredComics = showCarousel ? state.comics.take(5).toList() : [];
                    final regularComics = showCarousel ? state.comics.skip(5).toList() : state.comics;

                    return CustomScrollView(
                      slivers: [
                        // Carousel Thịnh Hành Nổi Bật (Trending Carousel)
                        if (showCarousel) ...[
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Row(
                                children: [
                                  Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'NỔI BẬT TRONG TUẦN',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1,
                                      color: AppColors.darkTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 175,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: featuredComics.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 12),
                                itemBuilder: (ctx, i) {
                                  final comic = featuredComics[i];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ComicDetailScreen(comicId: comic.id),
                                        ),
                                      ).then((_) => _loadLastReadComic());
                                    },
                                    child: Container(
                                      width: 110,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.darkBorder),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (comic.coverUrl != null)
                                            CachedNetworkImage(
                                              imageUrl: comic.coverUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          else
                                            Container(color: AppColors.darkSurface),
                                          Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.transparent, Colors.black87],
                                                stops: [0.5, 1.0],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 8,
                                            right: 8,
                                            bottom: 8,
                                            child: Text(
                                              comic.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],

                        // Tiêu đề danh sách truyện
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state.activeFilterTitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkTextPrimary,
                                  ),
                                ),
                                Text(
                                  '${state.comics.length} tác phẩm',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Grid truyện chính
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final comic = regularComics[index];
                                return ComicCard(
                                  comic: comic,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ComicDetailScreen(comicId: comic.id),
                                      ),
                                    ).then((_) => _loadLastReadComic());
                                  },
                                );
                              },
                              childCount: regularComics.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is DiscoverError) {
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
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Thử lại'),
                              onPressed: () => context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent()),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner "Tiếp tục đọc" trực quan sinh động (FR-08)
  Widget _buildContinueReadingBanner(BuildContext context, ReadingHistoryItem item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh bìa truyện
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.coverUrl!,
                    width: 52,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 52,
                    height: 72,
                    color: AppColors.darkBackground,
                    child: const Icon(Icons.book_rounded, color: AppColors.darkTextMuted),
                  ),
          ),
          const SizedBox(width: 12),
          // Thông tin tiến độ đọc
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TIẾP TỤC ĐỌC',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(item.readPercentage * 100).toInt()}%',
                      style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.comicTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chương ${item.chapterNumber} • Trang ${item.lastPageRead}/${item.totalPages}',
                  style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: item.readPercentage.clamp(0.0, 1.0),
                    backgroundColor: AppColors.darkBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Nút Đọc tiếp
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            tooltip: 'Đọc tiếp ngay',
            onPressed: () {
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
              ).then((_) => _loadLastReadComic());
            },
          ),
        ],
      ),
    );
  }
}
