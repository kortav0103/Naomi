import 'package:dio/dio.dart';

/// Client HTTP chuẩn mực gọi MangaDex REST API v5
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.mangadex.org',
        connectTimeout: const Duration(seconds: 10), // Giới hạn 10s theo NFR
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // User-Agent chuẩn theo quy định của MangaDex API v5 để tránh bị chặn IP
          'User-Agent': 'Naomi-Manga-App/1.0.0 (https://github.com/kortav0103/Naomi)',
        },
      ),
    );

    // Bật log để quan sát request khi gỡ lỗi (debug)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );
  }
}