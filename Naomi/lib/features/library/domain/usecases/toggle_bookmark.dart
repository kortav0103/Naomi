import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/library_repository.dart';

class ToggleBookmark {
  final LibraryRepository repository;

  ToggleBookmark(this.repository);

  Future<Either<Failure, bool>> call({
    required String comicId,
    required String title,
    String? coverUrl,
    required String author,
  }) {
    return repository.toggleBookmark(
      comicId: comicId,
      title: title,
      coverUrl: coverUrl,
      author: author,
    );
  }
}
