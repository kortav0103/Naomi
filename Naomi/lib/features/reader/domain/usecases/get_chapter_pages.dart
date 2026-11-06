import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chapter_pages.dart';
import '../repositories/reader_repository.dart';

class GetChapterPages {
  final ReaderRepository repository;

  GetChapterPages(this.repository);

  Future<Either<Failure, ChapterPages>> call({required String chapterId}) {
    return repository.getChapterPages(chapterId: chapterId);
  }
}