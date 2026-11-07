import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naomi/core/errors/failures.dart';
import 'package:naomi/features/library/domain/entities/bookmark.dart';
import 'package:naomi/features/library/domain/entities/downloaded_chapter.dart';
import 'package:naomi/features/library/domain/entities/reading_history_item.dart';
import 'package:naomi/features/library/domain/repositories/library_repository.dart';
import 'package:naomi/features/library/domain/usecases/get_bookmarks.dart';
import 'package:naomi/features/library/domain/usecases/get_downloaded_chapters.dart';
import 'package:naomi/features/library/domain/usecases/toggle_bookmark.dart';
import 'package:naomi/features/library/presentation/bloc/library_bloc.dart';
import 'package:naomi/features/library/presentation/bloc/library_event.dart';
import 'package:naomi/features/library/presentation/bloc/library_state.dart';

class FakeLibraryRepository implements LibraryRepository {
  @override
  Future<Either<Failure, List<Bookmark>>> getBookmarks() async => const Right([]);

  @override
  Future<Either<Failure, bool>> isBookmarked({required String comicId}) async => const Right(true);

  @override
  Future<Either<Failure, bool>> toggleBookmark({
    required String comicId,
    required String title,
    String? coverUrl,
    required String author,
  }) async => const Right(true);

  @override
  Future<Either<Failure, List<DownloadedChapter>>> getDownloadedChapters() async => const Right([]);

  @override
  Future<Either<Failure, void>> deleteDownloadedChapter({required String chapterId}) async => const Right(null);

  @override
  Future<Either<Failure, bool>> isChapterDownloaded({required String chapterId}) async => const Right(true);

  @override
  Future<Either<Failure, void>> downloadChapter({
    required String comicId,
    required String comicTitle,
    String? coverUrl,
    required String author,
    required String chapterId,
    required String chapterNumber,
    required String chapterTitle,
    void Function(int downloaded, int total)? onProgress,
  }) async => const Right(null);

  @override
  Future<Either<Failure, List<ReadingHistoryItem>>> getReadingHistory() async => const Right([]);

  @override
  Future<Either<Failure, ReadingHistoryItem?>> getLastReadComic() async => const Right(null);

  @override
  Future<Either<Failure, void>> clearReadingHistory() async => const Right(null);

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
  }) async => const Right(null);
}

class FakeSuccessGetBookmarks extends GetBookmarks {
  final List<Bookmark> bookmarks;
  FakeSuccessGetBookmarks(this.bookmarks) : super(FakeLibraryRepository());

  @override
  Future<Either<Failure, List<Bookmark>>> call() async => Right(bookmarks);
}

class FakeFailureGetBookmarks extends GetBookmarks {
  final String errorMessage;
  FakeFailureGetBookmarks(this.errorMessage) : super(FakeLibraryRepository());

  @override
  Future<Either<Failure, List<Bookmark>>> call() async => Left(CacheFailure(errorMessage));
}

class FakeSuccessGetDownloadedChapters extends GetDownloadedChapters {
  final List<DownloadedChapter> downloads;
  FakeSuccessGetDownloadedChapters(this.downloads) : super(FakeLibraryRepository());

  @override
  Future<Either<Failure, List<DownloadedChapter>>> call() async => Right(downloads);
}

class FakeSuccessToggleBookmark extends ToggleBookmark {
  FakeSuccessToggleBookmark() : super(FakeLibraryRepository());

  @override
  Future<Either<Failure, bool>> call({
    required String comicId,
    required String title,
    String? coverUrl,
    required String author,
  }) async => const Right(true);
}

void main() {
  const tBookmark = Bookmark(
    comicId: 'comic-1',
    title: 'Sousou no Frieren',
    coverUrl: 'https://mangadex.org/covers/frieren.jpg',
    author: 'Yamada Kanehito',
    addedAt: '2026-11-06T12:00:00Z',
  );

  const tDownload = DownloadedChapter(
    chapterId: 'ch-1',
    comicTitle: 'Sousou no Frieren',
    chapterNumber: '1',
    localDirectory: '/data/user/0/naomi/ch-1',
    totalPages: 45,
    downloadedAt: '2026-11-06T12:30:00Z',
  );

  final fakeRepo = FakeLibraryRepository();

  group('LibraryBloc Unit Tests', () {
    test('Trạng thái khởi tạo ban đầu phải là LibraryInitial', () {
      final bloc = LibraryBloc(
        getBookmarks: FakeSuccessGetBookmarks([tBookmark]),
        getDownloadedChapters: FakeSuccessGetDownloadedChapters([tDownload]),
        toggleBookmark: FakeSuccessToggleBookmark(),
        repository: fakeRepo,
      );

      expect(bloc.state, isA<LibraryInitial>());
      bloc.close();
    });

    test('Phát ra [LibraryLoading, LibraryLoaded] khi nạp tủ sách thành công', () async {
      final bloc = LibraryBloc(
        getBookmarks: FakeSuccessGetBookmarks([tBookmark]),
        getDownloadedChapters: FakeSuccessGetDownloadedChapters([tDownload]),
        toggleBookmark: FakeSuccessToggleBookmark(),
        repository: fakeRepo,
      );

      final expectedStates = [
        isA<LibraryLoading>(),
        isA<LibraryLoaded>()
            .having((s) => s.bookmarks.length, 'bookmarks count', 1)
            .having((s) => s.downloads.length, 'downloads count', 1),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadLibraryEvent());
    });

    test('Phát ra [LibraryLoading, LibraryError] khi truy xuất CSDL SQLite thất bại', () async {
      final bloc = LibraryBloc(
        getBookmarks: FakeFailureGetBookmarks('Lỗi truy xuất CSDL'),
        getDownloadedChapters: FakeSuccessGetDownloadedChapters([tDownload]),
        toggleBookmark: FakeSuccessToggleBookmark(),
        repository: fakeRepo,
      );

      final expectedStates = [
        isA<LibraryLoading>(),
        const LibraryError('Lỗi truy xuất CSDL'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadLibraryEvent());
    });
  });
}
