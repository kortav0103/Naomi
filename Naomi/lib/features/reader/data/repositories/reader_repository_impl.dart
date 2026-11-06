import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chapter_pages.dart';
import '../../domain/repositories/reader_repository.dart';
import '../datasources/reader_local_data_source.dart';
import '../datasources/reader_remote_data_source.dart';

class ReaderRepositoryImpl implements ReaderRepository {
  final ReaderRemoteDataSource remoteDataSource;
  final ReaderLocalDataSource localDataSource;
  final Connectivity connectivity;

  ReaderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  Future<bool> _isConnected() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  @override
  Future<Either<Failure, ChapterPages>> getChapterPages({required String chapterId}) async {
    if (!await _isConnected()) {
      return const Left(NetworkFailure('Không có kết nối mạng để tải các trang truyện.'));
    }

    try {
      final pagesModel = await remoteDataSource.getChapterPages(chapterId);
      return Right(pagesModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveReadingProgress({
    required String chapterId,
    required int lastPageRead,
    required double readPercentage,
    bool isCompleted = false,
  }) async {
    try {
      await localDataSource.saveProgress(
        chapterId: chapterId,
        lastPageRead: lastPageRead,
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

  @override
  Future<Either<Failure, int>> getSavedPageProgress({required String chapterId}) async {
    try {
      final page = await localDataSource.getSavedProgress(chapterId);
      return Right(page);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}