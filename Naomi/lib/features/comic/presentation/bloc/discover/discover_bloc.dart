import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_trending_comics.dart';
import '../../../domain/usecases/search_comics.dart';
import '../../../domain/repositories/comic_repository.dart';
import 'discover_event.dart';
import 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final GetTrendingComics getTrendingComics;
  final SearchComics searchComics;
  final ComicRepository repository;

  static const int _pageSize = 20;

  DiscoverBloc({
    required this.getTrendingComics,
    required this.searchComics,
    required this.repository,
  }) : super(const DiscoverInitial()) {
    on<LoadTrendingComicsEvent>(_onLoadTrending);
    on<SearchComicsEvent>(_onSearchComics);
    on<FilterComicsByGenreEvent>(_onFilterByGenre);
    on<LoadMoreComicsEvent>(_onLoadMoreComics);
  }

  Future<void> _onLoadTrending(
    LoadTrendingComicsEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(const DiscoverLoading());
    final result = await getTrendingComics(limit: _pageSize, offset: 0);
    result.fold(
      (failure) => emit(DiscoverError(failure.message)),
      (comics) => emit(DiscoverLoaded(
        comics: comics,
        activeFilterTitle: 'Trending Now',
        currentOffset: comics.length,
      )),
    );
  }

  Future<void> _onSearchComics(
    SearchComicsEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const LoadTrendingComicsEvent());
      return;
    }

    final trimmed = event.query.trim();
    emit(const DiscoverLoading());
    final result = await searchComics(query: trimmed, limit: _pageSize, offset: 0);
    result.fold(
      (failure) => emit(DiscoverError(failure.message)),
      (comics) => emit(DiscoverLoaded(
        comics: comics,
        activeFilterTitle: 'Kết quả: "$trimmed"',
        currentOffset: comics.length,
        currentQuery: trimmed,
      )),
    );
  }

  Future<void> _onFilterByGenre(
    FilterComicsByGenreEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(const DiscoverLoading());
    final result = await repository.getComicsByGenre(
      genreTagId: event.genreTagId,
      limit: _pageSize,
      offset: 0,
    );
    result.fold(
      (failure) => emit(DiscoverError(failure.message)),
      (comics) => emit(DiscoverLoaded(
        comics: comics,
        activeFilterTitle: 'Thể loại: ${event.genreName}',
        currentOffset: comics.length,
        currentGenreId: event.genreTagId,
      )),
    );
  }

  Future<void> _onLoadMoreComics(
    LoadMoreComicsEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DiscoverLoaded) return;
    if (currentState.isLoadingMore || currentState.hasReachedMax) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextOffset = currentState.currentOffset;
    final result = currentState.currentQuery.isNotEmpty
        ? await searchComics(
            query: currentState.currentQuery,
            limit: _pageSize,
            offset: nextOffset,
          )
        : currentState.currentGenreId.isNotEmpty
            ? await repository.getComicsByGenre(
                genreTagId: currentState.currentGenreId,
                limit: _pageSize,
                offset: nextOffset,
              )
            : await getTrendingComics(
                limit: _pageSize,
                offset: nextOffset,
              );

    result.fold(
      (_) => emit(currentState.copyWith(isLoadingMore: false, hasReachedMax: true)),
      (moreComics) {
        if (moreComics.isEmpty) {
          emit(currentState.copyWith(isLoadingMore: false, hasReachedMax: true));
        } else {
          final existingIds = currentState.comics.map((c) => c.id).toSet();
          final uniqueNew = moreComics.where((c) => !existingIds.contains(c.id)).toList();
          emit(currentState.copyWith(
            comics: [...currentState.comics, ...uniqueNew],
            currentOffset: nextOffset + moreComics.length,
            isLoadingMore: false,
            hasReachedMax: moreComics.length < _pageSize,
          ));
        }
      },
    );
  }
}
