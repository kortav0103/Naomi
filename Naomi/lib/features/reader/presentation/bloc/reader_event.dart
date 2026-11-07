import 'package:equatable/equatable.dart';

abstract class ReaderEvent extends Equatable {
  const ReaderEvent();

  @override
  List<Object?> get props => [];
}

/// Nạp dữ liệu các trang ảnh của chương với đầy đủ thông tin truyện
class LoadChapterPagesEvent extends ReaderEvent {
  final String chapterId;
  final String comicId;
  final String comicTitle;
  final String? coverUrl;
  final String chapterNumber;

  const LoadChapterPagesEvent({
    required this.chapterId,
    this.comicId = '',
    this.comicTitle = 'Manga',
    this.coverUrl,
    this.chapterNumber = '1',
  });

  @override
  List<Object?> get props => [chapterId, comicId, comicTitle, coverUrl, chapterNumber];
}

/// Khi người dùng cuộn hoặc lật sang trang mới
class ChangePageEvent extends ReaderEvent {
  final int pageIndex; // 0-based index
  const ChangePageEvent(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

/// Chuyển đổi chế độ đọc: Cuộn dọc Webtoon ⇄ Lật ngang Manga (FR-03)
class ToggleReaderModeEvent extends ReaderEvent {
  const ToggleReaderModeEvent();
}

/// Chuyển đổi hướng lật trang Manga: Trái sang Phải (LTR) ⇄ Phải sang Trái (RTL Chuẩn Nhật Bản)
class ToggleReadingDirectionEvent extends ReaderEvent {
  const ToggleReadingDirectionEvent();
}

/// Ẩn/Hiện thanh điều khiển khi chạm vào giữa màn hình (FR-02 Focus Mode)
class ToggleFocusModeEvent extends ReaderEvent {
  const ToggleFocusModeEvent();
}

/// Bật/Tắt chế độ nén ảnh Data Saver 4G
class ToggleDataSaverEvent extends ReaderEvent {
  const ToggleDataSaverEvent();
}
