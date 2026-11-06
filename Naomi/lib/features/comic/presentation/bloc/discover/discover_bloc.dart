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

  DiscoverBloc({
    required this.getTrendingComics,
    required this.searchComics,
    required this.repository,
  }) : super(DiscoverInitial()) {
    on<LoadTrendingComicsEvent>(_onLoadTrending);
    on<SearchComicsEvent>(_onSearchComics);
    on<FilterComicsByGenreEvent>(_onFilterByGenre);
  }

  Future<void> _onLoadTrending(
    LoadTrendingComicsEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    final result = await getTrendingComics();
    result.fold(
      (failure) => emit(DiscoverError(failure.message)),
      (comics) => emit(DiscoverLoaded(comics: comics, activeFilterTitle: 'Trending Now')),
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

    emit(DiscoverLoading());
    final result = await searchComics(query: event.query);
    result.fold(
      (failure) => emit(DiscoverError(failure.message)),
      (comics) => emit(DiscoverLoaded(comics: comics, activeFilterTitle: 'Kết quả: "${event.query}"')),
    );
  }

  Future<void> _onFilterByGenre(
    FilterComicsByGenreEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    final result = await repository.getComicsByGenre(genreTagId: event.genreTagId);
    result.fold(
      (failure) => emit(DiscoverError(failure.message)),
      (comics) => emit(DiscoverLoaded(comics: comics, activeFilterTitle: 'Thể loại: ${event.genreName}')),
    );
  }
}
