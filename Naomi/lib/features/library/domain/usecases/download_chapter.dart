import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/library_repository.dart';

class DownloadChapterParams {
  final String comicId;
  final String comicTitle;
  final String? coverUrl;
  final String author;
  final String chapterId;
  final String chapterNumber;
  final String chapterTitle;
  final void Function(int downloaded, int total)? onProgress;

  const DownloadChapterParams({
    required this.comicId,
    required this.comicTitle,
    this.coverUrl,
    required this.author,
    required this.chapterId,
    required this.chapterNumber,
    required this.chapterTitle,
    this.onProgress,
  });
}

/// UseCase thực hiện tải toàn bộ trang ảnh của chương truyện về máy để đọc offline (FR-06 & S11)
class DownloadChapter {
  final LibraryRepository repository;

  DownloadChapter(this.repository);

  Future<Either<Failure, void>> call(DownloadChapterParams params) {
    return repository.downloadChapter(
      comicId: params.comicId,
      comicTitle: params.comicTitle,
      coverUrl: params.coverUrl,
      author: params.author,
      chapterId: params.chapterId,
      chapterNumber: params.chapterNumber,
      chapterTitle: params.chapterTitle,
      onProgress: params.onProgress,
    );
  }
}
