import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Client HTTP chuẩn mực gọi MangaDex REST API v5 kèm cơ chế Retry, Rate-Limit Backoff & Web CORS Proxy
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.mangadex.org',
        connectTimeout: const Duration(seconds: 12), // Giới hạn theo NFR
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Trình duyệt Web (Chrome/Edge) không cho phép ghi đè User-Agent trong XHR
          if (!kIsWeb)
            'User-Agent': 'Naomi-Manga-App/1.0.0 (https://github.com/kortav0103/Naomi)',
        },
      ),
    );

    // 1. Hỗ trợ chạy trên Trình duyệt Web (Chrome/Edge): Tự động bọc qua CORS Proxy vì MangaDex chặn request trực tiếp từ localhost (403 Forbidden)
    if (kIsWeb) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final fullUri = options.uri.toString();
            if (fullUri.contains('api.mangadex.org') && !fullUri.contains('corsproxy.io')) {
              final encodedUrl = Uri.encodeComponent(fullUri);
              options.baseUrl = '';
              options.path = 'https://corsproxy.io/?$encodedUrl';
              options.queryParameters = {};
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            if (response.data is String) {
              try {
                response.data = jsonDecode(response.data as String);
              } catch (_) {}
            }
            return handler.next(response);
          },
        ),
      );
    }

    // 2. Interceptor tự động thử lại (Exponential Backoff) khi gặp lỗi mạng thoáng qua hoặc Rate-Limit HTTP 429
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final statusCode = error.response?.statusCode;
          final extra = error.requestOptions.extra;
          final int retryCount = (extra['retryCount'] as int?) ?? 0;

          final shouldRetry = (statusCode == 429 ||
                  statusCode == 502 ||
                  statusCode == 503 ||
                  statusCode == 504 ||
                  error.type == DioExceptionType.connectionTimeout) &&
              retryCount < 2;

          if (shouldRetry) {
            error.requestOptions.extra['retryCount'] = retryCount + 1;
            final delayMs = 600 * (retryCount + 1);
            await Future<void>.delayed(Duration(milliseconds: delayMs));
            try {
              final response = await dio.fetch<dynamic>(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 3. Bật log để quan sát request khi gỡ lỗi (debug)
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
