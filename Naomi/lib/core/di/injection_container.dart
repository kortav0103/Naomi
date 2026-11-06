import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../network/dio_client.dart';
import '../../features/comic/data/datasources/mangadex_remote_data_source.dart';
import '../../features/comic/data/repositories/comic_repository_impl.dart';
import '../../features/comic/domain/repositories/comic_repository.dart';
import '../../features/comic/domain/usecases/get_comic_chapters.dart';
import '../../features/comic/domain/usecases/get_comic_detail.dart';
import '../../features/comic/domain/usecases/get_trending_comics.dart';
import '../../features/comic/domain/usecases/search_comics.dart';
import '../../features/comic/presentation/bloc/detail/comic_detail_bloc.dart';
import '../../features/comic/presentation/bloc/discover/discover_bloc.dart';

// Biến toàn cục Service Locator (sl)
final sl = GetIt.instance;

/// Khởi tạo và đăng ký toàn bộ các dịch vụ cốt lõi của Naomi
Future<void> init() async {
  //! 1. Core Services & External
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  //! 2. Feature: Comic / Discover Module
  // Data sources
  sl.registerLazySingleton<MangaDexRemoteDataSource>(
    () => MangaDexRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ComicRepository>(
    () => ComicRepositoryImpl(
      remoteDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTrendingComics(sl()));
  sl.registerLazySingleton(() => SearchComics(sl()));
  sl.registerLazySingleton(() => GetComicChapters(sl()));
  sl.registerLazySingleton(() => GetComicDetail(sl()));

  // BLoCs (Factory để tạo instance mới mỗi khi màn hình mở ra)
  sl.registerFactory(
    () => DiscoverBloc(
      getTrendingComics: sl(),
      searchComics: sl(),
      repository: sl(),
    ),
  );
  sl.registerFactory(
    () => ComicDetailBloc(
      getComicDetail: sl(),
      getComicChapters: sl(),
    ),
  );
}
