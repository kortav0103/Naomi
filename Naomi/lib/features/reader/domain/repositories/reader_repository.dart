import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chapter_pages.dart';

/// Hợp đồng trừu tượng cho các nghiệp vụ của Trình đọc truyện
abstract class ReaderRepository {
  /// Lấy danh sách trang ảnh của chương từ MangaDex CDN
  Future<Either<Failure, ChapterPages>> getChapterPages({
    required String chapterId,
  });

  /// Lưu tiến trình đọc dở vào CSDL cục bộ SQLite (FR-04, FR-08)
  Future<Either<Failure, void>> saveReadingProgress({
    required String comicId,
    required String chapterId,
    required String comicTitle,
    String? coverUrl,
    required String chapterNumber,
    required int lastPageRead,
    required int totalPages,
    required double readPercentage,
    bool isCompleted = false,
  });

  /// Đọc vị trí trang đọc dở gần nhất từ SQLite
  Future<Either<Failure, int>> getSavedPageProgress({
    required String chapterId,
  });
}
