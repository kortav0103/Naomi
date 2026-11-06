import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naomi/core/errors/failures.dart';
import 'package:naomi/features/comic/domain/entities/chapter.dart';
import 'package:naomi/features/comic/domain/entities/comic.dart';
import 'package:naomi/features/comic/domain/repositories/comic_repository.dart';
import 'package:naomi/features/comic/domain/usecases/get_trending_comics.dart';
import 'package:naomi/features/comic/domain/usecases/search_comics.dart';
import 'package:naomi/features/comic/presentation/bloc/discover/discover_bloc.dart';
import 'package:naomi/features/comic/presentation/bloc/discover/discover_event.dart';
import 'package:naomi/features/comic/presentation/bloc/discover/discover_state.dart';

// 1. Tạo Repository và UseCase giả lập (Fake) để kiểm thử độc lập
class FakeComicRepository implements ComicRepository {
  @override
  Future<Either<Failure, List<Comic>>> getTrendingComics({int limit = 20, int offset = 0}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Comic>>> searchComics({required String query, int limit = 20, int offset = 0}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Comic>> getComicDetail({required String comicId}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Chapter>>> getComicChapters({
    required String comicId,
    List<String> languages = const ['vi', 'en'],
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Comic>>> getComicsByGenre({required String genreTagId, int limit = 20, int offset = 0}) async {
    return const Right([]);
  }
}

class FakeSuccessGetTrendingComics extends GetTrendingComics {
  final List<Comic> comics;
  FakeSuccessGetTrendingComics(this.comics) : super(FakeComicRepository());

  @override
  Future<Either<Failure, List<Comic>>> call({int limit = 20, int offset = 0}) async {
    return Right(comics);
  }
}

class FakeFailureGetTrendingComics extends GetTrendingComics {
  final String errorMessage;
  FakeFailureGetTrendingComics(this.errorMessage) : super(FakeComicRepository());

  @override
  Future<Either<Failure, List<Comic>>> call({int limit = 20, int offset = 0}) async {
    return Left(ServerFailure(errorMessage));
  }
}

class FakeSuccessSearchComics extends SearchComics {
  final List<Comic> comics;
  FakeSuccessSearchComics(this.comics) : super(FakeComicRepository());

  @override
  Future<Either<Failure, List<Comic>>> call({required String query, int limit = 20, int offset = 0}) async {
    return Right(comics);
  }
}

void main() {
  const tComic = Comic(
    id: 'comic-123',
    title: 'Frieren: Beyond Journey\'s End',
    coverUrl: 'https://mangadex.org/covers/frieren.jpg',
    author: 'Yamada Kanehito',
    artist: 'Abe Tsukasa',
    description: 'The adventure is over but life goes on for an elf mage...',
    status: 'ongoing',
    contentRating: 'safe',
    genres: ['Fantasy', 'Adventure', 'Drama'],
    updatedAt: '2026-11-06T00:00:00Z',
  );

  final tComicsList = [tComic];
  final fakeRepo = FakeComicRepository();

  group('DiscoverBloc Unit Tests', () {
    test('Trạng thái ban đầu của DiscoverBloc phải là DiscoverInitial', () {
      final bloc = DiscoverBloc(
        getTrendingComics: FakeSuccessGetTrendingComics(tComicsList),
        searchComics: FakeSuccessSearchComics(tComicsList),
        repository: fakeRepo,
      );

      expect(bloc.state, equals(const DiscoverInitial()));
      bloc.close();
    });

    test('Phát ra [DiscoverLoading, DiscoverLoaded] khi nạp danh sách thịnh hành thành công', () async {
      final bloc = DiscoverBloc(
        getTrendingComics: FakeSuccessGetTrendingComics(tComicsList),
        searchComics: FakeSuccessSearchComics(tComicsList),
        repository: fakeRepo,
      );

      final expectedStates = [
        const DiscoverLoading(),
        DiscoverLoaded(comics: tComicsList, activeFilterTitle: 'Trending Now'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadTrendingComicsEvent());
    });

    test('Phát ra [DiscoverLoading, DiscoverError] khi gọi API MangaDex thất bại', () async {
      final bloc = DiscoverBloc(
        getTrendingComics: FakeFailureGetTrendingComics('Lỗi kết nối máy chủ MangaDex'),
        searchComics: FakeSuccessSearchComics(tComicsList),
        repository: fakeRepo,
      );

      final expectedStates = [
        const DiscoverLoading(),
        const DiscoverError('Lỗi kết nối máy chủ MangaDex'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadTrendingComicsEvent());
    });

    test('Phát ra [DiscoverLoading, DiscoverLoaded] với kết quả tìm kiếm theo từ khóa', () async {
      final bloc = DiscoverBloc(
        getTrendingComics: FakeSuccessGetTrendingComics([]),
        searchComics: FakeSuccessSearchComics(tComicsList),
        repository: fakeRepo,
      );

      final expectedStates = [
        const DiscoverLoading(),
        DiscoverLoaded(comics: tComicsList, activeFilterTitle: 'Kết quả: "Frieren"'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const SearchComicsEvent('Frieren'));
    });
  });
}
