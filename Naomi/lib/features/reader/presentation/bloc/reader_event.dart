import 'package:equatable/equatable.dart';

abstract class ReaderEvent extends Equatable {
  const ReaderEvent();

  @override
  List<Object?> get props => [];
}

/// Nạp dữ liệu các trang ảnh của chương
class LoadChapterPagesEvent extends ReaderEvent {
  final String chapterId;
  const LoadChapterPagesEvent(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
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

/// Ẩn/Hiện thanh điều khiển khi chạm vào giữa màn hình (FR-02 Focus Mode)
class ToggleFocusModeEvent extends ReaderEvent {
  const ToggleFocusModeEvent();
}

/// Bật/Tắt chế độ nén ảnh Data Saver 4G
class ToggleDataSaverEvent extends ReaderEvent {
  const ToggleDataSaverEvent();
}
