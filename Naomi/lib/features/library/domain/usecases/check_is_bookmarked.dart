import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/library_repository.dart';

/// UseCase kiểm tra xem truyện đã được lưu trong Tủ sách (Bookmarks) chưa
class CheckIsBookmarked {
  final LibraryRepository repository;

  CheckIsBookmarked(this.repository);

  Future<Either<Failure, bool>> call(String comicId) {
    return repository.isBookmarked(comicId: comicId);
  }
}
