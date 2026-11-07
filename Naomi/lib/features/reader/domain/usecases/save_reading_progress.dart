import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/reader_repository.dart';

class SaveReadingProgress {
  final ReaderRepository repository;

  SaveReadingProgress(this.repository);

  Future<Either<Failure, void>> call({
    required String comicId,
    required String chapterId,
    required String comicTitle,
    String? coverUrl,
    required String chapterNumber,
    required int lastPageRead,
    required int totalPages,
    required double readPercentage,
    bool isCompleted = false,
  }) {
    return repository.saveReadingProgress(
      comicId: comicId,
      chapterId: chapterId,
      comicTitle: comicTitle,
      coverUrl: coverUrl,
      chapterNumber: chapterNumber,
      lastPageRead: lastPageRead,
      totalPages: totalPages,
      readPercentage: readPercentage,
      isCompleted: isCompleted,
    );
  }
}
