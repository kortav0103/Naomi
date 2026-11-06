import 'package:equatable/equatable.dart';

/// Thực thể đại diện cho một bộ truyện tranh (Manga/Webtoon)
class Comic extends Equatable {
  final String id; // UUID từ MangaDex (ví dụ: a1c7c917-...)
  final String title; // Tên truyện chính
  final String description; // Tóm tắt nội dung
  final String? coverUrl; // Đường dẫn ảnh bìa đầy đủ
  final String author; // Tên tác giả
  final String artist; // Tên họa sĩ
  final String status; // ongoing, completed, hiatus...
  final String contentRating; // safe, suggestive...
  final List<String> genres; // Danh sách thể loại (Action, Fantasy...)
  final String? updatedAt;

  const Comic({
    required this.id,
    required this.title,
    required this.description,
    this.coverUrl,
    required this.author,
    required this.artist,
    required this.status,
    required this.contentRating,
    required this.genres,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, coverUrl, status, genres];
}
