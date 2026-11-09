import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chapter.dart';
import '../entities/comic.dart';

/// Hợp đồng trừu tượng định nghĩa các nghiệp vụ truy xuất truyện tranh
abstract class ComicRepository {
  /// Lấy danh sách truyện thịnh hành (Trending) từ MangaDex
  Future<Either<Failure, List<Comic>>> getTrendingComics({
    int limit = 20,
    int offset = 0,
  });

  /// Tìm kiếm truyện theo từ khóa tên tác phẩm hoặc tác giả (FR-01)
  Future<Either<Failure, List<Comic>>> searchComics({
    required String query,
    int limit = 20,
    int offset = 0,
  });

  /// Lọc truyện theo thể loại (Genre ID)
  Future<Either<Failure, List<Comic>>> getComicsByGenre({
    required String genreTagId,
    int limit = 20,
    int offset = 0,
  });

  /// Lấy danh sách các chương của một bộ truyện (FR-10)
  Future<Either<Failure, List<Chapter>>> getComicChapters({
    required String comicId,
    List<String> languages = const ['en'],
  });

  /// Lấy thông tin chi tiết một bộ truyện
  Future<Either<Failure, Comic>> getComicDetail({
    required String comicId,
  });
}
