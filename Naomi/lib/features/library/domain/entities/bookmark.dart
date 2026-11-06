import 'package:equatable/equatable.dart';

/// Thực thể đại diện cho một truyện được độc giả đánh dấu Yêu thích
class Bookmark extends Equatable {
  final String comicId;
  final String title;
  final String? coverUrl;
  final String author;
  final String addedAt;

  const Bookmark({
    required this.comicId,
    required this.title,
    this.coverUrl,
    required this.author,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [comicId, title, coverUrl];
}