import '../../domain/entities/chapter_pages.dart';

/// DTO phân giải dữ liệu trả về từ MangaDex@Home Server
class ChapterPagesModel extends ChapterPages {
  const ChapterPagesModel({
    required super.chapterId,
    required super.baseUrl,
    required super.chapterHash,
    required super.pageFilenames,
    required super.dataSaverFilenames,
  });

  factory ChapterPagesModel.fromJson(Map<String, dynamic> json, {required String chapterId}) {
    final String baseUrl = json['baseUrl'] ?? '';
    final chapterData = json['chapter'] as Map<String, dynamic>? ?? {};

    final String chapterHash = chapterData['hash']?.toString() ?? '';
    final List<dynamic> rawPages = chapterData['data'] as List<dynamic>? ?? [];
    final List<dynamic> rawDataSaver = chapterData['dataSaver'] as List<dynamic>? ?? [];

    final List<String> pageFilenames = rawPages.map((e) => e.toString()).toList();
    final List<String> dataSaverFilenames = rawDataSaver.map((e) => e.toString()).toList();

    return ChapterPagesModel(
      chapterId: chapterId,
      baseUrl: baseUrl,
      chapterHash: chapterHash,
      pageFilenames: pageFilenames,
      dataSaverFilenames: dataSaverFilenames,
    );
  }
}
