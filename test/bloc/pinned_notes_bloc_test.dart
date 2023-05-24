import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/pinned_notes_bloc/pinned_notes_bloc.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/models/pinned_notes_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PinnedNotesBloc? pinnedNotesBloc;

  blocTest<PinnedNotesBloc, PinnedNotesState>(
    'All Notes Change',
    setUp: () => pinnedNotesBloc = PinnedNotesBloc(),
    tearDown: () => pinnedNotesBloc = null,
    build: () => pinnedNotesBloc!,
    seed: () => PinnedNotesScreenSuccess(allNotesList: [
      PinnedNotes(
        textOfNote: "textOfNote",
        authorOfNote: "authorOfNote",
        isLess: true,
        dateOfNote: "dateOfNote",
        backgroundColor: AppColors.skyblueHex,
      )
    ], pinnedNotesList: []),
    act: (bloc) => bloc.add(AllNotesChange(index: 0)),
    expect: () => [
      PinnedNotesScreenSuccess(
        pinnedNotesList: [],
        allNotesList: [
          PinnedNotes(
            textOfNote: "textOfNote",
            authorOfNote: "authorOfNote",
            isLess: false,
            dateOfNote: "dateOfNote",
            backgroundColor: AppColors.skyblueHex,
          )
        ],
      ),
    ],
  );

  blocTest<PinnedNotesBloc, PinnedNotesState>(
    'Pinned Notes Change',
    setUp: () => pinnedNotesBloc = PinnedNotesBloc(),
    tearDown: () => pinnedNotesBloc = null,
    build: () => pinnedNotesBloc!,
    seed: () => PinnedNotesScreenSuccess(
      allNotesList: [
        PinnedNotes(
          textOfNote: "textOfNote",
          authorOfNote: "authorOfNote",
          isLess: true,
          dateOfNote: "dateOfNote",
          backgroundColor: AppColors.skyblueHex,
        ),
        PinnedNotes(
          textOfNote: "textOfNote2",
          authorOfNote: "authorOfNote2",
          isLess: false,
          dateOfNote: "dateOfNote2",
          backgroundColor: AppColors.yellowNotes,
        )
      ],
      pinnedNotesList: [
        PinnedNotes(
          textOfNote: "textOfNote2",
          authorOfNote: "authorOfNote2",
          isLess: false,
          dateOfNote: "dateOfNote2",
          backgroundColor: AppColors.yellowNotes,
        )
      ],
    ),
    act: (bloc) => bloc.add(PinnedNotesChange(index: 0)),
    expect: () => [
      PinnedNotesScreenSuccess(
        pinnedNotesList: [
          PinnedNotes(
            textOfNote: "textOfNote2",
            authorOfNote: "authorOfNote2",
            isLess: true,
            dateOfNote: "dateOfNote2",
            backgroundColor: AppColors.yellowNotes,
          )
        ],
        allNotesList: [
          PinnedNotes(
            textOfNote: "textOfNote",
            authorOfNote: "authorOfNote",
            isLess: true,
            dateOfNote: "dateOfNote",
            backgroundColor: AppColors.skyblueHex,
          ),
          PinnedNotes(
            textOfNote: "textOfNote2",
            authorOfNote: "authorOfNote2",
            isLess: false,
            dateOfNote: "dateOfNote2",
            backgroundColor: AppColors.yellowNotes,
          )
        ],
      ),
    ],
  );

  blocTest<PinnedNotesBloc, PinnedNotesState>(
    'Load Data',
    setUp: () => pinnedNotesBloc = PinnedNotesBloc(),
    tearDown: () => pinnedNotesBloc = null,
    build: () => pinnedNotesBloc!,
    seed: () => PinnedNotesScreenSuccess(
      allNotesList: [
        PinnedNotes(
          textOfNote: "textOfNote",
          authorOfNote: "authorOfNote",
          isLess: true,
          dateOfNote: "dateOfNote",
          backgroundColor: AppColors.yellowNotes,
        ),
        PinnedNotes(
          textOfNote: "textOfNote2",
          authorOfNote: "authorOfNote2",
          isLess: false,
          dateOfNote: "dateOfNote2",
          backgroundColor: AppColors.skyblueHex,
        )
      ],
      pinnedNotesList: [
        PinnedNotes(
          textOfNote: "textOfNote2",
          authorOfNote: "authorOfNote2",
          isLess: false,
          dateOfNote: "dateOfNote2",
          backgroundColor: AppColors.skyblueHex,
        )
      ],
    ),
    act: (bloc) => bloc.add(LoadData()),
    expect: () => [
      PinnednotesScreenProgress(),
      PinnedNotesScreenSuccess(
        allNotesList: [
          PinnedNotes(
              textOfNote:
                  'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
              authorOfNote: 'john Doe',
              dateOfNote: 'Aug 20, 2022',
              isLess: true,
              backgroundColor: AppColors.skyblueHex),
          PinnedNotes(
              textOfNote:
                  'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
              authorOfNote: 'john Doe',
              isLess: true,
              dateOfNote: 'Aug 20, 2022',
              backgroundColor: AppColors.yellowNotes),
          PinnedNotes(
              textOfNote:
                  'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
              authorOfNote: 'john Doe',
              isLess: true,
              dateOfNote: 'Aug 20, 2022',
              backgroundColor: AppColors.yellowNotes),
          PinnedNotes(
              textOfNote:
                  'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
              authorOfNote: 'john Doe',
              isLess: true,
              dateOfNote: 'Aug 20, 2022',
              backgroundColor: AppColors.yellowNotes),
        ],
        pinnedNotesList: [
          PinnedNotes(
              textOfNote:
                  'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
              authorOfNote: 'john Doe',
              dateOfNote: 'Aug 20, 2022',
              isLess: true,
              backgroundColor: AppColors.skyblueHex),
          PinnedNotes(
              textOfNote:
                  'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
              authorOfNote: 'john Doe',
              isLess: true,
              dateOfNote: 'Aug 20, 2022',
              backgroundColor: AppColors.yellowNotes),
        ],
      ),
    ],
  );
}
