import '../../domain/entities/chapter.dart';

/// DTO phân giải dữ liệu Chapter từ MangaDex REST API v5
class ChapterModel extends Chapter {
  const ChapterModel({
    required super.id,
    required super.comicId,
    required super.chapterNumber,
    required super.volumeNumber,
    required super.title,
    required super.translatedLanguage,
    required super.publishAt,
    required super.scanlationGroup,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json, {String comicId = ''}) {
    final String id = json['id'] ?? '';
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};

    final String chapterNumber = attributes['chapter']?.toString() ?? '1';
    final String volumeNumber = attributes['volume']?.toString() ?? '';
    final String title = attributes['title']?.toString() ?? '';
    final String translatedLanguage = attributes['translatedLanguage']?.toString() ?? 'en';
    final String publishAt = attributes['publishAt']?.toString() ?? '';

    // Phân giải nhóm dịch thuật
    final relationships = json['relationships'] as List<dynamic>? ?? [];
    String scanlationGroup = 'MangaDex Community';
    for (final rel in relationships) {
      if (rel is Map<String, dynamic> && rel['type'] == 'scanlation_group') {
        final relAttrs = rel['attributes'] as Map<String, dynamic>?;
        if (relAttrs != null && relAttrs['name'] != null) {
          scanlationGroup = relAttrs['name'].toString();
          break;
        }
      }
    }

    return ChapterModel(
      id: id,
      comicId: comicId,
      chapterNumber: chapterNumber,
      volumeNumber: volumeNumber,
      title: title,
      translatedLanguage: translatedLanguage,
      publishAt: publishAt,
      scanlationGroup: scanlationGroup,
    );
  }
}
