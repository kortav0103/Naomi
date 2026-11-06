import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/comic.dart';
import '../repositories/comic_repository.dart';

class SearchComics {
  final ComicRepository repository;

  SearchComics(this.repository);

  Future<Either<Failure, List<Comic>>> call({
    required String query,
    int limit = 20,
    int offset = 0,
  }) {
    return repository.searchComics(query: query, limit: limit, offset: offset);
  }
}
