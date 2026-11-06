import 'package:equatable/equatable.dart';

/// Thực thể đại diện cho toàn bộ trang ảnh của một chương truyện từ MangaDex@Home CDN
class ChapterPages extends Equatable {
  final String chapterId;
  final String baseUrl;
  final String chapterHash;
  final List<String> pageFilenames; // Danh sách tên file ảnh gốc
  final List<String> dataSaverFilenames; // Danh sách tên file ảnh nén (Data Saver 4G)

  const ChapterPages({
    required this.chapterId,
    required this.baseUrl,
    required this.chapterHash,
    required this.pageFilenames,
    required this.dataSaverFilenames,
  });

  /// Tổng số trang của chương
  int get totalPages => pageFilenames.length;

  /// Tạo đường dẫn URL ảnh đầy đủ để tải từ CDN
  String getPageUrl(int pageIndex, {bool isDataSaver = false}) {
    final list = (isDataSaver && dataSaverFilenames.isNotEmpty)
        ? dataSaverFilenames
        : pageFilenames;

    if (pageIndex < 0 || pageIndex >= list.length) {
      return '';
    }

    final mode = (isDataSaver && dataSaverFilenames.isNotEmpty)
        ? 'data-saver'
        : 'data';

    // Ghép URL chuẩn MangaDex@Home: {baseUrl}/{mode}/{hash}/{filename}
    return '$baseUrl/$mode/$chapterHash/${list[pageIndex]}';
  }

  @override
  List<Object?> get props => [chapterId, baseUrl, chapterHash, pageFilenames];
}
