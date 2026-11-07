import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naomi/core/errors/failures.dart';
import 'package:naomi/features/reader/domain/entities/chapter_pages.dart';
import 'package:naomi/features/reader/domain/repositories/reader_repository.dart';
import 'package:naomi/features/reader/domain/usecases/get_chapter_pages.dart';
import 'package:naomi/features/reader/domain/usecases/save_reading_progress.dart';
import 'package:naomi/features/reader/presentation/bloc/reader_bloc.dart';
import 'package:naomi/features/reader/presentation/bloc/reader_event.dart';
import 'package:naomi/features/reader/presentation/bloc/reader_state.dart';

class FakeReaderRepository implements ReaderRepository {
  @override
  Future<Either<Failure, ChapterPages>> getChapterPages({required String chapterId}) async {
    return const Right(ChapterPages(
      chapterId: 'ch-1',
      baseUrl: 'https://uploads.mangadex.org',
      chapterHash: 'hash123',
      pageFilenames: ['1.jpg', '2.jpg', '3.jpg'],
      dataSaverFilenames: ['1.jpg', '2.jpg', '3.jpg'],
    ));
  }

  @override
  Future<Either<Failure, void>> saveReadingProgress({
    required String comicId,
    required String chapterId,
    required String comicTitle,
    String? coverUrl,
    required String chapterNumber,
    required int lastPageRead,
    required int totalPages,
    required double readPercentage,
    bool isCompleted = false,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, int>> getSavedPageProgress({required String chapterId}) async {
    return const Right(1);
  }
}

class FakeSuccessGetChapterPages extends GetChapterPages {
  final ChapterPages pages;
  FakeSuccessGetChapterPages(this.pages) : super(FakeReaderRepository());

  @override
  Future<Either<Failure, ChapterPages>> call({required String chapterId}) async {
    return Right(pages);
  }
}

class FakeSuccessSaveReadingProgress extends SaveReadingProgress {
  FakeSuccessSaveReadingProgress() : super(FakeReaderRepository());

  @override
  Future<Either<Failure, void>> call({
    required String comicId,
    required String chapterId,
    required String comicTitle,
    String? coverUrl,
    required String chapterNumber,
    required int lastPageRead,
    required int totalPages,
    required double readPercentage,
    bool isCompleted = false,
  }) async {
    return const Right(null);
  }
}

/// Lớp kiểm thử mở rộng cho phép emit trạng thái phục vụ kiểm thử
class TestReaderBloc extends ReaderBloc {
  TestReaderBloc({
    required super.getChapterPages,
    required super.saveReadingProgress,
    required super.repository,
  });

  void emitState(ReaderState state) => emit(state);
}

void main() {
  const tPages = ChapterPages(
    chapterId: 'ch-123',
    baseUrl: 'https://uploads.mangadex.org',
    chapterHash: 'hash-abc',
    pageFilenames: ['page1.jpg', 'page2.jpg', 'page3.jpg'],
    dataSaverFilenames: ['page1.jpg', 'page2.jpg', 'page3.jpg'],
  );

  final fakeRepo = FakeReaderRepository();

  group('ReaderBloc Unit Tests', () {
    test('Trạng thái khởi tạo ban đầu phải là ReaderInitial', () {
      final bloc = TestReaderBloc(
        getChapterPages: FakeSuccessGetChapterPages(tPages),
        saveReadingProgress: FakeSuccessSaveReadingProgress(),
        repository: fakeRepo,
      );

      expect(bloc.state, isA<ReaderInitial>());
      bloc.close();
    });

    test('Phát ra [ReaderLoading, ReaderLoaded] khi nạp các trang truyện thành công', () async {
      final bloc = TestReaderBloc(
        getChapterPages: FakeSuccessGetChapterPages(tPages),
        saveReadingProgress: FakeSuccessSaveReadingProgress(),
        repository: fakeRepo,
      );

      final expectedStates = [
        isA<ReaderLoading>(),
        isA<ReaderLoaded>()
            .having((s) => s.pages.totalPages, 'totalPages', 3)
            .having((s) => s.currentPage, 'currentPage', 1),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadChapterPagesEvent(chapterId: 'ch-123'));
    });

    test('Cập nhật currentPage khi phát sự kiện ChangePageEvent', () async {
      final bloc = TestReaderBloc(
        getChapterPages: FakeSuccessGetChapterPages(tPages),
        saveReadingProgress: FakeSuccessSaveReadingProgress(),
        repository: fakeRepo,
      );

      bloc.emitState(const ReaderLoaded(pages: tPages, currentPage: 1));

      final expectedStates = [
        isA<ReaderLoaded>().having((s) => s.currentPage, 'currentPage', 2),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const ChangePageEvent(1)); // Chuyển sang trang 2 (index 1)
    });

    test('Chuyển đổi chế độ Webtoon <-> Manga khi phát ToggleReaderModeEvent', () async {
      final bloc = TestReaderBloc(
        getChapterPages: FakeSuccessGetChapterPages(tPages),
        saveReadingProgress: FakeSuccessSaveReadingProgress(),
        repository: fakeRepo,
      );

      bloc.emitState(const ReaderLoaded(pages: tPages, isWebtoonMode: true));

      final expectedStates = [
        isA<ReaderLoaded>().having((s) => s.isWebtoonMode, 'isWebtoonMode', false),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const ToggleReaderModeEvent());
    });

    test('Chuyển đổi chế độ Tiết kiệm 4G (Data Saver) khi phát ToggleDataSaverEvent', () async {
      final bloc = TestReaderBloc(
        getChapterPages: FakeSuccessGetChapterPages(tPages),
        saveReadingProgress: FakeSuccessSaveReadingProgress(),
        repository: fakeRepo,
      );

      bloc.emitState(const ReaderLoaded(pages: tPages, isDataSaver: false));

      final expectedStates = [
        isA<ReaderLoaded>().having((s) => s.isDataSaver, 'isDataSaver', true),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const ToggleDataSaverEvent());
    });

    test('Bật/tắt Focus Mode khi phát ToggleFocusModeEvent', () async {
      final bloc = TestReaderBloc(
        getChapterPages: FakeSuccessGetChapterPages(tPages),
        saveReadingProgress: FakeSuccessSaveReadingProgress(),
        repository: fakeRepo,
      );

      bloc.emitState(const ReaderLoaded(pages: tPages, isFocusMode: false));

      final expectedStates = [
        isA<ReaderLoaded>().having((s) => s.isFocusMode, 'isFocusMode', true),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const ToggleFocusModeEvent());
    });
  });
}
