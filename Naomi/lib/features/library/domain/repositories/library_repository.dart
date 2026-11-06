import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bookmark.dart';
import '../entities/downloaded_chapter.dart';

/// Hợp đồng trừu tượng cho các nghiệp vụ Tủ sách cá nhân
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
}
