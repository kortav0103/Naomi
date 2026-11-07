import 'package:equatable/equatable.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/downloaded_chapter.dart';
import '../../domain/entities/reading_history_item.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

class LibraryLoaded extends LibraryState {
  final List<Bookmark> bookmarks;
  final List<DownloadedChapter> downloads;
  final List<ReadingHistoryItem> history;

  const LibraryLoaded({
    required this.bookmarks,
    required this.downloads,
    this.history = const [],
  });

  @override
  List<Object?> get props => [bookmarks, downloads, history];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
