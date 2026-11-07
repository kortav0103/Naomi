import '../audio/ambient_audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../network/dio_client.dart';
import '../theme/theme_controller.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/comic/data/datasources/mangadex_remote_data_source.dart';
import '../../features/comic/data/repositories/comic_repository_impl.dart';
import '../../features/comic/domain/repositories/comic_repository.dart';
import '../../features/comic/domain/usecases/get_comic_chapters.dart';
import '../../features/comic/domain/usecases/get_comic_detail.dart';
import '../../features/comic/domain/usecases/get_trending_comics.dart';
import '../../features/comic/domain/usecases/search_comics.dart';
import '../../features/comic/presentation/bloc/detail/comic_detail_bloc.dart';
import '../../features/comic/presentation/bloc/discover/discover_bloc.dart';
import '../../features/reader/data/datasources/reader_local_data_source.dart';
import '../../features/reader/data/datasources/reader_remote_data_source.dart';
import '../../features/reader/data/repositories/reader_repository_impl.dart';
import '../../features/reader/domain/repositories/reader_repository.dart';
import '../../features/reader/domain/usecases/get_chapter_pages.dart';
import '../../features/reader/domain/usecases/save_reading_progress.dart';
import '../../features/reader/presentation/bloc/reader_bloc.dart';
import '../../features/library/data/datasources/library_local_data_source.dart';
import '../../features/library/data/repositories/library_repository_impl.dart';
import '../../features/library/domain/repositories/library_repository.dart';
import '../../features/library/domain/usecases/check_is_bookmarked.dart';
import '../../features/library/domain/usecases/download_chapter.dart';
import '../../features/library/domain/usecases/get_bookmarks.dart';
import '../../features/library/domain/usecases/get_downloaded_chapters.dart';
import '../../features/library/domain/usecases/toggle_bookmark.dart';
import '../../features/library/presentation/bloc/library_bloc.dart';

// Biến toàn cục Service Locator (sl)
final sl = GetIt.instance;

/// Khởi tạo và đăng ký toàn bộ các dịch vụ cốt lõi của Naomi
Future<void> init() async {
  if (sl.isRegistered<DioClient>()) {
    return;
  }

  //! 1. Core Services & External
  sl.registerLazySingleton<ThemeController>(() => ThemeController());
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<AmbientAudioService>(() => AmbientAudioService());

  //! 2. Feature: Authentication Module (FR-00, NFR-05, NFR-10)
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );

  //! 3. Feature: Comic / Discover Module
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

  // BLoCs
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

  //! 4. Feature: Reader Module
  // Data sources
  sl.registerLazySingleton<ReaderRemoteDataSource>(
    () => ReaderRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ReaderLocalDataSource>(
    () => ReaderLocalDataSourceImpl(
      dbHelper: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ReaderRepository>(
    () => ReaderRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetChapterPages(sl()));
  sl.registerLazySingleton(() => SaveReadingProgress(sl()));

  // BLoC
  sl.registerFactory(
    () => ReaderBloc(
      getChapterPages: sl(),
      saveReadingProgress: sl(),
      repository: sl(),
    ),
  );

  //! 5. Feature: Library Module
  // Data source
  sl.registerLazySingleton<LibraryLocalDataSource>(
    () => LibraryLocalDataSourceImpl(
      dbHelper: sl(),
      dio: sl<DioClient>().dio,
      authLocalDataSource: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBookmarks(sl()));
  sl.registerLazySingleton(() => GetDownloadedChapters(sl()));
  sl.registerLazySingleton(() => ToggleBookmark(sl()));
  sl.registerLazySingleton(() => CheckIsBookmarked(sl()));
  sl.registerLazySingleton(() => DownloadChapter(sl()));

  // BLoC
  sl.registerFactory(
    () => LibraryBloc(
      getBookmarks: sl(),
      getDownloadedChapters: sl(),
      toggleBookmark: sl(),
      repository: sl(),
    ),
  );
}
