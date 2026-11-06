import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/chapter_pages_model.dart';

abstract class ReaderRemoteDataSource {
  /// Gọi API MangaDex CDN lấy danh sách trang ảnh của chương
  Future<ChapterPagesModel> getChapterPages(String chapterId);
}

class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  final DioClient client;

  ReaderRemoteDataSourceImpl({required this.client});

  @override
  Future<ChapterPagesModel> getChapterPages(String chapterId) async {
    try {
      final response = await client.dio.get('/at-home/server/$chapterId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ChapterPagesModel.fromJson(data, chapterId: chapterId);
      } else {
        throw ServerException('Lỗi tải trang truyện: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối MangaDex CDN');
    }
  }
}
