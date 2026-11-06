import 'package:equatable/equatable.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/entities/comic.dart';

abstract class ComicDetailState extends Equatable {
  const ComicDetailState();

  @override
  List<Object?> get props => [];
}

class ComicDetailInitial extends ComicDetailState {}

class ComicDetailLoading extends ComicDetailState {}

class ComicDetailLoaded extends ComicDetailState {
  final Comic comic;
  final List<Chapter> chapters;

  const ComicDetailLoaded({
    required this.comic,
    required this.chapters,
  });

  @override
  List<Object?> get props => [comic, chapters];
}

class ComicDetailError extends ComicDetailState {
  final String message;
  const ComicDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
