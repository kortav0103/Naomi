import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/comic.dart';
import '../repositories/comic_repository.dart';

class GetTrendingComics {
  final ComicRepository repository;

  GetTrendingComics(this.repository);

  Future<Either<Failure, List<Comic>>> call({int limit = 20, int offset = 0}) {
    return repository.getTrendingComics(limit: limit, offset: offset);
  }
}
