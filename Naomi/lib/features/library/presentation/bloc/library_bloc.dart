import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/usecases/get_bookmarks.dart';
import '../../domain/usecases/get_downloaded_chapters.dart';
import '../../domain/usecases/toggle_bookmark.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetBookmarks getBookmarks;
  final GetDownloadedChapters getDownloadedChapters;
  final ToggleBookmark toggleBookmark;
  final LibraryRepository repository;

  LibraryBloc({
    required this.getBookmarks,
    required this.getDownloadedChapters,
    required this.toggleBookmark,
    required this.repository,
  }) : super(const LibraryInitial()) {
    on<LoadLibraryEvent>(_onLoadLibrary);
    on<ToggleBookmarkEvent>(_onToggleBookmark);
    on<DeleteDownloadedChapterEvent>(_onDeleteDownloadedChapter);
    on<ClearReadingHistoryEvent>(_onClearReadingHistory);
  }

  Future<void> _onLoadLibrary(
    LoadLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    final bookmarksResult = await getBookmarks();
    final downloadsResult = await getDownloadedChapters();
    final historyResult = await repository.getReadingHistory();

    bookmarksResult.fold(
      (failure) => emit(LibraryError(failure.message)),
      (bookmarks) {
        downloadsResult.fold(
          (failure) => emit(LibraryError(failure.message)),
          (downloads) {
            final history = historyResult.getOrElse(() => []);
            emit(LibraryLoaded(
              bookmarks: bookmarks,
              downloads: downloads,
              history: history,
            ));
          },
        );
      },
    );
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<LibraryState> emit,
  ) async {
    await toggleBookmark(
      comicId: event.comicId,
      title: event.title,
      coverUrl: event.coverUrl,
      author: event.author,
    );
    add(const LoadLibraryEvent());
  }

  Future<void> _onDeleteDownloadedChapter(
    DeleteDownloadedChapterEvent event,
    Emitter<LibraryState> emit,
  ) async {
    await repository.deleteDownloadedChapter(chapterId: event.chapterId);
    add(const LoadLibraryEvent());
  }

  Future<void> _onClearReadingHistory(
    ClearReadingHistoryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    await repository.clearReadingHistory();
    add(const LoadLibraryEvent());
  }
}
