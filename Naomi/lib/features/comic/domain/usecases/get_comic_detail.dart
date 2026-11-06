import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/comic.dart';
import '../repositories/comic_repository.dart';

class GetComicDetail {
  final ComicRepository repository;

  GetComicDetail(this.repository);

  Future<Either<Failure, Comic>> call({required String comicId}) {
    return repository.getComicDetail(comicId: comicId);
  }
}
