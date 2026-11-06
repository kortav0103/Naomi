import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/reader_repository.dart';

class SaveReadingProgress {
  final ReaderRepository repository;

  SaveReadingProgress(this.repository);

  Future<Either<Failure, void>> call({
    required String chapterId,
    required int lastPageRead,
    required double readPercentage,
    bool isCompleted = false,
  }) {
    return repository.saveReadingProgress(
      chapterId: chapterId,
      lastPageRead: lastPageRead,
      readPercentage: readPercentage,
      isCompleted: isCompleted,
    );
  }
}