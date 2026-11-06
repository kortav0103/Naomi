import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/chapter_model.dart';
import '../models/comic_model.dart';

abstract class MangaDexRemoteDataSource {
  Future<List<ComicModel>> getTrendingComics({int limit = 20, int offset = 0});
  Future<List<ComicModel>> searchComics({required String query, int limit = 20, int offset = 0});
  Future<List<ComicModel>> getComicsByGenre({required String genreTagId, int limit = 20, int offset = 0});
  Future<List<ChapterModel>> getComicChapters({required String comicId, List<String> languages = const ['vi', 'en']});
  Future<ComicModel> getComicDetail({required String comicId});
}

class MangaDexRemoteDataSourceImpl implements MangaDexRemoteDataSource {
  final DioClient client;

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
          'contentRating[]': ['safe', 'suggestive'],
          'hasAvailableChapters': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((json) => ComicModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Lỗi tải truyện thịnh hành: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối MangaDex');
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
          'contentRating[]': ['safe', 'suggestive'],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((json) => ComicModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Lỗi tìm kiếm truyện: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối MangaDex');
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
          'contentRating[]': ['safe', 'suggestive'],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((json) => ComicModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Lỗi lọc theo thể loại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối MangaDex');
    }
  }

  @override
  Future<List<ChapterModel>> getComicChapters({
    required String comicId,
    List<String> languages = const ['vi', 'en'],
  }) async {
    try {
      final response = await client.dio.get(
        '/manga/$comicId/feed',
        queryParameters: {
          'translatedLanguage[]': languages,
          'order[chapter]': 'asc',
          'limit': 100,
          'includes[]': ['scanlation_group'],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
        return data
            .map((json) => ChapterModel.fromJson(json as Map<String, dynamic>, comicId: comicId))
            .toList();
      } else {
        throw ServerException('Lỗi tải danh sách chương: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối MangaDex');
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
        throw ServerException('Lỗi tải chi tiết truyện: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối MangaDex');
    }
  }
}
