import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/comic.dart';
import '../../domain/repositories/comic_repository.dart';
import '../datasources/mangadex_remote_data_source.dart';

class ComicRepositoryImpl implements ComicRepository {
  final MangaDexRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  ComicRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<bool> _isConnected() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  @override
  Future<Either<Failure, List<Comic>>> getTrendingComics({int limit = 20, int offset = 0}) async {
    if (!await _isConnected()) {
      return const Left(NetworkFailure('Không có kết nối mạng để nạp truyện thịnh hành.'));
    }

    try {
      final remoteComics = await remoteDataSource.getTrendingComics(limit: limit, offset: offset);
      return Right(remoteComics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Comic>>> searchComics({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    if (!await _isConnected()) {
      return const Left(NetworkFailure('Vui lòng kết nối mạng để tìm kiếm truyện.'));
    }

    try {
      final remoteComics = await remoteDataSource.searchComics(query: query, limit: limit, offset: offset);
      return Right(remoteComics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Comic>>> getComicsByGenre({
    required String genreTagId,
    int limit = 20,
    int offset = 0,
  }) async {
    if (!await _isConnected()) {
      return const Left(NetworkFailure('Vui lòng kết nối mạng để lọc theo thể loại.'));
    }

    try {
      final remoteComics = await remoteDataSource.getComicsByGenre(genreTagId: genreTagId, limit: limit, offset: offset);
      return Right(remoteComics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Chapter>>> getComicChapters({
    required String comicId,
    List<String> languages = const ['vi', 'en'],
  }) async {
    if (!await _isConnected()) {
      return const Left(NetworkFailure('Không có kết nối mạng để tải danh sách chương.'));
    }

    try {
      final chapters = await remoteDataSource.getComicChapters(comicId: comicId, languages: languages);
      return Right(chapters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Comic>> getComicDetail({required String comicId}) async {
    if (!await _isConnected()) {
      return const Left(NetworkFailure('Không có kết nối mạng để xem chi tiết truyện.'));
    }

    try {
      final comic = await remoteDataSource.getComicDetail(comicId: comicId);
      return Right(comic);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
