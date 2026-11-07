import 'package:equatable/equatable.dart';

/// Thực thể Tiến trình / Lịch sử đọc dở (FR-04 & FR-08)
class ReadingHistoryItem extends Equatable {
  final String comicId;
  final String chapterId;
  final String comicTitle;
  final String? coverUrl;
  final String chapterNumber;
  final int lastPageRead;
  final int totalPages;
  final double readPercentage;
  final bool isCompleted;
  final String updatedAt;

  const ReadingHistoryItem({
    required this.comicId,
    required this.chapterId,
    required this.comicTitle,
    this.coverUrl,
    required this.chapterNumber,
    required this.lastPageRead,
    required this.totalPages,
    required this.readPercentage,
    required this.isCompleted,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        comicId,
        chapterId,
        comicTitle,
        coverUrl,
        chapterNumber,
        lastPageRead,
        totalPages,
        readPercentage,
        isCompleted,
        updatedAt,
      ];
}
