import '../../domain/entities/comic.dart';

/// DTO phân giải dữ liệu JSON phức tạp từ MangaDex REST API v5
class ComicModel extends Comic {
  const ComicModel({
    required super.id,
    required super.title,
    required super.description,
    super.coverUrl,
    required super.author,
    required super.artist,
    required super.status,
    required super.contentRating,
    required super.genres,
    super.updatedAt,
  });

  factory ComicModel.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] ?? '';
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};

    // 1. Phân giải Tiêu đề (Chỉ nhận Tiếng Anh 'en' -> tiêu đề đầu tiên)
    final titleMap = attributes['title'] as Map<String, dynamic>? ?? {};
    String title = titleMap['en'] ?? '';
    if (title.isEmpty && titleMap.isNotEmpty) {
      title = titleMap.values.first.toString();
    }

    // 2. Phân giải Mô tả (Chỉ nhận Tiếng Anh 'en' -> mô tả đầu tiên)
    final descMap = attributes['description'] as Map<String, dynamic>? ?? {};
    String description = descMap['en'] ?? '';
    if (description.isEmpty && descMap.isNotEmpty) {
      description = descMap.values.first.toString();
    }

    // 3. Phân giải Thể loại (Genres/Tags)
    final tagsList = attributes['tags'] as List<dynamic>? ?? [];
    final List<String> genres = [];
    for (final tag in tagsList) {
      if (tag is Map<String, dynamic>) {
        final tagAttrs = tag['attributes'] as Map<String, dynamic>? ?? {};
        final tagNameMap = tagAttrs['name'] as Map<String, dynamic>? ?? {};
        final name = tagNameMap['en']?.toString();
        if (name != null && name.isNotEmpty) {
          genres.add(name);
        }
      }
    }

    // 4. Phân giải Relationships: Cover Art, Author, Artist
    final relationships = json['relationships'] as List<dynamic>? ?? [];
    String? coverFileName;
    String author = 'Unknown';
    String artist = 'Unknown';

    for (final rel in relationships) {
      if (rel is Map<String, dynamic>) {
        final type = rel['type']?.toString();
        final relAttrs = rel['attributes'] as Map<String, dynamic>?;

        if (type == 'cover_art' && relAttrs != null) {
          coverFileName = relAttrs['fileName']?.toString();
        } else if (type == 'author' && relAttrs != null) {
          author = relAttrs['name']?.toString() ?? author;
        } else if (type == 'artist' && relAttrs != null) {
          artist = relAttrs['name']?.toString() ?? artist;
        }
      }
    }

    // URL ảnh bìa chuẩn MangaDex (sử dụng phiên bản nén .512.jpg để tối ưu băng thông)
    String? coverUrl;
    if (coverFileName != null && coverFileName.isNotEmpty) {
      coverUrl = 'https://uploads.mangadex.org/covers/$id/$coverFileName.512.jpg';
    }

    return ComicModel(
      id: id,
      title: title.isEmpty ? 'Untitled Manga' : title,
      description: description,
      coverUrl: coverUrl,
      author: author,
      artist: artist,
      status: attributes['status']?.toString() ?? 'ongoing',
      contentRating: attributes['contentRating']?.toString() ?? 'safe',
      genres: genres,
      updatedAt: attributes['updatedAt']?.toString(),
    );
  }
}
