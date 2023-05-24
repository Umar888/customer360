import 'package:flutter/material.dart';
import 'package:gc_customer_app/bloc/pinned_notes_bloc/pinned_notes_bloc.dart';
import 'package:gc_customer_app/common_widgets/app_bar_widget.dart';
import 'package:gc_customer_app/common_widgets/notes_widgets/all_notes.dart';
import 'package:gc_customer_app/common_widgets/notes_widgets/left_slide_background.dart';
import 'package:gc_customer_app/common_widgets/notes_widgets/right_slide_background.dart';
import 'package:gc_customer_app/constants/text_strings.dart';
import 'package:gc_customer_app/primitives/size_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common_widgets/pinned_notes_screen_widget.dart';

class PinnedNotesScreen extends StatefulWidget {
  PinnedNotesScreen({super.key});

  @override
  State<PinnedNotesScreen> createState() => _PinnedNotesScreenState();
}

class _PinnedNotesScreenState extends State<PinnedNotesScreen> {
  late PinnedNotesBloc pinnedNotesBloc;
  @override
  void initState() {
    super.initState();
    pinnedNotesBloc = context.read<PinnedNotesBloc>();
    pinnedNotesBloc.add(LoadData());
  }

  @override
  Widget build(BuildContext context) {
    bool ontapSlide = false;
    var textThem = Theme.of(context).textTheme;
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppBarWidget(
          paddingFromleftLeading: widthOfScreen * 0.034,
          paddingFromRightActions: widthOfScreen * 0.034,
          textThem: Theme.of(context).textTheme,
          leadingWidget: Icon(
            Icons.arrow_back,
            color: Colors.grey[600],
            size: 30,
          ),
          onPressedLeading: () => Navigator.of(context).pop(),
          titletxt: 'NOTES  ',
          actionsWidget:SizedBox.shrink(),
          actionOnPress: () => () {},
        ),
      ),
      body: BlocBuilder<PinnedNotesBloc, PinnedNotesState>(
        builder: (context, state) {
          if (state is PinnedNotesScreenSuccess) {
            return Padding(
              padding: EdgeInsets.only(left: widthOfScreen * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pinnedNotestxt, style: textThem.headline2),
                  SizedBox(height: heightOfScreen * 0.02),
                  SizedBox(
                    height: state.pinnedNotesList!
                            .where((element) => !element.isLess!)
                            .isEmpty
                        ? heightOfScreen * 0.225
                        : heightOfScreen * 0.3,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return SizedBox(width: widthOfScreen * 0.04);
                      },
                      itemCount: state.pinnedNotesList!.length,
                      itemBuilder: (context, index) => PinnedNotesScreenWidget(
                        heightOfScreen: heightOfScreen,
                        widthOfScreen: widthOfScreen,
                        pinnedNotes: state.pinnedNotesList ?? [],
                        textThem: textThem,
                        index: index,
                        backgroundColor:
                            state.pinnedNotesList![index].backgroundColor!,
                        authorOfNote:
                            state.pinnedNotesList![index].authorOfNote!,
                        dateOfNote: state.pinnedNotesList![index].dateOfNote!,
                      ),
                    ),
                  ),
                  SizedBox(height: heightOfScreen * 0.04),
                  Text(allNotestxt, style: textThem.headline2),
                  SizedBox(height: heightOfScreen * 0.02),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.allNotesList!.length,
                      itemBuilder: (context, index) => Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              pinnedNotesBloc.add(AllNotesChange(index: index));
                              print('object');
                            },
                            child: Dismissible(
                              background: slideRightBackground(),
                              secondaryBackground: slideLeftBackground(),
                              key: ValueKey('dismissKey$index'),
                              child: AllNotesWidget(
                                heightOfScreen: heightOfScreen,
                                widthOfScreen: widthOfScreen,
                                textThem: textThem,
                                index: index,
                                backgroundColor:
                                    state.allNotesList![index].backgroundColor!,
                                authorOfNote:
                                    state.allNotesList![index].authorOfNote!,
                                dateOfNote:
                                    state.allNotesList![index].dateOfNote!,
                                allNotesList: state.allNotesList ?? [],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: heightOfScreen * 0.02,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return SizedBox(
                height: heightOfScreen,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ));
          }
        },
      ),
    );
  }
}
