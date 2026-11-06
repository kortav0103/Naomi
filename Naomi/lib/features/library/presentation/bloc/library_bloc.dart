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
  }) : super(LibraryInitial()) {
    on<LoadLibraryEvent>(_onLoadLibrary);
    on<ToggleBookmarkEvent>(_onToggleBookmark);
    on<DeleteDownloadedChapterEvent>(_onDeleteDownloadedChapter);
  }

  Future<void> _onLoadLibrary(
    LoadLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());

    final bookmarksResult = await getBookmarks();
    final downloadsResult = await getDownloadedChapters();

    bookmarksResult.fold(
      (failure) => emit(LibraryError(failure.message)),
      (bookmarks) {
        downloadsResult.fold(
          (failure) => emit(LibraryError(failure.message)),
          (downloads) => emit(LibraryLoaded(bookmarks: bookmarks, downloads: downloads)),
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
    // Tự động tải lại danh sách tủ sách sau khi thả tim/bỏ tim
    add(const LoadLibraryEvent());
  }

  Future<void> _onDeleteDownloadedChapter(
    DeleteDownloadedChapterEvent event,
    Emitter<LibraryState> emit,
  ) async {
    await repository.deleteDownloadedChapter(chapterId: event.chapterId);
    // Tải lại danh sách sau khi xóa
    add(const LoadLibraryEvent());
  }
}
