import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../network/dio_client.dart';

// Biến toàn cục Service Locator (sl)
final sl = GetIt.instance;

/// Khởi tạo và đăng ký toàn bộ các dịch vụ cốt lõi của Naomi
Future<void> init() async {
  //! 1. Core Services (Tầng hạ tầng dùng chung)
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // (Các BLoC, UseCase, Repository của từng tính năng sẽ được đăng ký tiếp tại đây ở Sprint 2, 3, 4)
}