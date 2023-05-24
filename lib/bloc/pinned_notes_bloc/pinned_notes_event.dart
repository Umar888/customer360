// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'pinned_notes_bloc.dart';

abstract class PinnedNotesEvent extends Equatable {
  PinnedNotesEvent();

  @override
  List<Object> get props => [];
}

class LoadData extends PinnedNotesEvent {
  LoadData();
  @override
  List<Object> get props => [];
}

class AllNotesChange extends PinnedNotesEvent {
  final int index;
  AllNotesChange({
    required this.index,
  });
  @override
  List<Object> get props => [index];
}

class PinnedNotesChange extends PinnedNotesEvent {
  final int index;
  PinnedNotesChange({
    required this.index,
  });
  @override
  List<Object> get props => [index];
}
