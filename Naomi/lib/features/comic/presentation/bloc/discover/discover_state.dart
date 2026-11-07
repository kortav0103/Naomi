import 'package:equatable/equatable.dart';
import '../../../domain/entities/comic.dart';

abstract class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object?> get props => [];
}

class DiscoverInitial extends DiscoverState {
  const DiscoverInitial();
}

class DiscoverLoading extends DiscoverState {
  const DiscoverLoading();
}

class DiscoverLoaded extends DiscoverState {
  final List<Comic> comics;
  final String activeFilterTitle; // "Trending Now", "Kết quả: ...", hoặc "Thể loại: ..."
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int currentOffset;
  final String currentQuery;
  final String currentGenreId;

  const DiscoverLoaded({
    required this.comics,
    this.activeFilterTitle = 'Trending Now',
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.currentOffset = 0,
    this.currentQuery = '',
    this.currentGenreId = '',
  });

  DiscoverLoaded copyWith({
    List<Comic>? comics,
    String? activeFilterTitle,
    bool? hasReachedMax,
    bool? isLoadingMore,
    int? currentOffset,
    String? currentQuery,
    String? currentGenreId,
  }) {
    return DiscoverLoaded(
      comics: comics ?? this.comics,
      activeFilterTitle: activeFilterTitle ?? this.activeFilterTitle,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentOffset: currentOffset ?? this.currentOffset,
      currentQuery: currentQuery ?? this.currentQuery,
      currentGenreId: currentGenreId ?? this.currentGenreId,
    );
  }

  @override
  List<Object?> get props => [
        comics,
        activeFilterTitle,
        hasReachedMax,
        isLoadingMore,
      ];
}

class DiscoverError extends DiscoverState {
  final String message;
  const DiscoverError(this.message);

  @override
  List<Object?> get props => [message];
}
