import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/downloaded_chapter.dart';
import '../../domain/entities/reading_history_item.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_data_source.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource localDataSource;

  LibraryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Bookmark>>> getBookmarks() async {
    try {
      final bookmarks = await localDataSource.getBookmarks();
      return Right(bookmarks);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBookmarked({required String comicId}) async {
    try {
      final isFav = await localDataSource.isBookmarked(comicId);
      return Right(isFav);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleBookmark({
    required String comicId,
    required String title,
    String? coverUrl,
    required String author,
  }) async {
    try {
      final isNowBookmarked = await localDataSource.toggleBookmark(
        comicId: comicId,
        title: title,
        coverUrl: coverUrl,
        author: author,
      );
      return Right(isNowBookmarked);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DownloadedChapter>>> getDownloadedChapters() async {
    try {
      final downloads = await localDataSource.getDownloadedChapters();
      return Right(downloads);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDownloadedChapter({required String chapterId}) async {
    try {
      await localDataSource.deleteDownloadedChapter(chapterId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isChapterDownloaded({required String chapterId}) async {
    try {
      final downloaded = await localDataSource.isChapterDownloaded(chapterId);
      return Right(downloaded);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> downloadChapter({
    required String comicId,
    required String comicTitle,
    String? coverUrl,
    required String author,
    required String chapterId,
    required String chapterNumber,
    required String chapterTitle,
  }) async {
    try {
      await localDataSource.downloadChapter(
        comicId: comicId,
        comicTitle: comicTitle,
        coverUrl: coverUrl,
        author: author,
        chapterId: chapterId,
        chapterNumber: chapterNumber,
        chapterTitle: chapterTitle,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReadingHistoryItem>>> getReadingHistory() async {
    try {
      final history = await localDataSource.getReadingHistory();
      return Right(history);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReadingHistoryItem?>> getLastReadComic() async {
    try {
      final item = await localDataSource.getLastReadComic();
      return Right(item);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearReadingHistory() async {
    try {
      await localDataSource.clearReadingHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
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
    try {
      await localDataSource.saveReadingProgress(
        comicId: comicId,
        chapterId: chapterId,
        comicTitle: comicTitle,
        coverUrl: coverUrl,
        chapterNumber: chapterNumber,
        lastPageRead: lastPageRead,
        totalPages: totalPages,
        readPercentage: readPercentage,
        isCompleted: isCompleted,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
