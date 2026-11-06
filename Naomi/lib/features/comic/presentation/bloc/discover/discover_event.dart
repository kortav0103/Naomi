import 'package:equatable/equatable.dart';

abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrendingComicsEvent extends DiscoverEvent {
  const LoadTrendingComicsEvent();
}

class SearchComicsEvent extends DiscoverEvent {
  final String query;
  const SearchComicsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterComicsByGenreEvent extends DiscoverEvent {
  final String genreTagId;
  final String genreName;
  const FilterComicsByGenreEvent({required this.genreTagId, required this.genreName});

  @override
  List<Object?> get props => [genreTagId, genreName];
}
