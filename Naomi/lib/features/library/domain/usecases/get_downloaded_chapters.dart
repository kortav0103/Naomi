import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/downloaded_chapter.dart';
import '../repositories/library_repository.dart';

class GetDownloadedChapters {
  final LibraryRepository repository;

  GetDownloadedChapters(this.repository);

  Future<Either<Failure, List<DownloadedChapter>>> call() {
    return repository.getDownloadedChapters();
  }
}
