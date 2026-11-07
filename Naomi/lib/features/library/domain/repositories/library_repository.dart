import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bookmark.dart';
import '../entities/downloaded_chapter.dart';
import '../entities/reading_history_item.dart';

/// Hợp đồng trừu tượng cho các nghiệp vụ Tủ sách cá nhân & Lịch sử đọc dở (FR-04, FR-06, FR-07)
abstract class LibraryRepository {
  /// Lấy danh sách truyện Yêu thích từ CSDL SQLite
  Future<Either<Failure, List<Bookmark>>> getBookmarks();

  /// Thêm hoặc Xóa truyện Yêu thích (Thả tim)
  Future<Either<Failure, bool>> toggleBookmark({
    required String comicId,
    required String title,
    String? coverUrl,
    required String author,
  });

  /// Kiểm tra xem truyện này đã được đánh dấu Yêu thích chưa
  Future<Either<Failure, bool>> isBookmarked({
    required String comicId,
  });

  /// Lấy danh sách các chương đã tải xuống thiết bị
  Future<Either<Failure, List<DownloadedChapter>>> getDownloadedChapters();

  /// Xóa chương ngoại tuyến để dọn dẹp bộ nhớ máy
  Future<Either<Failure, void>> deleteDownloadedChapter({
    required String chapterId,
  });

  /// Kiểm tra xem chương này đã tải về máy chưa
  Future<Either<Failure, bool>> isChapterDownloaded({
    required String chapterId,
  });

  /// Tải trọn bộ các trang ảnh của chương và lưu vào SQLite để đọc ngoại tuyến (FR-06)
  Future<Either<Failure, void>> downloadChapter({
    required String comicId,
    required String comicTitle,
    String? coverUrl,
    required String author,
    required String chapterId,
    required String chapterNumber,
    required String chapterTitle,
  });

  /// Lấy danh sách lịch sử các truyện đang đọc dở (FR-04)
  Future<Either<Failure, List<ReadingHistoryItem>>> getReadingHistory();

  /// Lấy bộ truyện được đọc gần đây nhất cho Kệ "Đọc tiếp" trên Trang chủ (FR-08)
  Future<Either<Failure, ReadingHistoryItem?>> getLastReadComic();

  /// Xóa toàn bộ lịch sử đọc
  Future<Either<Failure, void>> clearReadingHistory();

  /// Lưu tiến trình đọc dở không bị chặn bởi khóa ngoại
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
}
