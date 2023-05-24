part of 'tagging_bloc.dart';

@immutable
abstract class TaggingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaggingInitial extends TaggingState {}

class TaggingProgress extends TaggingState {}

class TaggingFailure extends TaggingState {}

class TaggingSuccess extends TaggingState {
  final CustomerTagging tags;

  TaggingSuccess({required this.tags});

  @override
  List<Object?> get props => [tags];
}
