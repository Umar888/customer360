import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../constants/colors.dart';
import '../../models/pinned_notes_model.dart';

part 'pinned_notes_event.dart';
part 'pinned_notes_state.dart';

class PinnedNotesBloc extends Bloc<PinnedNotesEvent, PinnedNotesState> {
  PinnedNotesBloc() : super(PinnedNotesInitial()) {
    on<AllNotesChange>((event, emit) {
      final previousState = state as PinnedNotesScreenSuccess;

      List<PinnedNotes> allNotesList = previousState.allNotesList ?? [];
      List<PinnedNotes> pinnedNotesList = previousState.pinnedNotesList ?? [];
      List<PinnedNotes> new_p = [];

      print(event.index);
      for (int k = 0; k < allNotesList.length; k++) {
        if (k == event.index) {
          new_p.add(PinnedNotes(
            textOfNote: allNotesList[k].textOfNote,
            authorOfNote: allNotesList[k].authorOfNote,
            isLess: allNotesList[k].isLess! ? false : true,
            dateOfNote: allNotesList[k].dateOfNote,
            backgroundColor: allNotesList[k].backgroundColor,
          ));
        } else {
          new_p.add(PinnedNotes(
            textOfNote: allNotesList[k].textOfNote,
            authorOfNote: allNotesList[k].authorOfNote,
            isLess: true,
            dateOfNote: allNotesList[k].dateOfNote,
            backgroundColor: allNotesList[k].backgroundColor,
          ));
        }
      }

      print(allNotesList == new_p);

      emit(
        PinnedNotesScreenSuccess(
          pinnedNotesList: pinnedNotesList,
          allNotesList: List.from(new_p),
        ),
      );
    });
    on<PinnedNotesChange>((event, emit) {
      final previousState = state as PinnedNotesScreenSuccess;

      List<PinnedNotes> allNotesList = previousState.allNotesList ?? [];
      List<PinnedNotes> pinnedNotesList = previousState.pinnedNotesList ?? [];
      List<PinnedNotes> new_p = [];

      print(event.index);
      for (int k = 0; k < pinnedNotesList.length; k++) {
        if (k == event.index) {
          new_p.add(PinnedNotes(
            textOfNote: pinnedNotesList[k].textOfNote,
            authorOfNote: pinnedNotesList[k].authorOfNote,
            isLess: pinnedNotesList[k].isLess! ? false : true,
            dateOfNote: pinnedNotesList[k].dateOfNote,
            backgroundColor: pinnedNotesList[k].backgroundColor,
          ));
        } else {
          new_p.add(PinnedNotes(
            textOfNote: pinnedNotesList[k].textOfNote,
            authorOfNote: pinnedNotesList[k].authorOfNote,
            isLess: true,
            dateOfNote: pinnedNotesList[k].dateOfNote,
            backgroundColor: pinnedNotesList[k].backgroundColor,
          ));
        }
      }

      print(pinnedNotesList == new_p);

      emit(
        PinnedNotesScreenSuccess(
          allNotesList: allNotesList,
          pinnedNotesList: List.from(new_p),
        ),
      );
    });

    on<LoadData>((event, emit) async {
      emit(PinnednotesScreenProgress());
      final List<PinnedNotes> allNotesList = [];
      final List<PinnedNotes> pinnedNotesList = [];
      // all Notes
      allNotesList.add(PinnedNotes(
          textOfNote:
              'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
          authorOfNote: 'john Doe',
          dateOfNote: 'Aug 20, 2022',
          isLess: true,
          backgroundColor: AppColors.skyblueHex));
      allNotesList.add(PinnedNotes(
          textOfNote:
              'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
          authorOfNote: 'john Doe',
          isLess: true,
          dateOfNote: 'Aug 20, 2022',
          backgroundColor: AppColors.yellowNotes));
      allNotesList.add(PinnedNotes(
          textOfNote:
              'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
          authorOfNote: 'john Doe',
          isLess: true,
          dateOfNote: 'Aug 20, 2022',
          backgroundColor: AppColors.yellowNotes));
      allNotesList.add(PinnedNotes(
          textOfNote:
              'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
          authorOfNote: 'john Doe',
          isLess: true,
          dateOfNote: 'Aug 20, 2022',
          backgroundColor: AppColors.yellowNotes));

      // pinned Notes
      pinnedNotesList.add(PinnedNotes(
          textOfNote:
              'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
          authorOfNote: 'john Doe',
          dateOfNote: 'Aug 20, 2022',
          isLess: true,
          backgroundColor: AppColors.skyblueHex));
      pinnedNotesList.add(PinnedNotes(
          textOfNote:
              'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
          authorOfNote: 'john Doe',
          isLess: true,
          dateOfNote: 'Aug 20, 2022',
          backgroundColor: AppColors.yellowNotes));

         emit(
        PinnedNotesScreenSuccess(
          allNotesList: allNotesList,
          pinnedNotesList: pinnedNotesList,
        ),
      );
    });

  }
}
