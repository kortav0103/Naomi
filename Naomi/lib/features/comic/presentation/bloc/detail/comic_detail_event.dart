import 'package:equatable/equatable.dart';

abstract class ComicDetailEvent extends Equatable {
  const ComicDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadComicDetailEvent extends ComicDetailEvent {
  final String comicId;
  const LoadComicDetailEvent(this.comicId);

  @override
  List<Object?> get props => [comicId];
}
