import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chapter.dart';
import '../repositories/comic_repository.dart';

class GetComicChapters {
  final ComicRepository repository;

  GetComicChapters(this.repository);

  Future<Either<Failure, List<Chapter>>> call({
    required String comicId,
    List<String> languages = const ['vi', 'en'],
  }) {
    return repository.getComicChapters(comicId: comicId, languages: languages);
  }
}
