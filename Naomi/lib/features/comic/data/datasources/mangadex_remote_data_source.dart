import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/chapter_model.dart';
import '../models/comic_model.dart';

abstract class MangaDexRemoteDataSource {
  Future<List<ComicModel>> getTrendingComics({int limit = 20, int offset = 0});
  Future<List<ComicModel>> searchComics({required String query, int limit = 20, int offset = 0});
  Future<List<ComicModel>> getComicsByGenre({required String genreTagId, int limit = 20, int offset = 0});
  Future<List<ChapterModel>> getComicChapters({required String comicId, List<String> languages = const ['en']});
  Future<ComicModel> getComicDetail({required String comicId});
}

class MangaDexRemoteDataSourceImpl implements MangaDexRemoteDataSource {
  final DioClient client;

  /// Danh sách nhãn kiểm duyệt mở rộng không giới hạn: mở khóa toàn bộ kho truyện MangaDex
  static const List<String> _unrestrictedContentRatings = [
    'safe',
    'suggestive',
    'erotica',
    'pornographic',
  ];

  MangaDexRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ComicModel>> getTrendingComics({int limit = 20, int offset = 0}) async {
    try {
      final response = await client.dio.get(
        '/manga',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'includes[]': ['cover_art', 'author', 'artist'],
          'order[followedCount]': 'desc',
          'contentRating[]': _unrestrictedContentRatings,
          'availableTranslatedLanguage[]': ['en'],
          'hasAvailableChapters': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((json) => ComicModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Error loading trending comics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'MangaDex connection error');
    }
  }

  @override
  Future<List<ComicModel>> searchComics({required String query, int limit = 20, int offset = 0}) async {
    try {
      final response = await client.dio.get(
        '/manga',
        queryParameters: {
          'title': query,
          'limit': limit,
          'offset': offset,
          'includes[]': ['cover_art', 'author', 'artist'],
          'order[relevance]': 'desc',
          'contentRating[]': _unrestrictedContentRatings,
          'availableTranslatedLanguage[]': ['en'],
          'hasAvailableChapters': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((json) => ComicModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Error searching comics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'MangaDex connection error');
    }
  }

  @override
  Future<List<ComicModel>> getComicsByGenre({required String genreTagId, int limit = 20, int offset = 0}) async {
    try {
      final response = await client.dio.get(
        '/manga',
        queryParameters: {
          'includedTags[]': [genreTagId],
          'limit': limit,
          'offset': offset,
          'includes[]': ['cover_art', 'author', 'artist'],
          'order[followedCount]': 'desc',
          'contentRating[]': _unrestrictedContentRatings,
          'availableTranslatedLanguage[]': ['en'],
          'hasAvailableChapters': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((json) => ComicModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Error filtering by genre: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'MangaDex connection error');
    }
  }

  @override
  Future<List<ChapterModel>> getComicChapters({
    required String comicId,
    List<String> languages = const ['en'],
  }) async {
    try {
      final List<ChapterModel> allChapters = [];
      int offset = 0;
      const int limit = 500; // MangaDex API v5 hỗ trợ tối đa 500 chapters mỗi trang trên endpoint /feed
      int total = 0;

      do {
        final response = await client.dio.get(
          '/manga/$comicId/feed',
          queryParameters: {
            'translatedLanguage[]': languages,
            'contentRating[]': _unrestrictedContentRatings,
            'order[chapter]': 'asc',
            'limit': limit,
            'offset': offset,
            'includes[]': ['scanlation_group'],
            'includeEmptyPages': 0,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
          total = response.data['total'] as int? ?? data.length;
          allChapters.addAll(
            data.map((json) => ChapterModel.fromJson(json as Map<String, dynamic>, comicId: comicId)),
          );
          offset += limit;
        } else {
          throw ServerException('Error loading chapter list: ${response.statusCode}');
        }
      } while (offset < total && offset < 2500);

      return allChapters;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'MangaDex connection error');
    }
  }

  @override
  Future<ComicModel> getComicDetail({required String comicId}) async {
    try {
      final response = await client.dio.get(
        '/manga/$comicId',
        queryParameters: {
          'includes[]': ['cover_art', 'author', 'artist'],
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ComicModel.fromJson(data);
      } else {
        throw ServerException('Error loading comic details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'MangaDex connection error');
    }
  }
}
