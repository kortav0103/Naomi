import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bookmark.dart';
import '../repositories/library_repository.dart';

class GetBookmarks {
  final LibraryRepository repository;

  GetBookmarks(this.repository);

  Future<Either<Failure, List<Bookmark>>> call() {
    return repository.getBookmarks();
  }
}
