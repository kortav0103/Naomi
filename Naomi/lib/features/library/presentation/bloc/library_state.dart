import 'package:equatable/equatable.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/downloaded_chapter.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Bookmark> bookmarks;
  final List<DownloadedChapter> downloads;

  const LibraryLoaded({
    required this.bookmarks,
    required this.downloads,
  });

  @override
  List<Object?> get props => [bookmarks, downloads];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
