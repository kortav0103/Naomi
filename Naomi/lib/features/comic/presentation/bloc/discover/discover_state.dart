import 'package:equatable/equatable.dart';
import '../../../domain/entities/comic.dart';

abstract class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object?> get props => [];
}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<Comic> comics;
  final String activeFilterTitle; // "Trending", "Search: naruto", hoặc "Genre: Action"

  const DiscoverLoaded({
    required this.comics,
    this.activeFilterTitle = 'Trending Now',
  });

  @override
  List<Object?> get props => [comics, activeFilterTitle];
}

class DiscoverError extends DiscoverState {
  final String message;
  const DiscoverError(this.message);

  @override
  List<Object?> get props => [message];
}
