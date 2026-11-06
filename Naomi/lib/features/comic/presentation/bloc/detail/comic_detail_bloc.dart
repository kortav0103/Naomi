import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_comic_chapters.dart';
import '../../../domain/usecases/get_comic_detail.dart';
import 'comic_detail_event.dart';
import 'comic_detail_state.dart';

class ComicDetailBloc extends Bloc<ComicDetailEvent, ComicDetailState> {
  final GetComicDetail getComicDetail;
  final GetComicChapters getComicChapters;

  ComicDetailBloc({
    required this.getComicDetail,
    required this.getComicChapters,
  }) : super(ComicDetailInitial()) {
    on<LoadComicDetailEvent>(_onLoadDetail);
  }

  Future<void> _onLoadDetail(
    LoadComicDetailEvent event,
    Emitter<ComicDetailState> emit,
  ) async {
    emit(ComicDetailLoading());

    final comicResult = await getComicDetail(comicId: event.comicId);
    final chaptersResult = await getComicChapters(comicId: event.comicId);

    comicResult.fold(
      (failure) => emit(ComicDetailError(failure.message)),
      (comic) {
        chaptersResult.fold(
          (failure) => emit(ComicDetailLoaded(comic: comic, chapters: const [])),
          (chapters) => emit(ComicDetailLoaded(comic: comic, chapters: chapters)),
        );
      },
    );
  }
}
