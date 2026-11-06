import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
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
  String _selectedGenre = 'All';

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
    context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (value.trim().isEmpty) {
      context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent());
    } else {
      context.read<DiscoverBloc>().add(SearchComicsEvent(value.trim()));
    }
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
              context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar (FR-01)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
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
                          _onSearch('');
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

          // 2. Genre Chips Bar
          SizedBox(
            height: 44,
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

          // 3. Grid Danh sách truyện
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
                            onPressed: () => context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent()),
                            child: const Text('Xem danh mục thịnh hành', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.darkSurface,
                    onRefresh: () async {
                      context.read<DiscoverBloc>().add(const LoadTrendingComicsEvent());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                state.activeFilterTitle,
                                style: const TextStyle(
                                  fontSize: 16,
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
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.comics.length,
                            itemBuilder: (context, index) {
                              final comic = state.comics[index];
                              return ComicCard(
                                comic: comic,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ComicDetailScreen(comicId: comic.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
    );
  }
}
