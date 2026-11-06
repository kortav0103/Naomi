import 'package:equatable/equatable.dart';

/// Thực thể đại diện cho một chương truyện tranh
class Chapter extends Equatable {
  final String id; // UUID chương từ MangaDex
  final String comicId; // ID truyện chứa chương này
  final String chapterNumber; // Số chương (vd: "1", "12.5")
  final String volumeNumber; // Số tập (vd: "1", "None")
  final String title; // Tiêu đề riêng của chương (nếu có)
  final String translatedLanguage; // Ngôn ngữ bản dịch (vi, en)
  final String publishAt; // Thời gian phát hành
  final String scanlationGroup; // Tên nhóm dịch thuật

  const Chapter({
    required this.id,
    required this.comicId,
    required this.chapterNumber,
    required this.volumeNumber,
    required this.title,
    required this.translatedLanguage,
    required this.publishAt,
    required this.scanlationGroup,
  });

  @override
  List<Object?> get props => [id, comicId, chapterNumber, translatedLanguage];
}
