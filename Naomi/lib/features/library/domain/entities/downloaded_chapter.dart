import 'package:equatable/equatable.dart';

/// Thực thể đại diện cho một chương truyện đã tải về máy để đọc ngoại tuyến
class DownloadedChapter extends Equatable {
  final String chapterId;
  final String comicTitle;
  final String chapterNumber;
  final String localDirectory; // Thư mục lưu ảnh trong bộ nhớ máy
  final int totalPages;
  final String downloadedAt;

  const DownloadedChapter({
    required this.chapterId,
    required this.comicTitle,
    required this.chapterNumber,
    required this.localDirectory,
    required this.totalPages,
    required this.downloadedAt,
  });

  @override
  List<Object?> get props => [chapterId, comicTitle, chapterNumber, localDirectory];
}