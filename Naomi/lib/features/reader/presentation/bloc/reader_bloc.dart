import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reader_repository.dart';
import '../../domain/usecases/get_chapter_pages.dart';
import '../../domain/usecases/save_reading_progress.dart';
import 'reader_event.dart';
import 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final GetChapterPages getChapterPages;
  final SaveReadingProgress saveReadingProgress;
  final ReaderRepository repository;

  ReaderBloc({
    required this.getChapterPages,
    required this.saveReadingProgress,
    required this.repository,
  }) : super(ReaderInitial()) {
    on<LoadChapterPagesEvent>(_onLoadChapterPages);
    on<ChangePageEvent>(_onChangePage);
    on<ToggleReaderModeEvent>(_onToggleReaderMode);
    on<ToggleReadingDirectionEvent>(_onToggleReadingDirection);
    on<ToggleFocusModeEvent>(_onToggleFocusMode);
    on<ToggleDataSaverEvent>(_onToggleDataSaver);
  }

  Future<void> _onLoadChapterPages(
    LoadChapterPagesEvent event,
    Emitter<ReaderState> emit,
  ) async {
    emit(ReaderLoading());

    final result = await getChapterPages(chapterId: event.chapterId);

    await result.fold(
      (failure) async => emit(ReaderError(failure.message)),
      (pages) async {
        // Đọc lại vị trí trang đọc dở từ SQLite (FR-04)
        final savedPageResult = await repository.getSavedPageProgress(chapterId: event.chapterId);
        final initialPage = savedPageResult.getOrElse(() => 1);

        emit(ReaderLoaded(
          pages: pages,
          currentPage: initialPage,
          comicId: event.comicId,
          comicTitle: event.comicTitle,
          coverUrl: event.coverUrl,
          chapterNumber: event.chapterNumber,
        ));

        // Lưu ngay tiến trình ban đầu để ghi nhận vào Lịch sử đọc dở (FR-08)
        if (event.comicId.isNotEmpty) {
          final total = pages.totalPages;
          final percentage = total > 0 ? (initialPage / total) : 0.0;
          await saveReadingProgress(
            comicId: event.comicId,
            chapterId: event.chapterId,
            comicTitle: event.comicTitle,
            coverUrl: event.coverUrl,
            chapterNumber: event.chapterNumber,
            lastPageRead: initialPage,
            totalPages: total,
            readPercentage: percentage,
            isCompleted: initialPage >= total,
          );
        }
      },
    );
  }

  Future<void> _onChangePage(
    ChangePageEvent event,
    Emitter<ReaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is ReaderLoaded) {
      final newPage = event.pageIndex + 1;
      emit(currentState.copyWith(currentPage: newPage));

      // Tự động lưu tiến trình vào SQLite ngầm (FR-04, FR-08)
      final total = currentState.pages.totalPages;
      final percentage = total > 0 ? (newPage / total) : 0.0;
      final isCompleted = newPage >= total;

      if (currentState.comicId.isNotEmpty) {
        saveReadingProgress(
          comicId: currentState.comicId,
          chapterId: currentState.pages.chapterId,
          comicTitle: currentState.comicTitle,
          coverUrl: currentState.coverUrl,
          chapterNumber: currentState.chapterNumber,
          lastPageRead: newPage,
          totalPages: total,
          readPercentage: percentage,
          isCompleted: isCompleted,
        );
      }
    }
  }

  void _onToggleReaderMode(
    ToggleReaderModeEvent event,
    Emitter<ReaderState> emit,
  ) {
    final currentState = state;
    if (currentState is ReaderLoaded) {
      emit(currentState.copyWith(isWebtoonMode: !currentState.isWebtoonMode));
    }
  }

  void _onToggleReadingDirection(
    ToggleReadingDirectionEvent event,
    Emitter<ReaderState> emit,
  ) {
    final currentState = state;
    if (currentState is ReaderLoaded) {
      emit(currentState.copyWith(isRTL: !currentState.isRTL));
    }
  }

  void _onToggleFocusMode(
    ToggleFocusModeEvent event,
    Emitter<ReaderState> emit,
  ) {
    final currentState = state;
    if (currentState is ReaderLoaded) {
      emit(currentState.copyWith(isFocusMode: !currentState.isFocusMode));
    }
  }

  void _onToggleDataSaver(
    ToggleDataSaverEvent event,
    Emitter<ReaderState> emit,
  ) {
    final currentState = state;
    if (currentState is ReaderLoaded) {
      emit(currentState.copyWith(isDataSaver: !currentState.isDataSaver));
    }
  }
}
