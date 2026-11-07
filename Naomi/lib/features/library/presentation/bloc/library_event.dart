import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Nạp dữ liệu toàn bộ Tủ sách (Yêu thích, Lịch sử đọc, Đã tải xuống)
class LoadLibraryEvent extends LibraryEvent {
  const LoadLibraryEvent();
}

/// Thêm hoặc Xóa truyện Yêu thích
class ToggleBookmarkEvent extends LibraryEvent {
  final String comicId;
  final String title;
  final String? coverUrl;
  final String author;

  const ToggleBookmarkEvent({
    required this.comicId,
    required this.title,
    this.coverUrl,
    required this.author,
  });

  @override
  List<Object?> get props => [comicId, title, coverUrl, author];
}

/// Xóa một chương đã tải ngoại tuyến
class DeleteDownloadedChapterEvent extends LibraryEvent {
  final String chapterId;

  const DeleteDownloadedChapterEvent(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
}

/// Xóa toàn bộ lịch sử đọc của người dùng hiện tại
class ClearReadingHistoryEvent extends LibraryEvent {
  const ClearReadingHistoryEvent();
}
