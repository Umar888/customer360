// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'pinned_notes_bloc.dart';

abstract class PinnedNotesState extends Equatable {
  PinnedNotesState();

  @override
  List<Object> get props => [];
}

class PinnedNotesInitial extends PinnedNotesState {}

class PinnednotesScreenProgress extends PinnedNotesState {}

class PinnedNotesScreenFailure extends PinnedNotesState {}

class PinnedNotesScreenSuccess extends PinnedNotesState {
  final List<PinnedNotes>? pinnedNotesList;
  final List<PinnedNotes>? allNotesList;
  PinnedNotesScreenSuccess({
    this.pinnedNotesList,
    this.allNotesList,
  });

  @override
  List<Object> get props => [
        pinnedNotesList!,
        allNotesList!,
      ];
}
