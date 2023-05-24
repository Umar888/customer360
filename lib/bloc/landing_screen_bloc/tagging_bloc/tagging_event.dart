part of 'tagging_bloc.dart';

@immutable
abstract class TaggingEvent extends Equatable {
  TaggingEvent();
  @override
  List<Object> get props => [];
}

class LoadTagData extends TaggingEvent {}
